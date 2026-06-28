"""
analyze_scenes.py

Parses Godot scene files (.tscn / .tres) to generate a simple text representation
of their node hierarchies in a tree form using indentation, including the resolved class names and types.
Has an option (RECURSIVE_EXPANSION) to recursively expand instanced scenes and display their child nodes.
"""

import os
import re

# CONFIGURATION OPTION
# Set to True to recursively traverse and expand instanced scenes (showing all sub-children)
# Set to False to only list the instanced scene node itself as a leaf
RECURSIVE_EXPANSION = True

# Paths relative to this script
WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUTPUT_FILE = os.path.join(WORKSPACE_DIR, "scene_trees.txt")
SCENES_DIR = os.path.join(WORKSPACE_DIR, "scenes")

# Global caches
scene_info_cache = {}

def scan_gd_files(workspace_dir):
    """
    Scans all .gd files in the workspace directory and builds a dictionary
    mapping res:// paths to their declared class_name (if any).
    """
    script_to_class = {}
    class_name_pattern = re.compile(r'^\s*class_name\s+(\w+)')
    
    for root, _, files in os.walk(workspace_dir):
        if ".git" in root or ".godot" in root:
            continue
        for file in files:
            if file.endswith(".gd"):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, workspace_dir).replace("\\", "/")
                res_path = f"res://{rel_path}"
                
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        for line in f:
                            match = class_name_pattern.match(line)
                            if match:
                                script_to_class[res_path] = match.group(1)
                                break
                except Exception:
                    pass
    return script_to_class

def get_scene_root_info(scene_res_path, workspace_dir, script_to_class):
    """
    Returns (class_name, built_in_type) for the root node of a scene file.
    Resolves recursively if the root node itself is an instance of another scene.
    """
    if scene_res_path in scene_info_cache:
        return scene_info_cache[scene_res_path]
        
    file_path = os.path.join(workspace_dir, scene_res_path.replace("res://", "").replace("/", os.sep))
    if not os.path.exists(file_path):
        return None, "Node"

    ext_resources = {}
    root_node_attrs = None
    root_node_script_id = None

    ext_res_pattern = re.compile(r'^\[ext_resource\s+([^\]]+)\]')
    node_pattern = re.compile(r'^\[node\s+([^\]]+)\]')
    attr_pattern = re.compile(r'(\w+)=(?:"([^"]*)"|([^\s\]]+))')
    prop_pattern = re.compile(r'^(\w+)\s*=\s*(.+)$')

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            in_root_node = False
            for line in f:
                line = line.strip()
                
                ext_res_match = ext_res_pattern.match(line)
                if ext_res_match:
                    attr_str = ext_res_match.group(1)
                    attrs = {}
                    for match in attr_pattern.findall(attr_str):
                        key = match[0]
                        val = match[1] if match[1] else match[2]
                        attrs[key] = val
                    
                    res_id = attrs.get("id")
                    res_path = attrs.get("path")
                    if res_id and res_path:
                        ext_resources[res_id] = res_path
                    continue

                node_match = node_pattern.match(line)
                if node_match:
                    if root_node_attrs is not None:
                        break
                        
                    attr_str = node_match.group(1)
                    attrs = {}
                    for match in attr_pattern.findall(attr_str):
                        key = match[0]
                        val = match[1] if match[1] else match[2]
                        attrs[key] = val
                    
                    if attrs.get("parent") is None:
                        root_node_attrs = attrs
                        in_root_node = True
                    continue

                if in_root_node:
                    if line.startswith("["):
                        in_root_node = False
                        break
                        
                    prop_match = prop_pattern.match(line)
                    if prop_match:
                        key = prop_match.group(1)
                        val = prop_match.group(2)
                        if key == "script":
                            res_id_match = re.search(r'ExtResource\("?([^"\)]+)"?\)', val)
                            if res_id_match:
                                root_node_script_id = res_id_match.group(1)
    except Exception as e:
        print(f"Error parsing scene root for {scene_res_path}: {e}")

    class_name = None
    built_in_type = "Node"

    if root_node_attrs:
        built_in_type = root_node_attrs.get("type", "Node")
        instance_ref = root_node_attrs.get("instance")
        
        if root_node_script_id and root_node_script_id in ext_resources:
            script_path = ext_resources[root_node_script_id]
            class_name = script_to_class.get(script_path)
        elif instance_ref:
            res_id_match = re.search(r'ExtResource\("?([^"\)]+)"?\)', instance_ref)
            if res_id_match:
                res_id = res_id_match.group(1)
                instanced_scene_path = ext_resources.get(res_id)
                if instanced_scene_path:
                    class_name, built_in_type = get_scene_root_info(instanced_scene_path, workspace_dir, script_to_class)

    scene_info_cache[scene_res_path] = (class_name, built_in_type)
    return class_name, built_in_type

def load_scene_nodes(file_path):
    """
    Parses the file and returns (root_name, nodes_dict, ext_resources).
    """
    if not os.path.exists(file_path):
        return None, {}, {}

    ext_resources = {}
    nodes = {}
    root_name = None
    current_node_rel_path = None

    ext_res_pattern = re.compile(r'^\[ext_resource\s+([^\]]+)\]')
    node_pattern = re.compile(r'^\[node\s+([^\]]+)\]')
    attr_pattern = re.compile(r'(\w+)=(?:"([^"]*)"|([^\s\]]+))')
    prop_pattern = re.compile(r'^(\w+)\s*=\s*(.+)$')

    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            
            ext_res_match = ext_res_pattern.match(line)
            if ext_res_match:
                attr_str = ext_res_match.group(1)
                attrs = {}
                for match in attr_pattern.findall(attr_str):
                    key = match[0]
                    val = match[1] if match[1] else match[2]
                    attrs[key] = val
                
                res_id = attrs.get("id")
                res_path = attrs.get("path")
                if res_id and res_path:
                    ext_resources[res_id] = res_path
                continue

            node_match = node_pattern.match(line)
            if node_match:
                attr_str = node_match.group(1)
                attrs = {}
                for match in attr_pattern.findall(attr_str):
                    key = match[0]
                    val = match[1] if match[1] else match[2]
                    attrs[key] = val
                
                name = attrs.get("name")
                parent = attrs.get("parent")
                node_type = attrs.get("type")
                instance_ref = attrs.get("instance")
                
                if not name:
                    current_node_rel_path = None
                    continue

                if parent is None:
                    root_name = name
                    current_node_rel_path = ""
                else:
                    if parent == ".":
                        current_node_rel_path = name
                    else:
                        current_node_rel_path = f"{parent}/{name}"
                
                nodes[current_node_rel_path] = {
                    "name": name,
                    "type": node_type,
                    "instance": instance_ref,
                    "script_id": None,
                    "children": []
                }
                
                if parent is not None:
                    parent_rel_path = "" if parent == "." else parent
                    if parent_rel_path in nodes:
                        nodes[parent_rel_path]["children"].append(current_node_rel_path)
                continue

            if line.startswith("["):
                current_node_rel_path = None
                continue

            if current_node_rel_path is not None:
                prop_match = prop_pattern.match(line)
                if prop_match:
                    key = prop_match.group(1)
                    val = prop_match.group(2)
                    if key == "script":
                        res_id_match = re.search(r'ExtResource\("?([^"\)]+)"?\)', val)
                        if res_id_match:
                            nodes[current_node_rel_path]["script_id"] = res_id_match.group(1)

    return root_name, nodes, ext_resources

def get_merged_scene_tree(file_path, workspace_dir, script_to_class, recursive=True, visited=None):
    """
    Loads scene nodes and recursively expands instanced scenes, prefixing paths appropriately.
    Returns a dictionary of nodes keyed by their relative path in the merged tree.
    """
    if visited is None:
        visited = set()
        
    canonical_path = os.path.realpath(file_path)
    if canonical_path in visited:
        # Prevent infinite recursion in case of cyclic references (not expected in valid Godot scenes)
        return None
    visited.add(canonical_path)

    root_name, local_nodes, ext_resources = load_scene_nodes(file_path)
    if not root_name:
        return None

    merged_nodes = {}
    for rel_path, node in local_nodes.items():
        merged_nodes[rel_path] = {
            "name": node["name"],
            "type": node["type"],
            "instance": node["instance"],
            "script_id": node["script_id"],
            "ext_resources": ext_resources,
            "children": list(node["children"])
        }

    if not recursive:
        return merged_nodes

    paths_to_check = list(merged_nodes.keys())
    for rel_path in paths_to_check:
        node = merged_nodes[rel_path]
        instance_ref = node["instance"]
        if not instance_ref:
            continue
            
        res_id_match = re.search(r'ExtResource\("?([^"\)]+)"?\)', instance_ref)
        if not res_id_match:
            continue
            
        res_id = res_id_match.group(1)
        instanced_scene_res_path = node["ext_resources"].get(res_id)
        if not instanced_scene_res_path:
            continue
            
        instanced_scene_file_path = os.path.join(
            workspace_dir, instanced_scene_res_path.replace("res://", "").replace("/", os.sep)
        )
        
        # Recurse
        sub_tree = get_merged_scene_tree(
            instanced_scene_file_path, workspace_dir, script_to_class, 
            recursive=True, visited=set(visited)
        )
        if not sub_tree:
            continue
            
        for sub_rel_path, sub_node in sub_tree.items():
            if sub_rel_path == "":
                # Root node of instanced sub-scene matches the instanced node in parent scene
                if not node["type"] and sub_node["type"]:
                    node["type"] = sub_node["type"]
                if not node["script_id"] and sub_node["script_id"]:
                    node["script_id"] = sub_node["script_id"]
                    node["ext_resources"] = {**sub_node["ext_resources"], **node["ext_resources"]}
                
                # Append sub-scene root's children to this node's children list
                for sub_child_path in sub_node["children"]:
                    prefix = rel_path if rel_path != "" else ""
                    new_child_path = f"{prefix}/{sub_child_path}" if prefix else sub_child_path
                    node["children"].append(new_child_path)
            else:
                # Sub-node inside sub-scene
                prefix = rel_path if rel_path != "" else ""
                new_sub_path = f"{prefix}/{sub_rel_path}" if prefix else sub_rel_path
                
                new_children = []
                for sub_child_path in sub_node["children"]:
                    new_child_path = f"{prefix}/{sub_child_path}" if prefix else sub_child_path
                    new_children.append(new_child_path)
                    
                merged_nodes[new_sub_path] = {
                    "name": sub_node["name"],
                    "type": sub_node["type"],
                    "instance": sub_node["instance"],
                    "script_id": sub_node["script_id"],
                    "ext_resources": sub_node["ext_resources"],
                    "children": new_children
                }

    return merged_nodes

def parse_scene_file(file_path, workspace_dir, script_to_class):
    """
    Parses a Godot scene file, processes merging/recursion based on RECURSIVE_EXPANSION,
    and returns a list of formatted lines representing the node tree.
    """
    merged_nodes = get_merged_scene_tree(
        file_path, workspace_dir, script_to_class, recursive=RECURSIVE_EXPANSION
    )
    if not merged_nodes:
        return None

    # Resolve types & class names for all merged nodes
    for path, node in merged_nodes.items():
        node_type = node["type"]
        instance_ref = node["instance"]
        node_script_id = node["script_id"]
        ext_resources = node["ext_resources"]
        
        node_class_name = None
        node_built_in_type = node_type or "Node"
        node_scene_name = None

        # Resolve instanced scenes
        if instance_ref:
            res_id_match = re.search(r'ExtResource\("?([^"\)]+)"?\)', instance_ref)
            if res_id_match:
                res_id = res_id_match.group(1)
                instanced_scene_path = ext_resources.get(res_id)
                if instanced_scene_path:
                    node_scene_name = os.path.basename(instanced_scene_path)
                    node_class_name, node_built_in_type = get_scene_root_info(
                        instanced_scene_path, workspace_dir, script_to_class
                    )

        # Resolve script attachment
        if node_script_id and node_script_id in ext_resources:
            script_path = ext_resources[node_script_id]
            node_class_name = script_to_class.get(script_path)

        # Build formatting parts
        parts = []
        if node_class_name:
            parts.append(node_class_name)
            if node_scene_name:
                parts.append(node_scene_name)
            else:
                parts.append(node_built_in_type)
        else:
            if node_scene_name:
                parts.append(node_scene_name)
            else:
                parts.append(node_built_in_type)

        node["resolved_type"] = ", ".join(parts)

    # Recursively format the tree starting from the root node (path "")
    formatted_lines = []
    
    def format_node(path, depth=0):
        if path not in merged_nodes:
            return
        node = merged_nodes[path]
        indent = "  " * depth
        formatted_lines.append(f"{indent}{node['name']} ({node['resolved_type']})")
        for child_path in node["children"]:
            format_node(child_path, depth + 1)

    format_node("", 0)
    return formatted_lines

def main():
    print("Scanning scripts for class names...")
    script_to_class = scan_gd_files(WORKSPACE_DIR)
    print(f"Found {len(script_to_class)} script classes.")

    print(f"Scanning scenes directory (RECURSIVE_EXPANSION = {RECURSIVE_EXPANSION})...")
    scene_files = []
    for root, _, files in os.walk(SCENES_DIR):
        for file in files:
            if file.endswith(".tscn") or file.endswith(".tres"):
                scene_files.append(os.path.join(root, file))

    output_lines = []
    for file_path in sorted(scene_files):
        scene_tree = parse_scene_file(file_path, WORKSPACE_DIR, script_to_class)
        if scene_tree is None:
            continue
            
        rel_path = os.path.relpath(file_path, os.path.dirname(SCENES_DIR))
        print(f"Processing {rel_path}...")
        
        scene_path_str = rel_path.replace("/", "\\")
        output_lines.append(f"#region {scene_path_str}")
        output_lines.extend(scene_tree)
        output_lines.append("#endregion")
        output_lines.append("") # empty line separator

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))
    
    print(f"Output generated successfully at {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
