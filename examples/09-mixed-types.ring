// Example 9: Mixed data types
// This example demonstrates handling various YAML data types

load "yaml.ring"

yamlString = `
# Scalars of different types
string_value: "Hello World"
number_value: 42
float_value: 3.14159
boolean_true: true
boolean_false: false
null_value: null
scientific: 1.23e-4
timestamp: 2023-01-15T10:30:00Z
# Sequences (arrays)
simple_array: [apple, banana, cherry]
number_array: [1, 2, 3, 4, 5]
mixed_array: [text, 123, true, null]
# Objects with mixed content
data_structure:
  json_like:
    name: "Complex Object"
    version: 2.3
    metadata:
      created_by: parser
      timestamp: 2023-12-01
    features: ["yaml", "arrays", "objects"]
    configuration:
      enabled: true
      rate_limit: null
      encoding: utf-8
# Special YAML nodes
empty_sequence: []
empty_mapping: {}
# Types that convert to Ring types
converted_types:
  - yaml_type: scalar
    ring_type: string
    example: normal_text
  - yaml_type: sequence
    ring_type: list
    example: [1, 2, 3]
  - yaml_type: mapping
    ring_type: list_of_lists
    example:
      property1: value1
      property2: value2
`

? "Example 9: Mixed data types in YAML"

data = yaml_load(yamlString)

if (isNull(data)) {
		? "Error loading YAML!"
		? "Last error: " + yaml_lasterror()
else
		? "Successfully loaded mixed data types"

		// Demonstrate scalar type conversion
		? "Scalar Type Conversion:"

		strVal = yaml_get(data, "string_value")
		? "  String: " + strVal + " (type: " + type(strVal) + ")"

		numVal = yaml_get(data, "number_value")
		? "  Integer: " + numVal + " (type: " + type(numVal) + ")"

		floatVal = yaml_get(data, "float_value")
		? "  Float: " + floatVal + " (type: " + type(floatVal) + ")"

		boolTrue = yaml_get(data, "boolean_true")
		? "  Boolean true: " + boolTrue + " (type: " + type(boolTrue) + ")"

		boolFalse = yaml_get(data, "boolean_false")
		? "  Boolean false: " + boolFalse + " (type: " + type(boolFalse) + ")"

		nullVal = yaml_get(data, "null_value")
		? "  Null value: " + nullVal + " (type: " + type(nullVal) + ")"

		sciVal = yaml_get(data, "scientific")
		? "  Scientific: " + sciVal + " (type: " + type(sciVal) + ")"

		// Demonstrate array types
		? "Array Collections:"

		simpleArr = yaml_get(data, "simple_array")
		? "  String array: " + print(simpleArr)

		numArr = yaml_get(data, "number_array")
		? "  Number array: " + print(numArr)

		mixedArr = yaml_get(data, "mixed_array")
		? "  Mixed array: " + print(mixedArr)

		// Demonstrate accessing complex object
		? "Complex Object Access:"

		objectName = yaml_get(data, "data_structure.json_like.name")
		objectVersion = yaml_get(data, "data_structure.json_like.version")
		objectEnabled = yaml_get(data, "data_structure.json_like.configuration.enabled")

		? "  Name: " + objectName
		? "  Version: " + objectVersion
		? "  Enabled: " + objectEnabled

		// Access features array within object
		? "  Features array: "
		features = yaml_get(data, "data_structure.json_like.features")
		if (isList(features)) {
				for feature in features {
						? "    - " + feature
				}
		}

		// Type conversion information
		? "Type Conversion Information:"

		// Get the first converted_types item which is a complex object
		firstType = yaml_get(data, "converted_types.[1]")
		if (isList(firstType)) {
				? "  First type conversion info:"
				for item in firstType {
						? "    " + item[1] + ": " + item[2]
				}
		}

		// Show how arrays are converted to lists of lists
		? "YAML to Ring List Structure:"
		// Access the example property from the nested object
		exampleObj = yaml_get(data, "converted_types.[2].example")
		if (isList(exampleObj)) {
				? "  Array as Ring list: " + print(exampleObj)
		}

		exampleMap = yaml_get(data, "converted_types.[3].example")
		if (isList(exampleMap)) {
				? "  Object as Ring list of [key,value] pairs:"
				for pair in exampleMap {
						? "    " + pair[1] + " = " + pair[2]
				}
		}
}

? nl + "Done!"