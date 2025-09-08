// Example 3: Simple data access using yaml_get
// This example shows how to access specific values from the YAML data

load "yaml.ring"

yamlString = "
employee:
  name: Mohamed Ahmed
  department: Engineering
  salary: 75000
  active: true
  manager: Ahmed Khaled
"

? "Example 3: Accessing specific YAML values"

data = yaml_load(yamlString)

if (isNull(data)) {
	? "Error loading YAML!"
else
	// Access specific values using yaml_get function
	? "Using yaml_get to access values:"

	// Simple top-level values
	name = yaml_get(data, "employee.name")
	department = yaml_get(data, "employee.department")
	salary = yaml_get(data, "employee.salary")
	active = yaml_get(data, "employee.active")

	? "Direct access:"
	? "  Name: " + name
	? "  Department: " + department
	? "  Salary: " + salary
	? "  Active: " + active

	// Try to access a value that doesn't exist
	missing = yaml_get(data, "nonexistent")
	if (isNull(missing)) {
		? "Value 'nonexistent' correctly returned NULL (not found)"
	else
		? "This shouldn't happen!"
	}
}

? nl + "Done!"
