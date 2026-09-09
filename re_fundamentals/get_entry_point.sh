#!/bin/bash
#
# get_entry_point.sh
# Extracts and displays ELF header information (Magic Number, Class,
# Byte Order, Entry Point Address) from a given ELF file.
#
# Usage: ./get_entry_point.sh <elf_file>

# Directory of this script, so messages.sh is found regardless of
# where the script is called from (relative paths, no hardcoding).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/messages.sh"

# --- Argument check ---
if [ $# -ne 1 ]; then
    echo "Usage: $0 <elf_file>"
    exit 1
fi

file_name="$1"

# --- Existence check ---
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

# --- Validity check: is it actually an ELF file? ---
if ! file "$file_name" | grep -q "ELF"; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

# --- Extract fields from readelf -h output ---
header_output="$(readelf -h "$file_name")"

# Trim leading/trailing whitespace without xargs (readelf's endianness
# text contains an apostrophe, which breaks xargs word-splitting).
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

magic_number="$(od -An -tx1 -N16 "$file_name" | tr -s ' ' | tr '[:lower:]' '[:upper:]' | tr -d '\n' | sed 's/^ *//')"

class="$(trim "$(echo "$header_output" | grep "Class:" | awk -F':' '{print $2}')")"

byte_order="$(trim "$(echo "$header_output" | grep "Data:" | awk -F':' '{print $2}')")"

entry_point_address="$(trim "$(echo "$header_output" | grep "Entry point address:" | awk -F':' '{print $2}')")"

# --- Display formatted output ---
display_elf_header_info
