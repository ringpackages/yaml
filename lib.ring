// Load Ring YAML library
if (isWindows()) {
      loadlib("ring_yaml.dll")
elseif (isLinux() || isFreeBSD())
      loadlib("libring_yaml.so")
elseif (isMacOSX())
      loadlib("libring_yaml.dylib")
else
      raise("Unsupported OS! You need to build the library for your OS.")
}

// Load StdLibCore
load "stdlibcore.ring"

// Load Ring YAML
load "src/yaml.ring"