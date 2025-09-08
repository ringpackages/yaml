/*
	Ring YAML Library Install Script
	----------------------------------
	This script installs the Ring YAML library for the current platform.
	It detects the OS and architecture, then copies or symlinks the library to the 
	appropriate system location.
*/

load "stdlibcore.ring"
load "src/utils/color.ring"

// Default library settings
cLibPrefix = "lib"
cPathSep = "/"

// Platform detection and configuration
switch (true) {
	case isWindows()
		cLibPrefix = ""
		cPathSep = "\\"
		cLibExt = ".dll"
		cOSName = "windows"
	case isLinux()
		cLibExt = ".so"
		cOSName = "linux"
	case isFreeBSD()
		cLibExt = ".so"
		cOSName = "freebsd"
	case isMacOSX()
		cLibExt = ".dylib"
		cOSName = "macos"
	else
		? colorText([:text = "Error: Unsupported operating system detected!", :color = :BRIGHT_RED, :style = :BOLD])
		return
}

// Get system architecture
cArchName = getarch()
switch (cArchName) {
	case "x86"
		cArchName = "i386"
	case "x64"
		cArchName = "amd64"
	case "arm64"
		cArchName = "arm64"
	else
		? colorText([:text = "Error: Unsupported architecture: " + cArchName, :color = :BRIGHT_RED, :style = :BOLD])
		return
}

// Construct the package path
cPackagePath = exefolder() + ".." + cPathSep + "tools" + cPathSep + "ringpm" + cPathSep + "packages" + cPathSep + "yaml"

// Construct the library path
cLibPath = cPackagePath + cPathSep + "lib" + cPathSep + 
		cOSName + cPathSep + cArchName + cPathSep + cLibPrefix + "ring_yaml" + cLibExt

// Verify library exists
if (!fexists(cLibPath)) {
	? colorText([:text = "Error: YAML library not found!", :color = :BRIGHT_RED, :style = :BOLD])
	? colorText([:text = "Expected location: ", :color = :YELLOW]) + colorText([:text = cLibPath, :color = :CYAN])
	? colorText([:text = "Please ensure the library is built for your platform (" + cOSName + "/" + cArchName + ")", :color = :BRIGHT_MAGENTA])
	? colorText([:text = "You can refer to README.md for build instructions: ", :color = :CYAN]) + colorText([:text = cPackagePath + cPathSep + "README.md", :color = :YELLOW])
	return
}

// Install library based on platform
try {
	if (isWindows()) {
		systemSilent("copy /y " + '"' + cLibPath + '" "' + exefolder() + '"')
	else
		cLibDir = exefolder() + ".." + cPathSep + "lib"
		if (isFreeBSD() || isMacOSX()) {
			cDestDir = "/usr/local/lib"
		elseif (isLinux())
			cDestDir = "/usr/lib"
		}
		cCommand1 = 'ln -sf "' + cLibPath + '" "' + cLibDir + '"'
		cCommand2 = 'which sudo >/dev/null 2>&1 && sudo ln -sf "' + cLibPath + '" "' + cDestDir + 
				'" || (which doas >/dev/null 2>&1 && doas ln -sf "' + cLibPath + '" "' + cDestDir + 
				'" || ln -sf "' + cLibPath + '" "' + cDestDir + '")'
		system(cCommand1)
		system(cCommand2)
	}

	// Copy examples to the samples/UsingYAML directory
	cCurrentDir = currentdir()
	cExamplesPath = cPackagePath + cPathSep + "examples"
	cSamplesPath = exefolder() + ".." + cPathSep + "samples" + cPathSep + "UsingYAML"

	// Ensure the samples directory exists and create it if not
	if (!direxists(exefolder() + ".." + cPathSep + "samples")) {
		makeDir(exefolder() + ".." + cPathSep + "samples")
	}

	// Delete the UsingYAML directory if it exists 
	if (direxists(cSamplesPath)) {
		remove(cSamplesPath)
	}

	// Create the UsingYAML directory
	makeDir(cSamplesPath)

	// Change to the samples directory
	chdir(cSamplesPath)

	// Loop through the examples and copy them to the samples directory
	for item in dir(cExamplesPath) {
		if (item[2]) {
			OSCopyFolder(cExamplesPath + cPathSep, item[1])
		else
			OSCopyFile(cExamplesPath + cPathSep + item[1])
		}
	}
	
	// Change back to the original directory
	chdir(cCurrentDir)

	// Check if yaml.ring exists in the exefolder
	if (fexists(exefolder() + "yaml.ring")) {
		// Remove the existing yaml.ring file
		remove(exefolder() + "yaml.ring")

		// Write the load command to the yaml.ring file
		write(exefolder() + "load" + cPathSep + "yaml.ring", `load "/../../tools/ringpm/packages/yaml/lib.ring"`)
	}
	
	// Ensure the Ring2EXE libs directory exists
	if (direxists(exefolder() + ".." + cPathSep + "tools" + cPathSep + "ring2exe" + cPathSep + "libs")) {
		// Write the library definition to the yaml.ring file for Ring2EXE
		write(exefolder() + ".." + cPathSep + "tools" + cPathSep + "ring2exe" + cPathSep + "libs" + cPathSep + "yaml.ring", getRing2EXEContent())
	}
	
	? colorText([:text = "Successfully installed Ring YAML!", :color = :BRIGHT_GREEN, :style = :BOLD])
	? colorText([:text = "You can refer to samples in: ", :color = :CYAN]) + colorText([:text = cSamplesPath, :color = :YELLOW])
	? colorText([:text = "Or in the package directory: ", :color = :CYAN]) + colorText([:text = cExamplesPath, :color = :YELLOW])
catch
	? colorText([:text = "Error: Failed to install Ring YAML!", :color = :BRIGHT_RED, :style = :BOLD])
	? colorText([:text = "Details: ", :color = :YELLOW]) + colorText([:text = cCatchError, :color = :CYAN])
}


func getRing2EXEContent() {
	return `aLibrary = [:name = :yaml,
	 :title = "YAML",
	 :windowsfiles = [
		"ring_yaml.dll"
	 ],
	 :linuxfiles = [
		"libring_yaml.so"
	 ],
	 :macosxfiles = [
		"libring_yaml.dylib"
	 ],
	 :freebsdfiles = [
		"libring_yaml.so"
	 ],
	 :ubuntudep = "",
	 :fedoradep = "",
	 :macosxdep = "",
	 :freebsddep = ""
	]`
}