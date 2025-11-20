# ModifierSwift

A Swift tool for generating type-safe SwiftUI modifier enums from `.swiftinterface` files.

## Overview

ModifierSwift parses SwiftUI's `.swiftinterface` files and generates type-safe enum representations of view modifiers. This enables:

- **Type-safe modifier composition** - Catch invalid modifier combinations at compile time
- **Better autocomplete** - IDE suggestions for valid modifier variants
- **Easier refactoring** - Modifiers represented as data structures
- **Testing support** - Assert on modifier values in UI tests

## Installation

### Requirements

- macOS 14.0+
- Swift 6.2+
- Xcode 16.0+

### Building from Source

```bash
git clone <repository-url>
cd modifierSwift
swift build -c release
```

The executable will be available at `.build/release/modifier-swift`.

## Usage

### Basic Usage

```bash
modifier-swift --input /path/to/SwiftUICore.swiftinterface --output ./Generated
```

### Options

- `-i, --input <path>` - Path to the `.swiftinterface` file to parse (required)
- `-o, --output <path>` - Output directory for generated Swift files (default: `./Generated`)
- `-v, --verbose` - Enable verbose output
- `--version` - Show version information
- `-h, --help` - Show help information

## Project Structure

```
Sources/
├── Core/               # Core library components
│   ├── Models/         # Data models (ModifierInfo, TypeInfo, etc.)
│   ├── Parser/         # SwiftInterface parsing logic
│   ├── Analyzer/       # Type analysis and categorization
│   └── Generator/      # Code generation for enums
└── CLI/                # Command-line interface

Tests/
├── CoreTests/          # Unit tests for Core library
└── IntegrationTests/   # End-to-end integration tests
```

## Development

### Running Tests

```bash
swift test
```

### Running the CLI in Development

```bash
# Basic usage
swift run modifier-swift --input arm64e-apple-ios.swiftinterface --output ./Generated

# With verbose output
swift run modifier-swift --input arm64e-apple-ios.swiftinterface --output ./Generated --verbose

# Clean output directory before generating
swift run modifier-swift --input arm64e-apple-ios.swiftinterface --output ./Generated --clean

# Disable categorization (all in one directory)
swift run modifier-swift --input arm64e-apple-ios.swiftinterface --output ./Generated --no-categorize
```

### Real-World Example

Processing the actual SwiftUI interface file:

```bash
$ modifier-swift --input arm64e-apple-ios.swiftinterface --output ./Generated --verbose --clean

ModifierSwift v0.1.0
Input: arm64e-apple-ios.swiftinterface
Output: ./Generated

📖 Parsing interface file...
✓ Found 199 modifiers

📊 Categorized into 7 groups:
  • Animation: 2 modifiers
  • Appearance: 14 modifiers
  • Environment: 2 modifiers
  • Interaction: 5 modifiers
  • Layout: 11 modifiers
  • Other: 161 modifiers
  • Text: 4 modifiers

🔨 Generating code...
  ✓ Generated TextModifier.swift (4 modifiers)
  ✓ Generated AppearanceModifier.swift (14 modifiers)
  ✓ Generated OtherModifier.swift (161 modifiers)
  ✓ Generated LayoutModifier.swift (11 modifiers)
  ✓ Generated AnimationModifier.swift (2 modifiers)
  ✓ Generated InteractionModifier.swift (5 modifiers)
  ✓ Generated EnvironmentModifier.swift (2 modifiers)

✅ Successfully generated 7 enum(s) with 199 total modifiers
📁 Output: ./Generated
```

### Code Formatting

This project uses SwiftFormat. Format all code before committing:

```bash
swiftformat Sources/ Tests/
```

## Generated Code Example

Given a SwiftUI modifier like:

```swift
extension View {
    func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View
}
```

ModifierSwift generates:

```swift
public enum PaddingModifier {
    case edges(Edge.Set, CGFloat?)
    case all
    case length(CGFloat)
}

extension View {
    func modifier(_ modifier: PaddingModifier) -> some View {
        switch modifier {
        case .edges(let edges, let length):
            self.padding(edges, length)
        case .all:
            self.padding()
        case .length(let length):
            self.padding(length)
        }
    }
}
```

## Architecture

### 1. Parser Phase

The `InterfaceParser` reads `.swiftinterface` files and extracts:
- View extension methods
- Method signatures and parameters
- Availability constraints
- Documentation comments

### 2. Analysis Phase

The `TypeAnalyzer` processes extracted methods:
- Resolves type information
- Groups related modifiers
- Identifies parameter patterns
- Categorizes by functionality

### 3. Generation Phase

The `EnumGenerator` produces Swift code:
- Enum cases for each modifier variant
- SyntaxConvertible extensions
- Helper methods for applying modifiers
- Documentation comments

### 4. Output Phase

The `FileOutputManager` writes generated files:
- Organizes by category
- Applies code formatting
- Generates imports and headers

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Status

✅ **All Core Phases Complete!**

Completed Phases:
- ✅ Phase 1: Project Structure & Foundation
- ✅ Phase 2: SwiftInterface Parser
- ✅ Phase 3: Type System Analysis
- ✅ Phase 4: Code Generator - Modifier Enums
- ✅ Phase 5: Code Generator - SyntaxConvertible Extensions (merged with Phase 4)
- ✅ Phase 6: File Output Manager
- ✅ Phase 7: CLI Interface
- ✅ Phase 8: Testing & Validation

**Test Coverage:** 78 tests passing across all components
