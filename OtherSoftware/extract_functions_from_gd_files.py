import os

def extract_functions_from_gd(folder_path, output_file):
    results = []

    for root, _, files in os.walk(folder_path):
        for filename in files:
            if filename.endswith(".gd"):
                full_path = os.path.join(root, filename)
                functions = []

                with open(full_path, "r", encoding="utf-8") as f:
                    for line in f:
                        stripped = line.lstrip()
                        if stripped.startswith("func "):
                            functions.append(stripped.rstrip())

                results.append((filename, functions))

    # Write output
    with open(output_file, "a", encoding="utf-8") as out:
        for filename, funcs in results:
            out.write(f"{filename}\n")
            for func in funcs:
                out.write(f"  {func}\n")
            out.write("\n")


# Example usage:
extract_functions_from_gd("C:/Users/Isaac/Documents/GitHub/transarctica-2/scripts", "C:/Users/Isaac/Documents/GitHub/transarctica-2/functions.txt")