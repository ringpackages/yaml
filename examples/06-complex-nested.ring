// Example 6: Complex nested structures
// This example shows complex combinations of objects and arrays

load "yaml.ring"

yamlString = "
library:
  name: Central Library
  books:
    - title: Programming Fundamentals
      author:
        first: John
        last: Smith
      genre: Computer Science
      tags: [programming, textbook, beginner]
      ratings:
        average: 4.5
        reviews:
          - user: alice123
            rating: 5
            comment: Perfect for beginners!
          - user: bob_dev
            rating: 4
            comment: Good coverage but needs updates
          - user: charlie
            rating: 5
            comment: Clear explanations
    - title: Advanced Algorithm Design
      author:
        first: Sarah
        last: Johnson
      genre: Computer Science
      tags: [algorithms, advanced, textbook]
      ratings:
        average: 4.7
        reviews:
          - user: expert42
            rating: 5
            comment: Excellent coverage of P vs NP
          - user: algorithms_lover
            rating: 4
            comment: Comprehensive but dense
  members:
    - id: 1001
      personalInfo:
        name: Mike Brown
        subscription:
          type: Premium
          start_date: 2023-01-15
      borrowed_books:
        - book_id: B001
          due_date: 2023-12-01
        - book_id: B003
          due_date: 2023-12-10
"

? "Example 6: Complex nested structures"

data = yaml_load(yamlString)

if (isNull(data)) {
	? "Error loading YAML!"
else
	// Access deeply nested values
	? nl + "Deep object traversal:"

	libraryName = yaml_get(data, "library.name")
	? "Library: " + libraryName

	// Access first book's author info
	firstBookTitle = yaml_get(data, "library.books.[1].title")
	firstAuthorFirst = yaml_get(data, "library.books.[1].author.first")
	firstAuthorLast = yaml_get(data, "library.books.[1].author.last")

	? "First book author: " + firstAuthorFirst + " " + firstAuthorLast

	// Access array within object within array
	? "Array within nested objects:"

	secondBookTitle = yaml_get(data, "library.books.[2].title")
	? "Second book title: " + secondBookTitle

	// Access tags array within the second book
	tag1 = yaml_get(data, "library.books.[2].tags.[1]")
	tag2 = yaml_get(data, "library.books.[2].tags.[2]")
	? "Tags: " + tag1 + ", " + tag2

	// Access user reviews within ratings
	? nl + "Deeply nested user reviews:"

	reviewUser = yaml_get(data, "library.books.[1].ratings.reviews.[1].user")
	reviewRating = yaml_get(data, "library.books.[1].ratings.reviews.[1].rating")
	reviewComment = yaml_get(data, "library.books.[1].ratings.reviews.[1].comment")

	? "First review - User: " + reviewUser + ", Rating: " + reviewRating
	? "Comment: " + reviewComment

	// Access member information
	? nl + "Member information access:"

	memberName = yaml_get(data, "library.members.[1].personalInfo.name")
	membershipType = yaml_get(data, "library.members.[1].personalInfo.subscription.type")

	? "Member: " + memberName
	? "Membership: " + membershipType

	// Access borrowed books (array within member)
	borrowedBookDue = yaml_get(data, "library.members.[1].borrowed_books.[1].due_date")
	? "First borrowed book due date: " + borrowedBookDue
}

? nl + "Done!"