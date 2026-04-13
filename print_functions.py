def print_lines_starting_with(filename, prefix):
    with open(filename, "r") as f:
        for line in f:
            if line.lstrip().startswith(prefix):
                print(line.rstrip())

# Example usage:
print_lines_starting_with("scripts/combat_scene.gd", "@onready var")