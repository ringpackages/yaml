aPackageInfo = [
	:name = "Ring YAML",
	:description = "A YAML parsing and manipulation library for the Ring programming language",
	:folder = "yaml",
	:developer = "ysdragon",
	:email = "youssefelkholey@gmail.com",
	:license = "MIT License",
	:version = "1.0.1",
	:ringversion = "1.23",
	:versions = 	[
		[
			:version = "1.0.1",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "",
			:version = "",
			:providerusername = ""
		]
	],
	:files = 	[
		"lib.ring",
		"main.ring",
		"CMakeLists.txt",
		"examples/01-basic-file-load.ring",
		"examples/01.yaml",
		"examples/02-basic-string-parse.ring",
		"examples/03-simple-data-access.ring",
		"examples/04-object-access.ring",
		"examples/05-array-access.ring",
		"examples/06-complex-nested.ring",
		"examples/07-error-handling.ring",
		"examples/08-large-data.yaml",
		"examples/08-large-file-example.ring",
		"examples/09-mixed-types.ring",
		"examples/10-advanced-paths.ring",
		"src/ring_yaml.c",
		"src/yaml.ring",
		"src/utils/color.ring",
		"src/utils/install.ring",
		"src/utils/uninstall.ring",
		"tests/test.yaml",
		"tests/YAML_test.ring",
		"README.md",
		"LICENSE"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[
		"lib/windows/i386/ring_yaml.dll",
		"lib/windows/amd64/ring_yaml.dll",
		"lib/windows/arm64/ring_yaml.dll"
	],
	:linuxfiles = 	[
		"lib/linux/amd64/libring_yaml.so",
		"lib/linux/arm64/libring_yaml.so"
	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:freebsdfiles = 	[
		"lib/freebsd/amd64/libring_yaml.so",
		"lib/freebsd/arm64/libring_yaml.so"
	],
	:macosfiles = 	[
		"lib/macos/amd64/libring_yaml.dylib",
		"lib/macos/arm64/libring_yaml.dylib"
	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = ""
]

