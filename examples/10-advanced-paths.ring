// Example 10: Advanced path operations
// This example demonstrates advanced path handling, loops, and conditional access

load "yaml.ring"

yamlString = `
inventory:
  electronics:
    laptops:
      - model: ThinkPad X1
        price: 1499.99
        specs: {cpu: "i7", ram: 16, ssd: 512}
        in_stock: true
        variants: [carbon_black, storm_gray]
      - model: MacBook Pro
        price: 1999.99
        specs: {cpu: "M4", ram: 16, ssd: 1024}
        in_stock: false
        variants: [silver, space_gray]
      - model: Dell XPS
        price: 1299.99
        specs: {cpu: "i5", ram: 8, ssd: 256}
        in_stock: true
        variants: [white, black]
    tablets:
      - model: iPad Pro
        price: 799.99
        specs: {screen: "12.9", storage: 256}
        in_stock: true
      - model: Galaxy Tab S8
        price: 699.99
        specs: {screen: 11, storage: 128}
        in_stock: false
  books:
    programming:
      - title: "Clean Code"
        author: "Robert Martin"
        year: 2008
        rating: 4.7
        reviews: ["Great book", "Must read", "Changed my code quality"]
      - title: "The Pragmatic Programmer"
        author: "Hunt & Thomas"
        year: 1999
        rating: 4.9
        reviews: ["Classic", "Essential", "Every programmer should read"]
      - title: "Design Patterns"
        author: "Gang of Four"
        year: 1994
        rating: 4.6
        reviews: ["Fundamental", "Still relevant", "Great explanations"]
configurations:
  - environment: development
    replicas: 1
    debug: true
    features: ["hot_reload", "verbose_logging"]
  - environment: staging
    replicas: 2
    debug: false
    features: ["monitoring", "error_reporting"]
  - environment: production
    replicas: 5
    debug: false
    features: ["monitoring", "auto_scaling", "high_availability"]
`

? "Example 10: Advanced path operations and traversals"

data = yaml_load(yamlString)

if (isNull(data)) {
	? "Error loading YAML!"
else
	// Looping through array elements
	? "Traversing product catalog:"

	for i = 1 to 3 {
		laptopModel = yaml_get(data, "inventory.electronics.laptops.[" + i + "].model")
		laptopPrice = yaml_get(data, "inventory.electronics.laptops.[" + i + "].price")
		laptopStock = yaml_get(data, "inventory.electronics.laptops.[" + i + "].in_stock")

		print("  " + laptopModel + " - $" + laptopPrice)
		if (laptopStock = 1) {
			result = "in stock"
		else
			result = "out of stock"
		}
		? " ( " + result + " ) "
	}

	// Accessing nested object properties within arrays
	? "Accessing nested specs within products:"

	for i = 1 to 3 {
		path = "inventory.electronics.laptops.[" + i + "].specs.ram"
		ram = yaml_get(data, path)
		if (isNull(ram)) {
			model = yaml_get(data, "inventory.electronics.laptops.[" + (i) + "].model")
			? "  " + model + " has " + ram + "GB RAM"
		}
	}

	// Working with arrays within arrays (variants)
	? "Product variants:"

	for i = 1 to 3 {
		model = yaml_get(data, "inventory.electronics.laptops.[" + i + "].model")
		variants = yaml_get(data, "inventory.electronics.laptops.[" + i + "].variants")

		if (isList(variants)) {
			print("  " + model + " variants: ")
			for variant in variants {
				print(variant + " ")
			}
			? nl
		}
	}

	// Double nested loops (books within categories)
	? "Programming books catalog:"

	booksList = yaml_get(data, "inventory.books.programming")
	if (isList(booksList)) {
		for i = 1 to len(booksList) {
			book = booksList[i]
			if (isList(book)) {
				for j = 1 to len(book) {
					key = book[j][1]
					value = book[j][2]
					print("    " + key + ": ")
					if (isList(value)) {
						for k = 1 to len(value) {
							print(value[k])
							if (k < len(value)) {
								print(", ")
							}
						}
						? nl
					else
						? value
					}
				}
			}
		}
	}

	// Advanced path construction
	? "Advanced path operations:"

	// Build dynamic paths
	categories = ["laptops", "tablets"]
	for category in categories {
		? "Category: " + category

		// Get the list for this category
		products = yaml_get(data, "inventory.electronics." + category)

		if (isList(products)) {
			for i = 1 to len(products) {
				model = yaml_get(data, "inventory.electronics." + category + ".[1].model")
				inStock = yaml_get(data, "inventory.electronics." + category + ".[1].in_stock")
				if (inStock = 1) {
					result = "available"
				else
					result = "unavailable"
				}
				? "  " + model + " (" + result + ")"
			}
		}
	}

	// Configuration traversal
	? "Environment configurations:"

	configs = yaml_get(data, "configurations")
	if (isList(configs)) {
		for i = 1 to len(configs) {
			config = yaml_get(data, "configurations.[" + i + "]")
			if (isList(config)) {
				env = ""
				replicas = ""
				for item in config {
					if (item[1] = "environment") {
						env = item[2]
					}
					if (item[1] = "replicas") {
						replicas = item[2]
					}
				}
				? "  " + env + ": " + replicas + " replicas"
			}
		}
	}

	// Complex path combinations with conditional access
	? "Conditional path access patterns:"

	// Only show programming books with rating >= 4.7
	? "  Books with high ratings:"
	books = yaml_get(data, "inventory.books.programming")
	if (isList(books)) {
		for i = 1 to len(books) {
			bookData = books[i]
			if (isList(bookData)) {
				rating = 0
				title = ""
				for field in bookData {
					if (field[1] = "rating") {
						rating = number(field[2])
					}
					if (field[1] = "title") {
						title = field[2]
					}
				}

				if (rating >= 4.7) {
					? "    " + title + " (rating: " + rating + ")"
				}
			}
		}
	}
}

? nl + "Done!"