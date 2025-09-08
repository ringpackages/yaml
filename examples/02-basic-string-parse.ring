// Example 2: Loading YAML from string
// This example demonstrates loading YAML directly from a string

load "yaml.ring"

yamlString = "
product: Laptop
specs:
  processor: i7
  memory: 16GB
  storage: 512GB
price: 1299.99
available: true
"

? "Loading YAML from string..."

data = yaml_load(yamlString)

if (isNull(data)) {
    ? "Error parsing YAML string!"
    ? "Last error: " + yaml_lasterror()
else
    ? "Successfully parsed YAML string!"

    // Show structure
    ? "Parsed structure:"
    for item in data {
		if (isList(item[2])) {
			for subitem in item[2] {
				? "  " + subitem[1] + " = " + subitem[2]
			}
		else
			? "  " + item[1] + " = " + item[2]
		}
        
	}
}

? nl + "Done!"