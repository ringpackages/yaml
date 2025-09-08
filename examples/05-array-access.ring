// Example 5: Accessing arrays
// This example shows how to access values in arrays using bracket notation

load "yaml.ring"

yamlString = "
shopping_list:
  - Milk
  - Bread
  - Eggs
  - Cheese
shopping_cart:
  - name: Apple
    price: 0.99
    quantity: 6
  - name: Banana
    price: 0.59
    quantity: 4
  - name: Orange
    price: 1.29
    quantity: 5
students:
  - name: Alice
    age: 20
    grades: [85, 90, 88]
  - name: Bob
    age: 22
    grades: [92, 87, 91]
  - name: Carol
    age: 19
    grades: [90, 93, 89]
"

? "Example 5: Accessing array elements"

data = yaml_load(yamlString)

if (isNull(data)) {
	? "Error loading YAML!"
else
	// Access simple array elements
	? nl + "Simple array access:"
	item1 = yaml_get(data, "shopping_list.[1]")
	? "First item: " + item1

	item2 = yaml_get(data, "shopping_list.[2]")
	? "Second item: " + item2

	item3 = yaml_get(data, "shopping_list.[3]")
	? "Third item: " + item3

	// Access object arrays (shopping cart)
	? nl + "Object array access:"

	appleName = yaml_get(data, "shopping_cart.[1].name")
	applePrice = yaml_get(data, "shopping_cart.[1].price")
	? "First item: " + appleName + " ($" + applePrice + ")"

	bananaQty = yaml_get(data, "shopping_cart.[2].quantity")
	? "Banana quantity: " + bananaQty

	// Access nested arrays in objects
	? nl + "Nested array within object:"

	aliceGrade2 = yaml_get(data, "students.[1].grades.[2]")
	? "Alice's second grade: " + aliceGrade2

	bobName = yaml_get(data, "students.[2].name")
	bobGrade1 = yaml_get(data, "students.[2].grades.[1]")
	? "Bob's name: " + bobName + ", first grade: " + bobGrade1
}

? nl + "Done!"