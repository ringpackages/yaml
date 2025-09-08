// Example 1: Basic file loading
// This example demonstrates loading a YAML file and displaying the data

load "yaml.ring"

? "Loading YAML from file: 01.yaml"

data = yaml_load("01.yaml")

if (isNull(data)) {
    print("Error loading YAML file!\n")
    print("Last error: " + yaml_lasterror() + "\n")
else
    ? "Successfully loaded YAML data!"
    ? "Data: "
	? data

    // The data is returned as a list of [key, value] pairs
    print("Accessing individual values:\n")
    for item in data {
        ? "  " + item[1] + " = " + item[2]
	}
}

? nl + "Done!"