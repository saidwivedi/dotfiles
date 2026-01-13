#!/usr/bin/env zsh

# =============================================================================
# WandB Functions for Cluster Environment
# =============================================================================
# Functions to handle WandB synchronization from cluster environments
# where experiments run without internet access.

# Main function to sync WandB logs from cluster with intelligent analysis
function sync_wandb(){
	local hours_before="${1:-2}"  # Default: check folders modified in last 2 hours
	local timezone_offset="${2:-0}"  # Default: no timezone difference

	echo "🔄 Syncing WandB logs from cluster (modified in last $hours_before hours, accounting for ${timezone_offset}h timezone difference)..."

	# Configure these variables for your setup
	local remote_host="${REMOTE_HOST:-hostname}"  # Your remote server hostname
	local remote_base_path="${WANDB_REMOTE_PATH:-/path/to/wandb_logs}"  # Path to wandb logs on remote
	local local_path="${WANDB_LOCAL_PATH:-.}"  # Local path for wandb logs
	local max_attempts=3
	local attempt=1

	# Get list of folders modified in the last x hours using a single SSH connection
	echo "🔍 Finding folders modified in last $hours_before hours on cluster..."

	# Account for timezone: if local is ahead by N hours, look back N more hours on cluster
	local adjusted_hours=$((hours_before + timezone_offset))
	local minutes_before=$((adjusted_hours * 60))

	# Set up SSH connection multiplexing to reuse a single connection
	local ssh_socket="/tmp/ssh_socket_$(id -un)_${remote_host}"
	export RSYNC_RSH="ssh -o ControlMaster=auto -o ControlPath=$ssh_socket -o ControlPersist=86400"

	# Consolidate ALL SSH operations into a single connection to reduce authentication prompts
	local ssh_results
	ssh_results=$(ssh -o ControlMaster=auto -o ControlPath="$ssh_socket" -o ControlPersist=86400 "$remote_host" "
		if [[ -d '$remote_base_path' ]]; then
			echo 'All run directories with timestamps:'
			find '$remote_base_path' -name 'offline-run-*' -type d -exec ls -ld {} \; 2>/dev/null | sort
			echo '===SEPARATOR1==='

			# Find modified run directories
			find '$remote_base_path' -name 'offline-run-*' -type d -mmin -$minutes_before 2>/dev/null
			echo '===SEPARATOR2==='

			# Get all subdirectories for modified run directories
			for run_dir in \$(find '$remote_base_path' -name 'offline-run-*' -type d -mmin -$minutes_before 2>/dev/null); do
				if [[ -d \"\$run_dir\" ]]; then
					find \"\$run_dir\" -type d 2>/dev/null
				fi
			done
		fi
	" 2>/dev/null)

	# Parse the results
	local all_dirs_info=$(echo "$ssh_results" | sed '/===SEPARATOR1===/,$d')
	local modified_run_dirs=$(echo "$ssh_results" | sed '1,/===SEPARATOR1===/d' | sed '/===SEPARATOR2===/,$d')
	local all_subdirs=$(echo "$ssh_results" | sed '1,/===SEPARATOR2===/d')

	echo "$all_dirs_info"

	if [[ -n "$modified_run_dirs" ]]; then
		echo "📋 Modified run directories found: $(echo "$modified_run_dirs" | wc -l)"
	else
		echo "📋 No modified run directories found"
	fi

	# Process subdirectories
	local modified_folders=""
	if [[ -n "$modified_run_dirs" ]]; then
		if [[ -n "$all_subdirs" ]]; then
			modified_folders="$all_subdirs"
		fi

		# Add the wandb parent directory
		modified_folders="$remote_base_path/wandb"$'\n'"$modified_folders"

		# Remove duplicates and empty lines
		modified_folders=$(echo "$modified_folders" | sort -u | grep -v '^$')
	fi

	if [[ -z "$modified_folders" ]]; then
		echo "📭 No folders modified in last $hours_before hours found on cluster"
		return 0
	fi

	echo "📂 Found $(echo "$modified_folders" | wc -l) folder(s) to sync:"
	echo "$modified_folders" | sed "s|$remote_base_path/||g" | sed 's/^/  /'

	# Delete only the corresponding local folders that will be updated
	if [[ -d "wandb_logs" ]]; then
		echo "🧹 Cleaning up local folders that will be updated..."
		echo "$modified_folders" | while read -r folder; do
			local relative_path="${folder#$remote_base_path/}"
			if [[ -d "wandb_logs/$relative_path" ]]; then
				echo "  🗑️  Removing: wandb_logs/$relative_path"
				rm -rf "wandb_logs/$relative_path"
			fi
		done
	fi

	# Sync only the modified folders
	while [[ $attempt -le $max_attempts ]]; do
		echo "📡 Attempt $attempt/$max_attempts: Syncing modified folders..."

		# Create include pattern for rsync to sync only modified folders
		{
			# Add parent wandb directory
			echo "+ wandb/"

			# Add specific run directories and their contents
			echo "$modified_run_dirs" | while read -r run_dir; do
				if [[ -n "$run_dir" ]]; then
					local run_name=$(basename "$run_dir")
					echo "+ wandb/$run_name/"
					echo "+ wandb/$run_name/**"
				fi
			done

			# Exclude all other offline-run directories
			echo "- wandb/offline-run-*"

			# Exclude everything else
			echo "- *"
		} > /tmp/wandb_include_list


		rsync -av --info=progress2 --ignore-errors --partial --delay-updates --safe-links \
			--include-from=/tmp/wandb_include_list \
			"${remote_host}:$remote_base_path/" "wandb_logs/"

		local rsync_status=$?
		rm -f /tmp/wandb_include_list

		if [[ $rsync_status -eq 0 ]]; then
			echo "✅ Selective sync completed"
			break
		elif [[ $attempt -eq $max_attempts ]]; then
			echo "⚠️  Sync had issues but proceeding..."
			break
		else
			echo "⚠️  Sync had issues, retrying in 2 seconds..."
			sleep 2
		fi

		((attempt++))
	done

	if [[ -d "wandb_logs" ]]; then
		echo "🔍 Analyzing WandB files..."

		# Check for .wandb files and their status
		local total_wandb_files=0
		local valid_wandb_files=0
		local corrupted_files=0

		while IFS= read -r -d '' file; do
			((total_wandb_files++))
			local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
			local run_name=$(basename "$(dirname "$file")")

			if [[ $file_size -eq 0 ]]; then
				echo "  ❌ Corrupted (0 bytes): $run_name/$(basename "$file")"
				((corrupted_files++))
			elif [[ $file_size -lt 7 ]]; then
				echo "  ❌ Corrupted (<7 bytes): $run_name/$(basename "$file") (${file_size} bytes)"
				((corrupted_files++))
			else
				echo "  ✅ Valid: $run_name/$(basename "$file") (${file_size} bytes)"
				((valid_wandb_files++))
			fi
		done < <(find wandb_logs -name "*.wandb" -print0 2>/dev/null)

		echo ""
		echo "📊 WandB Files Summary:"
		echo "   Total runs found: $total_wandb_files"
		echo "   Valid runs: $valid_wandb_files"
		echo "   Corrupted runs: $corrupted_files"

		if [[ $valid_wandb_files -gt 0 ]]; then
			echo ""
			echo "🔄 Syncing valid runs to WandB..."
			cd wandb_logs

			if sync_wandb_with_retry_on_conflict; then
				echo "✅ WandB sync completed successfully!"
				echo "🎉 Uploaded $valid_wandb_files run(s) to WandB"
			else
				echo "⚠️  WandB sync had some issues"
			fi
			cd ..
		elif [[ $corrupted_files -gt 0 ]]; then
			echo ""
			echo "⚠️  Only corrupted runs found - likely experiment is still running"
			echo "💡 Solutions:"
			echo "   1. Wait for experiment to finish, then run sync_wandb again"
			echo "   2. Stop the experiment on cluster, then sync"
			echo "   3. Check if experiment crashed and restart it"
		else
			echo ""
			echo "❓ No WandB run files found"
		fi

	else
		echo "❌ No wandb_logs directory found after sync"
		return 1
	fi
}

# Helper function to sync wandb with retry on conflict
function sync_wandb_with_retry_on_conflict() {
	local max_attempts=1
	local attempt=1

	while [[ $attempt -le $max_attempts ]]; do
		echo "🔄 Sync attempt $attempt/$max_attempts..."

		# Try standard sync first with real-time output and capture to file
		echo "📋 Starting wandb sync (you'll see real-time output)..."
		wandb sync --sync-all --include-offline wandb 2>&1 | tee /tmp/wandb_sync_output
		local sync_exit_code=${PIPESTATUS[0]}
		echo ""

		# Check if the output contains the "previously created and deleted" error FIRST
		# (wandb sync can return exit code 0 even with 409 conflicts)
		if grep -q "previously created and deleted; try a new run name" /tmp/wandb_sync_output; then
			echo "⚠️  Detected run ID conflict error, attempting to fix..."

			# Extract all problematic run IDs from the output
			local problematic_runs=$(grep -o 'run [a-z0-9]\{8\}' /tmp/wandb_sync_output | cut -d' ' -f2 | sort -u)

			if [[ -n "$problematic_runs" ]]; then
				echo "🔧 Found problematic run(s): $(echo "$problematic_runs" | tr '\n' ' ')"

				# Handle each problematic run
				while IFS= read -r problematic_run; do
					if [[ -n "$problematic_run" ]]; then
						echo "🔄 Processing run: $problematic_run"

						# Find the corresponding offline run directory
						local offline_run_dir=$(find wandb -name "offline-run-*-$problematic_run" -type d | head -1)

						if [[ -n "$offline_run_dir" && -d "$offline_run_dir" ]]; then
							echo "📁 Found offline run directory: $offline_run_dir"

							# Generate a new 8-character random run ID
							local new_run_id=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
							echo "🆔 Generated new run ID: $new_run_id"

							# Sync with new ID
							echo "🔄 Syncing with new run ID..."
							if wandb sync "$offline_run_dir" --id "$new_run_id"; then
								echo "✅ Successfully synced $problematic_run with new run ID: $new_run_id"
							else
								echo "❌ Failed to sync $problematic_run with new run ID"
							fi
						else
							echo "❌ Could not find offline run directory for: $problematic_run"
							# List available directories for debugging
							echo "🔍 Available offline run directories:"
							find wandb -name "offline-run-*" -type d | head -10
						fi
					fi
				done <<< "$problematic_runs"

				# After handling conflicts, try syncing remaining runs
				echo "🔄 Attempting to sync any remaining runs..."
				# Use continue here to retry the main loop

			else
				echo "❌ Could not extract problematic run ID from error"
			fi
		elif [[ $sync_exit_code -eq 0 ]]; then
			# If sync was successful and no conflicts detected, we're done
			echo "✅ Standard sync successful"
			rm -f /tmp/wandb_sync_output
			return 0
		else
			echo "❌ Different error encountered (not run ID conflict):"
			echo "Error output: $(cat /tmp/wandb_sync_output)"
		fi

		rm -f /tmp/wandb_sync_output
		((attempt++))

		if [[ $attempt -le $max_attempts ]]; then
			echo "⏳ Waiting 2 seconds before retry..."
			sleep 2
		fi
	done

	echo "❌ All sync attempts failed after $max_attempts tries"
	return 1
}

# Helper function to check WandB status on cluster without syncing
function check_wandb_cluster(){
	echo "🔍 Checking WandB status on cluster..."

	local remote_host="${REMOTE_HOST:-hostname}"
	local remote_path="${WANDB_REMOTE_PATH:-/path/to/wandb_logs}"

	echo "📡 Checking cluster files..."
	ssh "$remote_host" "
		if [[ -d '$remote_path' ]]; then
			echo '✅ WandB logs directory exists on cluster'
			echo '📊 Run summary:'
			find '$remote_path' -name '*.wandb' -exec ls -lh {} \; | while read -r line; do
				size=\$(echo \"\$line\" | awk '{print \$5}')
				file=\$(echo \"\$line\" | awk '{print \$9}')
				run_name=\$(basename \"\$(dirname \"\$file\")\")
				if [[ \"\$size\" == \"0\" ]]; then
					echo \"  ❌ \$run_name: 0 bytes (corrupted)\"
				else
					echo \"  ✅ \$run_name: \$size\"
				fi
			done 2>/dev/null || echo '📁 No .wandb files found'
		else
			echo '❌ No WandB logs directory found on cluster'
		fi
	"
}

# Helper function to sync only completed runs (filter by age)
function sync_wandb_completed(){
	local min_age_minutes="${1:-5}"  # Default: files older than 5 minutes

	echo "🔄 Syncing only completed WandB runs (older than $min_age_minutes minutes)..."

	local local_wandb_dir="${WANDB_LOCAL_PATH:-.}/wandb_logs"
	[[ -d "$local_wandb_dir" ]] && rm -rf "$local_wandb_dir"

	local remote_host="${REMOTE_HOST:-hostname}"
	local remote_path="${remote_host}:${WANDB_REMOTE_PATH:-/path/to/wandb_logs}"
	local local_path="${WANDB_LOCAL_PATH:-.}"

	# First, sync all files
	rsync -av --info=progress2 --ignore-errors --partial --delay-updates --safe-links "$remote_path" "$local_path"

	if [[ -d "wandb_logs" ]]; then
		echo "🧹 Filtering out recently modified files (likely still being written)..."

		# Remove .wandb files that were modified in the last N minutes
		find wandb_logs -name "*.wandb" -newermt "$min_age_minutes minutes ago" -delete

		# Now proceed with regular sync logic
		echo "🔍 Analyzing remaining WandB files..."

		local total_wandb_files=0
		local valid_wandb_files=0

		while IFS= read -r -d '' file; do
			((total_wandb_files++))
			local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
			local run_name=$(basename "$(dirname "$file")")

			if [[ $file_size -ge 7 ]]; then
				echo "  ✅ Valid: $run_name/$(basename "$file") (${file_size} bytes)"
				((valid_wandb_files++))
			fi
		done < <(find wandb_logs -name "*.wandb" -print0 2>/dev/null)

		if [[ $valid_wandb_files -gt 0 ]]; then
			echo "🔄 Syncing $valid_wandb_files completed run(s) to WandB..."
			cd wandb_logs
			wandb sync --sync-all --include-offline wandb
			cd ..
		else
			echo "📭 No completed runs found (all runs are still active)"
		fi
	fi
}
