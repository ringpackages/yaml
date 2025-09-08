// Example 7: Error handling
// This example demonstrates various error scenarios and how to handle them

load "yaml.ring"

? "Example 7: Error handling scenarios"

// Invalid YAML string
invalidString = "
person:
  name: John
  age: 30
  : invalid_syntax  # Missing key before colon
"

? "Testing invalid YAML syntax:"
? "Invalid YAML: "
? invalidString

data = yaml_load(invalidString)
if (isNull(data)) {
	? "Expected error: " + yaml_lasterror()
else
	? "Unexpected success!"
}

// Missing file
? "Testing with non-existent file:"
data = yaml_load("nonexistent.yaml")
if (isNull(data)) {
	? "Expected error: " + yaml_lasterror()
else
	? "Unexpected success!"
}

// Valid YAML but accessing non-existent paths
validString = "
config:
  database:
    host: localhost
    port: 5432
  api:
    endpoints: [/api/v1, /api/v2]
"

? "Testing valid YAML but invalid path access:"
? validString

data = yaml_load(validString)
if (isNull(data)) {
	? "Unexpected error: " + yaml_lasterror()
else
	? "YAML loaded successfully"

	// Try accessing non-existent top-level key
	missingTopLevel = yaml_get(data, "server")
	if (isNull(missingTopLevel)) {
		? "Expected: 'server' key not found"
	else
		? "Unexpected success accessing missing key"
	}

	// Try accessing non-existent nested key
	missingNested = yaml_get(data, "database.username")
	if (isNull(missingNested)) {
		? "Expected: 'database.username' not found"
	else
		? "Unexpected success accessing missing nested key"
	}

	// Try accessing array index out of bounds
	outOfBounds = yaml_get(data, "api.endpoints.[10]")
	if (isNull(outOfBounds)) {
		? "Expected: Index 10 out of bounds"
	else
		? "Unexpected success with out-of-bounds index"
	}

	// Valid accesses for comparison
	validHost = yaml_get(data, "config.database.host")
	? "Valid access: database.host = " + validHost

	validEndpoint1 = yaml_get(data, "config.api.endpoints.[1]")
	? "Valid access: api.endpoints.1 = " + validEndpoint1
}

// Mixed valid and invalid paths
? nl + "Demonstrating safe path traversal:"

// If any part of the path is invalid, the whole path returns NULL
? "These paths return NULL:"
for path in ["invalid_path", "config.invalid_key", "config.database.invalid_property", "config.api.endpoints.[100]"] {
	result = yaml_get(data, path)
	if (isNull(result)) {
		result = "NULL"
	}
	? "  '" + path + "' -> " + result
}

? nl + "Done!"