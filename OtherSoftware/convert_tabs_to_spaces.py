"""
convert_tabs_to_spaces.py

Recursively scans the workspace for GDScript (.gd) files and replaces all tab characters (\\t)
with 4 spaces to standardize indentation.
"""

import os

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def convert_tabs_to_spaces(workspace_dir):
    print(f"Scanning for GDScript files in: {workspace_dir}")
    modified_count = 0
    total_count = 0

    for root, _, files in os.walk(workspace_dir):
        # Skip internal editor or version control directories
        if ".git" in root or ".godot" in root:
            continue
            
        for file in files:
            if file.endswith(".gd"):
                total_count += 1
                file_path = os.path.join(root, file)
                
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                        
                    if "\t" in content:
                        # Replace tabs with 4 spaces
                        new_content = content.replace("\t", "    ")
                        
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(new_content)
                            
                        rel_path = os.path.relpath(file_path, workspace_dir)
                        print(f"Converted tabs to spaces in: {rel_path}")
                        modified_count += 1
                except Exception as e:
                    print(f"Error processing {file}: {e}")

    print(f"\nScan complete. Processed {total_count} files, updated {modified_count} files.")

if __name__ == "__main__":
    convert_tabs_to_spaces(WORKSPACE_DIR)
