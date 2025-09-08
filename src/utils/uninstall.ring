// This file is part of the Ring YAML library.
// It provides functionality to remove the library files and clean up the environment.

load "stdlibcore.ring"

cPathSep = "/"

if (isWindows()) {
	cPathSep = "\\"
}

// Remove the yaml.ring file from the load directory
remove(exefolder() + "load" + cPathSep + "yaml.ring")

// Remove the yaml.ring file from the Ring2EXE libs directory
remove(exefolder() + ".." + cPathSep + "tools" + cPathSep + "ring2exe" + cPathSep + "libs" + cPathSep + "yaml.ring")

// Change current directory to the samples directory
chdir(exefolder() + ".." + cPathSep + "samples")

// Remove the UsingYAML directory if it exists
if (direxists("UsingYAML")) {
	OSDeleteFolder("UsingYAML")
}