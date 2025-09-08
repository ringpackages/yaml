// Example 4: Accessing nested objects
// This example shows how to access values in nested object structures

load "yaml.ring"

yamlString = "
company:
  name: TechCorp
  location:
    city: San Francisco
    state: CA
    address: 123 Tech Street
  employees: 250
  departments:
    engineering:
      head: Sarah Chen
      count: 50
    sales:
      head: Mike Wilson
      count: 30
    hr:
      head: Emma Davis
      count: 10
"

? "Example 4: Accessing nested object values"

data = yaml_load(yamlString)

if (isNull(data)) {
	? "Error loading YAML!"
else
	// Access nested values using dot notation
	? "Dot notation access:"

	companyName = yaml_get(data, "company.name")
	? "Company Name: " + companyName

	city = yaml_get(data, "company.location.city")
	? "City: " + city

	state = yaml_get(data, "company.location.state")
	? "State: " + state

	address = yaml_get(data, "company.location.address")
	? "Address: " + address

	// Access department heads
	engHead = yaml_get(data, "company.departments.engineering.head")
	salesHead = yaml_get(data, "company.departments.sales.head")
	hrHead = yaml_get(data, "company.departments.hr.head")

	? "Department Heads:"
	? "  Engineering: " + engHead
	? "  Sales: " + salesHead
	? "  HR: " + hrHead

	// Access department counts
	engCount = yaml_get(data, "company.departments.engineering.count")
	totalCount = yaml_get(data, "company.employees")

	? "Employee counts:"
	? "  Engineering: " + engCount
	? "  Total: " + totalCount

	? "Full nested structure:"
	? list2code(data)
}

? nl + "Done!"