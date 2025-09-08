// Helper function to load a yaml source
func yaml_load(cSource) {
	if (right(cSource, 5) = ".yaml" || right(cSource, 4) = ".yml") {
		pDoc = yaml_parse_file(cSource)
	else
		pDoc = yaml_parse(cSource)
	}

	if (isNull(pDoc)) {
		return NULL
	}

	return yaml2list(pDoc)
}

// Helper function to access yaml nodes using dots (trees)
func yaml_get(aData, cPath) {
	if (!isList(aData) || !isString(cPath)) {
		return NULL
	}

	aCurrent = aData
	
	// Normalize the path so '.' is the universal separator.
	cPath = substr(cPath, "[", ".[")
	
	// Split the path into segments.
	aParts = split(cPath, ".")
	
	// Iterate through each segment and traverse the data.
	for cPart in aParts {
		cPart = trim(cPart)
		// Skip empty parts from "..", ".[" or leading/trailing dots
		if (len(cPart) = 0) {
			continue
		}

		// Check if the current segment is list index, e.g., "[1]"
		if (left(cPart, 1) = "[" && right(cPart, 1) = "]") {
			// Cannot index a non-list
			if (!isList(aCurrent)) {
				return NULL
			}
			
			// Extract the index number
			cIndex = substr(cPart, 2, len(cPart) - 2)
			nIndex = number(trim(cIndex))
			
			// Validate array bounds
			if (nIndex < 1 || nIndex > len(aCurrent)) {
				return NULL
			}
			aCurrent = aCurrent[nIndex]
			
		else
			if (!isList(aCurrent)) {
				return NULL
			}
			
			// Find the key in the list of [key, value] pairs
			nPos = find(aCurrent, cPart, 1)
			if (nPos = 0) {
				return NULL
			}
			
			// The value is the second element of the found sublist
			aCurrent = aCurrent[nPos][2]
		}
	}
	
	return aCurrent
}