#!/usr/bin/env zsh

# Function to convert bytes to MB with decimal precision
bytes_to_mb() {
    local bytes="$1"
    if [[ -n "$bytes" && "$bytes" -gt 0 ]]; then
        awk "BEGIN {printf \"%.1f\", $bytes/1048576}"
    else
        echo "0.0"
    fi
}

# Function to convert bytes to human readable format (helper for stable display)
bytes_to_human() {
    local bytes="$1"
    if [[ -z "$bytes" || "$bytes" -eq 0 ]]; then
        echo "0B"
        return
    fi

    if [[ "$bytes" -ge 1099511627776 ]]; then
        awk "BEGIN {printf \"%.2fTB\", $bytes/1099511627776}"
    elif [[ "$bytes" -ge 1073741824 ]]; then
        awk "BEGIN {printf \"%.2fGB\", $bytes/1073741824}"
    elif [[ "$bytes" -ge 1048576 ]]; then
        awk "BEGIN {printf \"%.1fMB\", $bytes/1048576}"
    elif [[ "$bytes" -ge 1024 ]]; then
        awk "BEGIN {printf \"%.0fKB\", $bytes/1024}"
    else
        echo "${bytes}B"
    fi
}

# Function to convert bytes to GB with decimal precision
bytes_to_gb() {
    local bytes="$1"
    if [[ -n "$bytes" && "$bytes" -gt 0 ]]; then
        awk "BEGIN {printf \"%.2f\", $bytes/1073741824}"
    else
        echo "0.00"
    fi
}

# Function to parse size with unit and convert to bytes
parse_size_to_bytes() {
    local size_str="$1"
    if [[ -z "$size_str" ]]; then
        echo "0"
        return
    fi

    # Remove commas and extract number and unit
    local clean_size=$(echo "$size_str" | tr -d ',' | tr '[:upper:]' '[:lower:]')
    local number=$(echo "$clean_size" | grep -oE '[0-9.]+')
    local unit=$(echo "$clean_size" | grep -oE '[kmgt]?b$')

    if [[ -z "$number" ]]; then
        echo "0"
        return
    fi

    case "$unit" in
        "kb") awk "BEGIN {printf \"%.0f\", $number * 1024}" ;;
        "mb") awk "BEGIN {printf \"%.0f\", $number * 1048576}" ;;
        "gb") awk "BEGIN {printf \"%.0f\", $number * 1073741824}" ;;
        "tb") awk "BEGIN {printf \"%.0f\", $number * 1099511627776}" ;;
        *) echo "${number%.*}" ;; # Assume bytes if no unit
    esac
}

# Function to draw a visual progress bar with enhanced info
draw_progress_bar() {
    local percent="$1"
    local info_line="$2"
    local preview_total_bytes="${3:-0}"  # Add stable total from preview
    local bar_length=40
    local filled_length=$((percent * bar_length / 100))
    local empty_length=$((bar_length - filled_length))

    # Clean the input line by removing carriage returns and control characters
    info_line=$(echo "$info_line" | tr -d '\r\n\0' | sed 's/[[:cntrl:]]//g')

    # Create the progress bar with ASCII characters for better compatibility
    local filled_bar=$(printf "%*s" $filled_length "" | tr ' ' '=')
    local empty_bar=$(printf "%*s" $empty_length "" | tr ' ' '-')

    # Extract detailed transfer info from the line
    local speed=$(echo "$info_line" | grep -oE '[0-9.,]+[kMGT]?B/s' | tail -1)
    local eta_info=$(echo "$info_line" | grep -oE '[0-9]+:[0-9]+:[0-9]+' | tail -1)

    # Extract transferred and total sizes more robustly
    local transferred_size=""
    local total_size=""

    # Parse rsync --info=progress2 output format:
    # Example: "    123,456,789  45%    1.23MB/s    0:01:23 (xfr#123, to-chk=456/789)"
    # We want the first number (bytes transferred), not the speed

    # First try to extract raw byte count (the leading number without units)
    local raw_bytes=$(echo "$info_line" | grep -oE '^\s*[0-9,]+' | tr -d ' ,')

    if [[ -n "$raw_bytes" && "$raw_bytes" -gt 0 ]]; then
        # Convert raw bytes to human-readable format
        transferred_size=$(bytes_to_human "$raw_bytes")
    else
        # Fallback: look for size patterns, but exclude speeds (patterns with "/s")
        local size_candidates=$(echo "$info_line" | grep -oE '[0-9.,]+[kMGT]?B' | grep -v '/s')
        if [[ -n "$size_candidates" ]]; then
            transferred_size=$(echo "$size_candidates" | head -1)
        fi
    fi

    # Set total size using stable preview total if available
    if [[ "$preview_total_bytes" -gt 0 ]]; then
        # Use the stable total from preview scan
        total_size=$(bytes_to_human "$preview_total_bytes")
    elif [[ -n "$transferred_size" && "$percent" -gt 0 && -z "$raw_bytes" ]]; then
        # Fall back to calculation only if no stable reference and no raw bytes available
        local transferred_bytes=$(parse_size_to_bytes "$transferred_size")
        if [[ "$transferred_bytes" -gt 0 ]]; then
            local total_bytes=$(awk "BEGIN {printf \"%.0f\", $transferred_bytes * 100 / $percent}")
            total_size=$(bytes_to_human "$total_bytes")
        fi
    fi

    # Color codes
    local green='\033[0;32m'
    local blue='\033[0;36m'
    local yellow='\033[1;33m'
    local purple='\033[0;35m'
    local cyan='\033[0;96m'
    local bold='\033[1m'
    local nc='\033[0m' # No Color

    # Format the progress text with enhanced size display
    local progress_text=""

    # Show transfer progress with appropriate units
    if [[ -n "$transferred_size" && -n "$total_size" ]]; then
        local transferred_bytes=$(parse_size_to_bytes "$transferred_size")
        local total_bytes=$(parse_size_to_bytes "$total_size")

        # Format transferred amount in appropriate unit (GB if >= 1GB, otherwise MB)
        local transferred_display=""
        if [[ "$transferred_bytes" -ge 1073741824 ]]; then
            local transferred_gb=$(bytes_to_gb "$transferred_bytes")
            transferred_display="${transferred_gb}GB"
        else
            local transferred_mb=$(bytes_to_mb "$transferred_bytes")
            transferred_display="${transferred_mb}MB"
        fi

        # Format total amount in appropriate unit (GB if >= 1GB, otherwise MB)
        local total_display=""
        if [[ "$total_bytes" -ge 1073741824 ]]; then
            local total_gb=$(bytes_to_gb "$total_bytes")
            total_display="${total_gb}GB"
        else
            local total_mb=$(bytes_to_mb "$total_bytes")
            total_display="${total_mb}MB"
        fi

        progress_text="${cyan}${transferred_display}${nc}/${purple}${total_display}${nc}"
    elif [[ -n "$transferred_size" ]]; then
        local transferred_bytes=$(parse_size_to_bytes "$transferred_size")

        # Format transferred amount in appropriate unit
        if [[ "$transferred_bytes" -ge 1073741824 ]]; then
            local transferred_gb=$(bytes_to_gb "$transferred_bytes")
            progress_text="${cyan}${transferred_gb}GB${nc}"
        else
            local transferred_mb=$(bytes_to_mb "$transferred_bytes")
            progress_text="${cyan}${transferred_mb}MB${nc}"
        fi
    fi

    # Add speed information
    if [[ -n "$speed" ]]; then
        if [[ -n "$progress_text" ]]; then
            progress_text="${progress_text} ${yellow}@ ${speed}${nc}"
        else
            progress_text="${yellow}@ ${speed}${nc}"
        fi
    fi

    # Add ETA information
    if [[ -n "$eta_info" ]]; then
        progress_text="${progress_text} ${blue}ETA: ${eta_info}${nc}"
    fi

    # Print the enhanced progress bar
    printf "\r${bold}📥 [${green}${filled_bar}${empty_bar}${nc}${bold}] ${percent}%%${nc} ${progress_text}"

    # If 100%, add a newline and completion message
    if [[ "$percent" -eq 100 ]]; then
        printf "\n${green}🎉 Transfer completed!${nc}\n"
    fi
}

# Function to setup SSH connection sharing for single authentication
setup_ssh_connection() {
    local remote_host="$1"
    local ssh_socket="/tmp/ssh_socket_$$_$(date +%s)"

    echo "🔐 Establishing SSH connection (authenticate once)..." >&2

    # Create master connection
    ssh -M -S "$ssh_socket" -fN "$remote_host"

    if [[ $? -eq 0 ]]; then
        echo "✅ SSH connection established" >&2
        echo "$ssh_socket"  # Only this goes to stdout for capture
        return 0
    else
        echo "❌ Failed to establish SSH connection" >&2
        return 1
    fi
}

# Function to cleanup SSH connection
cleanup_ssh_connection() {
    local ssh_socket="$1"
    local remote_host="$2"

    if [[ -n "$ssh_socket" && -S "$ssh_socket" ]]; then
        ssh -S "$ssh_socket" -O exit "$remote_host" 2>/dev/null
        rm -f "$ssh_socket" 2>/dev/null
        echo "🔌 SSH connection closed"
    fi
}

# Function to iteratively download a folder using rsync
# Usage: download_folder <folder_name> [max_retries] [base_remote_path] [skip_preview] [ssh_socket] [batch_mode]
download_folder() {
    local folder_name="$1"
    local max_retries="${2:-3}"
    local base_remote_path="${3:-${REMOTE_BASE_PATH:-/path/to/remote/data}}"
    local skip_preview="${4:-false}"
    local ssh_socket="$5"
    local batch_mode="${6:-false}"
    local remote_host="${REMOTE_HOST:-hostname}"
    local cleanup_ssh=false

    # Validate input
    if [[ -z "$folder_name" ]]; then
        echo "Error: Folder name is required"
        echo "Usage: download_folder <folder_name> [max_retries] [base_remote_path] [skip_preview] [ssh_socket]"
        return 1
    fi

    local remote_path="${remote_host}:${base_remote_path}/${folder_name}"
    local local_path="./"
    local retry_count=0

    echo "Starting download of: $folder_name"
    echo "Remote path: $remote_path"
    echo "Local path: $local_path"
    echo "Max retries: $max_retries"
    echo "----------------------------------------"

    # Setup SSH connection sharing if not provided
    if [[ -z "$ssh_socket" ]]; then
        if ! ssh_socket=$(setup_ssh_connection "$remote_host"); then
            echo "❌ Failed to establish SSH connection"
            return 1
        fi
        cleanup_ssh=true
        # Trap to ensure SSH connection cleanup on exit
        trap "cleanup_ssh_connection '$ssh_socket' '$remote_host'" EXIT INT TERM
    fi

    # Create local directory structure if it doesn't exist
    local local_folder_path="$folder_name"
    mkdir -p "$(dirname "$local_folder_path")"

    # Extract just the folder name for rsync destination
    local folder_basename=$(basename "$folder_name")
    local folder_dirname=$(dirname "$folder_name")

    # Set up local path for rsync - if there's a directory structure, navigate into it
    if [[ "$folder_dirname" != "." ]]; then
        local_path="$folder_dirname/"
    else
        local_path="./"
    fi

    # Get download preview information (skip if requested)
    local file_count=0
    local total_size_bytes=0

    if [[ "$skip_preview" != "true" ]]; then
        echo "🔍 Scanning remote folder for remaining files to download..."
        local scan_output=$(rsync -av --dry-run --stats --checksum -e "ssh -S $ssh_socket" "$remote_path" "$local_path" 2>/dev/null)

        if [[ $? -eq 0 && -n "$scan_output" ]]; then
            # Extract file count and total size from stats (only files that need to be transferred)
            file_count=$(echo "$scan_output" | grep "Number of regular files transferred:" | grep -oE '[0-9,]+' | head -1 | tr -d ',')
            total_size_bytes=$(echo "$scan_output" | grep "Total transferred file size:" | grep -oE '[0-9,]+' | head -1 | tr -d ',')

            # Check for files that are skipped (already exist)
            local skipped_files=$(echo "$scan_output" | grep -c "skipping")
            local existing_files=$(echo "$scan_output" | grep "Number of files:" | grep -oE '[0-9,]+' | head -1 | tr -d ',')

            # Convert bytes to human readable format if we have the size
            local total_size_human=""
            if [[ -n "$total_size_bytes" && "$total_size_bytes" -gt 0 ]]; then
                if command -v numfmt >/dev/null 2>&1; then
                    total_size_human=$(numfmt --to=iec-i --suffix=B "$total_size_bytes" 2>/dev/null)
                else
                    # Fallback size calculation
                    if [[ "$total_size_bytes" -gt 1073741824 ]]; then
                        total_size_human=$(( total_size_bytes / 1073741824 ))"GB"
                    elif [[ "$total_size_bytes" -gt 1048576 ]]; then
                        total_size_human=$(( total_size_bytes / 1048576 ))"MB"
                    elif [[ "$total_size_bytes" -gt 1024 ]]; then
                        total_size_human=$(( total_size_bytes / 1024 ))"KB"
                    else
                        total_size_human="${total_size_bytes}B"
                    fi
                fi
            fi

            # Display preview information
            echo "📊 Download Preview (remaining files only):"
            if [[ -n "$file_count" && "$file_count" -gt 0 ]]; then
                echo "   📁 Files to download: ${file_count}"
                if [[ -n "$total_size_human" ]]; then
                    echo "   💾 Size to download: $total_size_human"
                fi

                # Show average file size
                if [[ -n "$total_size_bytes" && "$file_count" -gt 0 ]]; then
                    local avg_file_size=$((total_size_bytes / file_count))
                    local avg_size_human=""
                    if [[ "$avg_file_size" -ge 1048576 ]]; then
                        avg_size_human="$(bytes_to_mb $avg_file_size)MB"
                    elif [[ "$avg_file_size" -ge 1024 ]]; then
                        avg_size_human="$((avg_file_size / 1024))KB"
                    else
                        avg_size_human="${avg_file_size}B"
                    fi
                    echo "   📏 Average file size: $avg_size_human"
                fi

                # Show info about already existing files if any
                if [[ -n "$existing_files" && "$existing_files" -gt "$file_count" ]]; then
                    local already_downloaded=$((existing_files - file_count))
                    echo "   ✅ Files already downloaded: $already_downloaded"
                    echo "   🔄 Remaining files to download: $file_count"
                fi

                echo "   📁 Transfer method: Direct rsync"
            elif [[ -n "$file_count" && "$file_count" -eq 0 ]]; then
                echo "   ✅ All files are already downloaded - nothing to transfer!"
                echo "   📁 Total files in folder: ${existing_files:-"unknown"}"
                echo "----------------------------------------"
                echo "🎉 Download complete (all files already existed locally)"
                return 0
            else
                echo "   📁 Files to download: calculating..."
            fi
            echo "----------------------------------------"

            # Ask for confirmation if it's a large download (skip in batch mode)
            if [[ -n "$total_size_bytes" && "$total_size_bytes" -gt 1073741824 && "$batch_mode" != "true" ]]; then
                echo "⚠️  Large remaining download detected (>1GB). Press Ctrl+C to cancel or any key to continue..."
                read -k1 -s
                echo ""
            fi
        else
            echo "ℹ️  Could not get download preview (folder might be empty or connection issue)"
            echo "----------------------------------------"
        fi
    else
        echo "⚡ Skipping preview scan - starting download immediately"
        echo "----------------------------------------"
    fi

    # Standard rsync method
    while [[ $retry_count -le $max_retries ]]; do
        if [[ $retry_count -gt 0 ]]; then
            echo "Retry attempt $retry_count/$max_retries..."
            sleep 2
        fi

        echo "Executing: rsync -av --checksum --info=progress2 -e ssh $remote_path $local_path"

        # Execute rsync with overall progress and error handling (using shared SSH connection)
        # The --checksum option ensures only files with different content are transferred
        if rsync -av --checksum --info=progress2 -e "ssh -S $ssh_socket" "$remote_path" "$local_path" | while IFS= read -r line; do
            # Display progress lines that show overall transfer stats
            if [[ "$line" =~ [0-9]+% ]]; then
                # Extract percentage and create progress bar
                local percent=$(echo "$line" | grep -o '[0-9]\+%' | head -1 | tr -d '%')
                if [[ -n "$percent" ]]; then
                    draw_progress_bar "$percent" "$line" "$total_size_bytes"
                fi
            elif [[ "$line" =~ ^[[:space:]]*[0-9,]+[[:space:]]+[0-9]+%.*$ ]]; then
                # Skip individual file transfer lines to avoid cluttering
                continue
            elif [[ ! "$line" =~ ^[^/]*/.* ]]; then
                # Only show non-file-path lines (errors, completion messages, etc.)
                echo "$line"
            fi
        done; then
            echo "✅ Download completed successfully!"

            # Display summary
            if [[ -d "$folder_name" ]]; then
                local file_count=$(find "$folder_name" -type f | wc -l)
                local dir_size=$(du -sh "$folder_name" 2>/dev/null | cut -f1)
                echo "📊 Summary:"
                echo "   Files downloaded: $file_count"
                echo "   Total size: $dir_size"
            fi

            # Cleanup SSH connection if we created it
            if [[ "$cleanup_ssh" == "true" ]]; then
                cleanup_ssh_connection "$ssh_socket" "$remote_host"
            fi
            return 0
        else
            local exit_code=$?
            echo "❌ rsync failed with exit code: $exit_code"

            if [[ $retry_count -eq $max_retries ]]; then
                echo "🚫 Max retries reached. Download failed."
                # Cleanup SSH connection if we created it
                if [[ "$cleanup_ssh" == "true" ]]; then
                    cleanup_ssh_connection "$ssh_socket" "$remote_host"
                fi
                return $exit_code
            fi

            ((retry_count++))
        fi
    done
}

# Function to expand wildcards on remote server
expand_remote_wildcards() {
    local pattern="$1"
    local base_remote_path="${2:-${REMOTE_BASE_PATH:-/path/to/remote/data}}"
    local remote_host="${REMOTE_HOST:-hostname}"

    # If pattern doesn't contain wildcards, return as-is
    if [[ "$pattern" != *"*"* && "$pattern" != *"?"* && "$pattern" != *"["* ]]; then
        echo "$pattern"
        return 0
    fi

    echo "🔍 Expanding wildcard pattern: $pattern" >&2

    # Use ssh to list matching directories on remote server
    local remote_matches=$(ssh "$remote_host" "cd '$base_remote_path' 2>/dev/null && ls -1d $pattern 2>/dev/null | grep -v '^ls:' | head -20" 2>/dev/null)

    if [[ -n "$remote_matches" ]]; then
        local match_count=$(echo "$remote_matches" | wc -l | tr -d ' ')
        echo "✅ Found $match_count matching folder(s):" >&2
        echo "$remote_matches" | sed 's/^/   - /' >&2
        echo "$remote_matches"
    else
        echo "❌ No folders match pattern: $pattern" >&2
        return 1
    fi
}

# Function to download multiple folders iteratively
dfs() {
    local folders=("$@")
    local failed_downloads=()
    local successful_downloads=()
    local expanded_folders=()
    local ssh_socket=""
    local remote_host="${REMOTE_HOST:-hostname}"

    if [[ ${#folders[@]} -eq 0 ]]; then
        echo "Error: At least one folder name is required"
        echo "Usage: dfs <folder1> [folder2] [folder3] ..."
        echo "Supports wildcards: dfs 'foldername*' 'test_*' etc."
        return 1
    fi

    # Set up single SSH connection for all downloads (authenticate once)
    if ! ssh_socket=$(setup_ssh_connection "$remote_host"); then
        echo "❌ Failed to establish SSH connection"
        return 1
    fi

    # Trap to ensure SSH connection cleanup on exit
    trap "cleanup_ssh_connection '$ssh_socket' '$remote_host'" EXIT INT TERM

    # First pass: expand any wildcards (using shared SSH connection)
    echo "🔍 Expanding folder patterns..."
    for folder in "${folders[@]}"; do
        if [[ "$folder" == *"*"* || "$folder" == *"?"* || "$folder" == *"["* ]]; then
            # This is a wildcard pattern - use the shared SSH connection
            local base_remote_path="${REMOTE_BASE_PATH:-/path/to/remote/data}"
            local remote_matches=$(ssh -S "$ssh_socket" "$remote_host" "cd '$base_remote_path' 2>/dev/null && ls -1d $folder 2>/dev/null | grep -v '^ls:' | head -20" 2>/dev/null)

            if [[ -n "$remote_matches" ]]; then
                local match_count=$(echo "$remote_matches" | wc -l | tr -d ' ')
                echo "✅ Found $match_count matching folder(s) for pattern '$folder':"
                echo "$remote_matches" | sed 's/^/   - /'
                while IFS= read -r match; do
                    [[ -n "$match" ]] && expanded_folders+=("$match")
                done <<< "$remote_matches"
            else
                echo "⚠️  Pattern '$folder' didn't match any folders - skipping"
            fi
        else
            # Regular folder name
            expanded_folders+=("$folder")
        fi
    done

    if [[ ${#expanded_folders[@]} -eq 0 ]]; then
        echo "❌ No folders to download after pattern expansion"
        cleanup_ssh_connection "$ssh_socket" "$remote_host"
        return 1
    fi

    echo "📦 Starting batch download of ${#expanded_folders[@]} folder(s)..."
    echo "=========================================="

    for folder in "${expanded_folders[@]}"; do
        echo ""
        echo "🔄 Processing: $folder"

        # Pass the shared SSH socket to download_folder (with batch_mode=true)
        if download_folder "$folder" 3 "${REMOTE_BASE_PATH:-/path/to/remote/data}" false "$ssh_socket" true; then
            successful_downloads+=("$folder")
            echo "✅ $folder - SUCCESS"
        else
            failed_downloads+=("$folder")
            echo "❌ $folder - FAILED"
        fi

        echo "----------------------------------------"
    done

    # Cleanup SSH connection
    cleanup_ssh_connection "$ssh_socket" "$remote_host"

    # Final summary
    echo ""
    echo "📋 FINAL SUMMARY"
    echo "================"
    echo "✅ Successful: ${#successful_downloads[@]}"
    for folder in "${successful_downloads[@]}"; do
        echo "   - $folder"
    done

    if [[ ${#failed_downloads[@]} -gt 0 ]]; then
        echo "❌ Failed: ${#failed_downloads[@]}"
        for folder in "${failed_downloads[@]}"; do
            echo "   - $folder"
        done
        return 1
    fi

    echo "🎉 All downloads completed successfully!"
    return 0
}

# Function to download multiple folders without preview scans (faster)
dfs_fast() {
    local folders=("$@")
    local failed_downloads=()
    local successful_downloads=()

    if [[ ${#folders[@]} -eq 0 ]]; then
        echo "Error: At least one folder name is required"
        echo "Usage: dfs_fast <folder1> [folder2] [folder3] ..."
        return 1
    fi

    echo "⚡ Starting FAST batch download of ${#folders[@]} folder(s) (no preview scans)..."
    echo "=========================================="

    for folder in "${folders[@]}"; do
        echo ""
        echo "🔄 Processing: $folder"

        if download_folder "$folder" 3 "${REMOTE_BASE_PATH:-/path/to/remote/data}" true; then
            successful_downloads+=("$folder")
            echo "✅ $folder - SUCCESS"
        else
            failed_downloads+=("$folder")
            echo "❌ $folder - FAILED"
        fi

        echo "----------------------------------------"
    done

    # Final summary
    echo ""
    echo "📋 FINAL SUMMARY"
    echo "================"
    echo "✅ Successful: ${#successful_downloads[@]}"
    for folder in "${successful_downloads[@]}"; do
        echo "   - $folder"
    done

    if [[ ${#failed_downloads[@]} -gt 0 ]]; then
        echo "❌ Failed: ${#failed_downloads[@]}"
        for folder in "${failed_downloads[@]}"; do
            echo "   - $folder"
        done
        return 1
    fi

    echo "🎉 All downloads completed successfully!"
    return 0
}

# Helper function to check remote folder exists before downloading
check_remote_folder() {
    local folder_name="$1"
    local base_remote_path="${2:-${REMOTE_BASE_PATH:-/path/to/remote/data}}"
    local remote_host="${REMOTE_HOST:-hostname}"

    if [[ -z "$folder_name" ]]; then
        echo "Error: Folder name is required"
        return 1
    fi

    local remote_path="${base_remote_path}/${folder_name}"

    echo "Checking if remote folder exists: $remote_path"

    if ssh "$remote_host" "test -d '$remote_path'"; then
        echo "✅ Remote folder exists: $remote_path"

        # Get folder info
        local folder_info=$(ssh "$remote_host" "ls -la '$remote_path' | head -10")
        echo "📁 Folder contents preview:"
        echo "$folder_info"
        return 0
    else
        echo "❌ Remote folder does not exist: $remote_path"
        return 1
    fi
}

# Export functions for use in interactive shells
# Add these lines to your ~/.zshrc to make them available in all sessions:
# source /path/to/this/script.zsh
