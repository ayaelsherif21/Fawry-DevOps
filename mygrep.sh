#!/bin/bash

# Function to display help information
display_help() {
    echo "Usage: mygrep.sh [OPTIONS] PATTERN [FILE]"
    echo "Search for PATTERN in FILE (case-insensitive)"
    echo ""
    echo "Options:"
    echo "  -n         show line numbers"
    echo "  -v         invert match (select non-matching lines)"
    echo "  --help     display this help and exit"
    echo ""
    echo "Combinations like -vn or -nv are supported"
}

# Initialize variables
show_line_numbers=0
invert_match=0
pattern=""
file=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        (-n)
            show_line_numbers=1
            shift
            ;;
        (-v)
            invert_match=1
            shift
            ;;
        (-nv|-vn)
            show_line_numbers=1
            invert_match=1
            shift
            ;;
        (--help)
            display_help
            exit 0
            ;;
        (-*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        (*)
            # The first non-option argument is the pattern, the second is the file
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            elif [[ -z "$file" ]]; then
                file="$1"
            else
                echo "Error: Too many arguments" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input
if [[ -z "$pattern" ]]; then
    echo "Error: Missing search pattern" >&2
    echo "Usage: mygrep.sh [OPTIONS] PATTERN [FILE]" >&2
    exit 1
fi

if [[ -z "$file" ]]; then
    echo "Error: Missing file name" >&2
    echo "Usage: mygrep.sh [OPTIONS] PATTERN [FILE]" >&2
    exit 1
fi

if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' not found" >&2
    exit 1
fi

# Perform the search
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Case-insensitive match
    if [[ "$line" =~ ${pattern,,} ]]; then
        match_found=1
    else
        match_found=0
    fi
    
    # Handle inverted match
    if (( invert_match )); then
        if (( !match_found )); then
            if (( show_line_numbers )); then
                echo "$line_number:$line"
            else
                echo "$line"
            fi
        fi
    else
        if (( match_found )); then
            if (( show_line_numbers )); then
                echo "$line_number:$line"
            else
                echo "$line"
            fi
        fi
    fi
done < "$file"