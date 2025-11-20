import XCTest
@testable import Core

final class RealInterfaceParsingTests: XCTestCase {
    func test_parse_realSwiftUIInterface_extractsModifiers() throws {
        // Arrange
        let parser = InterfaceParser()
        let interfaceFile = "./arm64e-apple-ios.swiftinterface"
        
        // Skip if file doesn't exist
        guard FileManager.default.fileExists(atPath: interfaceFile) else {
            throw XCTSkip("SwiftUI interface file not found at \(interfaceFile)")
        }
        
        // Act
        let modifiers = try parser.parse(filePath: interfaceFile)
        
        // Assert
        XCTAssertFalse(modifiers.isEmpty, "Should extract modifiers from real interface file")
        
        // Print first 10 modifiers for verification
        print("\n=== Extracted Modifiers ===")
        for (index, modifier) in modifiers.prefix(10).enumerated() {
            print("\n[\(index + 1)] \(modifier.name)")
            print("  Parameters: \(modifier.parameters.count)")
            print("  Return: \(modifier.returnType)")
            if let availability = modifier.availability {
                print("  Availability: \(availability)")
            }
            if modifier.isGeneric {
                print("  Generic: yes")
            }
        }
        print("\n=== Total: \(modifiers.count) modifiers ===\n")
    }
    
    func test_parse_realSwiftUIInterface_extractsDisabledModifier() throws {
        // Arrange
        let parser = InterfaceParser()
        let interfaceFile = "./arm64e-apple-ios.swiftinterface"
        
        guard FileManager.default.fileExists(atPath: interfaceFile) else {
            throw XCTSkip("SwiftUI interface file not found")
        }
        
        // Act
        let modifiers = try parser.parse(filePath: interfaceFile)
        
        // Find the disabled modifier
        let disabledModifiers = modifiers.filter { $0.name == "disabled" }
        
        // Assert
        XCTAssertFalse(disabledModifiers.isEmpty, "Should find 'disabled' modifier")
        
        if let first = disabledModifiers.first {
            print("\n=== disabled modifier ===")
            print("Name: \(first.name)")
            print("Parameters: \(first.parameters.count)")
            for param in first.parameters {
                print("  - \(param.label ?? "_") \(param.name): \(param.type)")
            }
            print("Return: \(first.returnType)")
        }
    }
}
