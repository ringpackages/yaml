arch = getarch()
if (isWindows()) {
	if (arch = "x64") {
		loadlib("../lib/windows/amd64/ring_yaml.dll")
	elseif (arch = "arm64")
		loadlib("../lib/windows/arm64/ring_yaml.dll")
	elseif (arch = "x86")
		loadlib("../lib/windows/i386/ring_yaml.dll")
	}
elseif (isLinux())
	if (arch = "x64") {
		loadlib("../lib/linux/amd64/libring_yaml.so")
	elseif (arch = "arm64")
		loadlib("lib/linux/arm64/libring_yaml.so")
	}
elseif (isFreeBSD())
	if (arch = "x64") {
		loadlib("../lib/freebsd/amd64/libring_yaml.so")
	elseif (arch = "arm64")
		loadlib("../lib/freebsd/arm64/libring_yaml.so")
	}
elseif (isMacOSX())
	if (arch = "x64") {
		loadlib("../lib/macos/amd64/libring_yaml.dylib")
	elseif (arch = "arm64")
		loadlib("../lib/macos/arm64/libring_yaml.dylib")
	}
else
	raise("Unsupported OS! You need to build the library for your OS.")
}

load "stdlibcore.ring"
load "../src/yaml.ring"

func main() {
	oTester = new YamlTest()
	oTester.runAllTests()
}

class YamlTest {
	cTestFile = "test.yaml"
	aYamlList

	nTestsRun = 0
	nTestsFailed = 0

	func init() {
		? "Attempting to parse file: " + cTestFile
		aYamlList = yaml_load(cTestFile)
		if (isNull(aYamlList)) {
			? "Failed to parse YAML file. Error: " + yaml_lasterror()
			raise("Prerequisite Failed: Could not parse the test file '" + cTestFile + "'. Error: " + yaml_lasterror())
		}
		? "Successfully parsed YAML file and converted to list."
	}

	func assert(condition, message) {
		if (!condition) {
			raise("Assertion Failed: " + message)
		}
	}

	func run(testName, methodName) {
		nTestsRun++
		see "  " + testName + "..."
		try {
			call methodName()
			see " [PASS]" + nl
		catch
			nTestsFailed++
			see " [FAIL]" + nl
			see "    -> " + cCatchError + nl
		}
	}

	func runAllTests() {
		? "========================================"
		? "  Running YAML Extension Test Suite"
		? "========================================" + nl

		? nl + "Testing Basic Parsing..."
		run("test_parse_file", "test_parse_file")
		run("test_parse_string", "test_parse_string")
		run("test_error_handling", "test_error_handling")

		? nl + "Testing Data Access..."
		run("test_get_simple_values", "test_get_simple_values")
		run("test_get_nested_map", "test_get_nested_map")
		run("test_get_sequence", "test_get_sequence")
		run("test_get_sequence_of_maps", "test_get_sequence_of_maps")
		run("test_get_multiline_string", "test_get_multiline_string")
		run("test_merge_key", "test_merge_key")

		? "========================================"
		? "Test Summary:"
		? "  Total Tests: " + nTestsRun
		? "  Passed: " + (nTestsRun - nTestsFailed)
		? "  Failed: " + nTestsFailed
		? "========================================"
		if (!nTestsFailed) {
			? "SUCCESS: All tests passed!"
		else
			? "FAILURE: Some tests did not pass."
		}
	}

	func test_parse_file() {
		assert(islist(aYamlList), "Result from file parse should be a list.")
		assert(len(aYamlList) > 0, "Parsed list should not be empty.")
	}

	func test_parse_string() {
		cYamlStr = 'key: "value"'
		aData = yaml_load(cYamlStr)
		assert(islist(aData), "yaml_load on string should return a list.")
		assert(aData[1][1] = "key" && aData[1][2] = "value", "Parsed string content is incorrect.")
	}

	func test_error_handling() {
		aBadData = yaml_load("nonexistent.yaml")
		assert(isnull(aBadData), "Parsing a non-existent file should return NULL.")
		assert(len(yaml_lasterror()) > 0, "yaml_lasterror() should have a message after failure.")
	}

	func test_get_simple_values() {
		cAuthor = aYamlList[:author]
		assert(cAuthor = "Test User", "Should retrieve a top-level string.")

		cAuthor = yaml_get(aYamlList, "author")
		assert(cAuthor = "Test User", "Should retrieve a top-level string.")
		
		nVersion = aYamlList[:version]
		assert(nVersion = 1.2, "Should retrieve a number.")

		nVersion = yaml_get(aYamlList, "version")
		assert(nVersion = 1.2, "Should retrieve a number.")

		isActive = aYamlList[:is_active]
		assert(isActive = True, "Should retrieve a boolean.")

		isActive = yaml_get(aYamlList, "is_active")
		assert(isActive = True, "Should retrieve a boolean.")
	}
	
	func test_get_nested_map() {
		cRole = aYamlList[:database][:user][:role]
		assert(cRole = "admin", "Should get nested values from maps.")

		cRole = yaml_get(aYamlList, "database.user.role")
		assert(cRole = "admin", "Should get nested values from maps.")
	}

	func test_get_sequence() {
		aPorts = aYamlList[:database][:ports]
		assert(islist(aPorts), "Should return a list for a sequence.")
		assert(len(aPorts) = 3, "Sequence should have 3 items.")
		assert(aPorts[2] = 8002, "Should get item by index from a sequence.")

		aPorts = yaml_get(aYamlList, "database.ports")
		assert(islist(aPorts), "Should return a list for a sequence.")
		assert(len(aPorts) = 3, "Sequence should have 3 items.")
		assert(aPorts[2] = 8002, "Should get item by index from a sequence.")
	}

	func test_get_sequence_of_maps() {
		aProducts = aYamlList[:products]
		assert(islist(aProducts), "Should return a list for a sequence of maps.")
		assert(len(aProducts) = 2, "Sequence of maps should have 2 items.")

		cProductName = aProducts[2][:name]
		assert(cProductName = "Nail", "Should get nested value from a sequence of maps.")

		aProducts = yaml_get(aYamlList, "products")
		assert(islist(aProducts), "Should return a list for a sequence of maps.")
		assert(len(aProducts) = 2, "Sequence of maps should have 2 items.")

		cProductName = yaml_get(aProducts[2], "name")
		assert(cProductName = "Nail", "Should get nested value from a sequence of maps.")
	}

	func test_get_multiline_string() {
		cDesc = aYamlList[:description]
		assert(substr(cDesc, "multi-line"), "Should correctly handle multi-line strings.")

		cDesc = yaml_get(aYamlList, "description")
		assert(substr(cDesc, "multi-line"), "Should correctly handle multi-line strings.")
	}

	func test_merge_key() {
		cAdapter = aYamlList[:development][:adapter]
		nPort = aYamlList[:development][:port]
		assert(cAdapter = "postgres" && nPort = 5432, "Merge key functionality should work correctly.")

		cAdapter = yaml_get(aYamlList, "development.adapter")
		nPort = yaml_get(aYamlList, "development.port")
		assert(cAdapter = "postgres" && nPort = 5432, "Merge key functionality should work correctly.")
	}
}