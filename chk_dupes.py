import re

file_path = '/Users/gokaygulustan/Desktop/vibeuu/VibeU/VibeU/App/AppState.swift'

with open(file_path, 'r') as f:
    content = f.read()

# Regex to find dictionaries
# static let en: [String: String] = [ ... ]
dicts = re.findall(r'static let (\w+): \[String: String\] = \[(.*?)\]', content, re.DOTALL)

for lang, body in dicts:
    print(f"Checking {lang}...")
    # Extract keys
    # Key is "Key": "Value"
    # match "Key"
    # Be careful with escaped quotes if any, though simple regex might suffice for this file
    keys = re.findall(r'^\s*"([^"]+)"\s*:', body, re.MULTILINE)
    
    seen = set()
    dupes = set()
    for k in keys:
        if k in seen:
            dupes.add(k)
        else:
            seen.add(k)
    
    if dupes:
        print(f"Found {len(dupes)} duplicates in {lang}:")
        for d in dupes:
            print(f"  - {d}")
    else:
        print(f"No duplicates in {lang}")
