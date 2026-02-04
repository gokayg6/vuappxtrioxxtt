
import re

def find_duplicates(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    current_dict = None
    seen_keys = {}
    duplicates = []

    # Regex to identify dictionary start: static let en: [String: String] = [
    dict_start_pattern = re.compile(r'static let (\w+): \[String: String\] = \[')
    # Regex to identify keys: "Key": "Value",
    key_pattern = re.compile(r'^\s*"([^"]+)"\s*:')

    for line_num, line in enumerate(lines, 1):
        # Check for dictionary start
        match = dict_start_pattern.search(line)
        if match:
            current_dict = match.group(1)
            seen_keys = {}
            print(f"Found dictionary: {current_dict} at line {line_num}")
            continue

        # Check for dictionary end (simplified, assuming ] is on its own line or end of block)
        if current_dict and line.strip().startswith(']'):
            print(f"End of dictionary: {current_dict} at line {line_num}")
            current_dict = None
            continue

        if current_dict:
            key_match = key_pattern.search(line)
            if key_match:
                key = key_match.group(1)
                if key in seen_keys:
                    duplicates.append((current_dict, key, line_num, seen_keys[key]))
                else:
                    seen_keys[key] = line_num

    if duplicates:
        print("\nFound duplicates:")
        for dict_name, key, current_line, prev_line in duplicates:
            print(f"Dictionary '{dict_name}': Key '{key}' DUPLICATED at line {current_line} (first seen at {prev_line})")
    else:
        print("\nNo duplicates found!")

if __name__ == "__main__":
    find_duplicates("/Users/gokaygulustan/Desktop/vibeuu/VibeU/VibeU/App/AppState.swift")
