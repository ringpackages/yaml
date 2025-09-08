# Ring YAML

[license]: https://img.shields.io/github/license/ysdragon/yaml?style=for-the-badge&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc
[![][license]](https://github.com/ysdragon/yaml/blob/master/LICENSE)

An easy-to-use YAML parsing and manipulation library for the Ring programming language. This library is built as a wrapper around the [`libyaml`](https://github.com/yaml/libyaml) C library.

## ✨ Features

-   **Load YAML Data**: Effortlessly load YAML data from files or directly from strings.
-   **Complex Data Structures**: Seamlessly parse intricate and deeply nested YAML structures.
-   **Intuitive Data Access**: Access your data with ease using dot notation via the `yaml_get` function.
-   **Cross-Platform Compatibility**: Works flawlessly across Windows, Linux, macOS, and FreeBSD.

## 📋 Prerequisites

-   **Ring Language**: Ensure you have Ring version 1.23 or higher installed. You can download it from the [official Ring website](https://ring-lang.github.io/download.html).

## 🚀 Installation

### Using RingPM

The recommended way to install Ring YAML is through the Ring Package Manager (RingPM).

```bash
ringpm install yaml from ysdragon
```

## 💡 Usage

First, you need to load the library in your Ring script:

```ring
load "yaml.ring"
```

### Loading a YAML File

```ring
yamlData = yaml_load("path/to/your/file.yaml")

if (isNull(yamlData)) {
    print("Error loading YAML: " + yaml_lasterror() + "\n")
else
    print(yamlData)  // Print the entire data structure
}
```

### Loading from a YAML String

```ring
yamlString = `
product: Laptop
price: 1299.99
specs:
  processor: i7
  memory: 16GB
items:
  - name: Mouse
  - name: Keyboard
`

data = yaml_load(yamlString)
? data
```

### Accessing Data

You can access your YAML data in two convenient ways:

**1. Using Standard Ring List Syntax:**

```ring
// Access nested values
product = data[:product]             // "Laptop"
processor = data[:specs][:processor] // "i7"

// Access array elements
firstItem = data[:items][1][:name] // "Mouse"
```

**2. Using the `yaml_get` function with Dot Notation:**

```ring
// Access nested values
product = yaml_get(data, "product")          // "Laptop"
processor = yaml_get(data, "specs.processor")  // "i7"

// Access array elements (1-based indexing)
firstItem = yaml_get(data, "items[1].name") // "Mouse"
// or
firstItem = yaml_get(data, "items.[1].name") // "Mouse"
```

### Error Handling

It's good practice to check for errors, especially when dealing with file I/O.

```ring
data = yaml_load("nonexistent.yaml")

if (isNull(data)) {
    ? "Failed to load YAML file: " + yaml_lasterror()
}
```

## 📚 API Reference

### `yaml_load(source)`

Loads YAML data from a file or a string.

-   **Parameters:**
    -   `source` (string): The file path (if it ends with `.yaml` or `.yml`) or the YAML string to be parsed.
-   **Returns:** A Ring list containing the parsed key-value pairs, or `NULL` if an error occurs.

### `yaml_get(data, path)`

Accesses nested data within a parsed YAML structure using dot notation.

-   **Parameters:**
    -   `data`: The YAML data loaded by the `yaml_load` function.
    -   `path` (string): A dot-separated path to the desired value (e.g., `"product.specs.processor"`).
-   **Returns:** The value at the specified path, or `NULL` if the path is not found.

### `yaml_lasterror()`

Retrieves the last error message that occurred.

-   **Returns:** A string containing the details of the last error.

### `yaml_version()`

Retrieves the libyaml version.

-   **Returns:** A string representing the libyaml version.

## Examples

For more in-depth examples, please refer to the [`examples/`](examples/) directory in the repository.

## 🛠️ Development

If you wish to contribute to the development of Ring YAML or build it from the source, follow these steps.

### Prerequisites

-   **CMake**: Version 3.16 or higher.
-   **C Compiler**: A C compiler compatible with your platform (e.g., GCC, Clang, MSVC).
-   **Ring Source Code**: You will need to have the Ring language source code available on your machine.

### Build Steps

1.  **Clone the Repository:**
    ```sh
    git clone https://github.com/ysdragon/yaml.git --recursive
    ```
    > **Note**: If you installed the library via RingPM, you can skip this step.

2.  **Set the `RING` Environment Variable:**
    This variable must point to the root directory of the Ring language source code.

    -   **Windows (Command Prompt):**
        ```cmd
        set RING=X:\path\to\ring
        ```
    -   **Windows (PowerShell):**
        ```powershell
        $env:RING = "X:\path\to\ring"
        ```
    -   **Unix-like Systems (Linux, macOS or FreeBSD):**
        ```bash
        export RING=/path/to/ring
        ```

3.  **Configure with CMake:**
    Create a build directory and run CMake from within it.
    ```sh
    mkdir build
    cd build
    cmake ..
    ```

4.  **Build the Project:**
    Compile the source code using the build toolchain configured by CMake.
    ```sh
    cmake --build .
    ```

    The compiled library will be available in the `lib/<os>/<arch>` directory.

## 🤝 Contributing

Contributions are always welcome! If you have suggestions for improvements or have identified a bug, please feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for more details.