import XCTest
@testable import Core

final class ModifierInfoTests: XCTestCase {
    // MARK: - Initialization Tests
    
    func test_init_withAllParameters_createsInstance() {
        // Arrange & Act
        let modifier = ModifierInfo(
            name: "padding",
            parameters: [],
            returnType: "some View",
            availability: "@available(iOS 13.0, *)",
            documentation: "Adds padding to the view",
            isGeneric: false,
            genericConstraints: []
        )
        
        // Assert
        XCTAssertEqual(modifier.name, "padding")
        XCTAssertTrue(modifier.parameters.isEmpty)
        XCTAssertEqual(modifier.returnType, "some View")
        XCTAssertEqual(modifier.availability, "@available(iOS 13.0, *)")
        XCTAssertEqual(modifier.documentation, "Adds padding to the view")
        XCTAssertFalse(modifier.isGeneric)
        XCTAssertTrue(modifier.genericConstraints.isEmpty)
    }
    
    func test_init_withMinimalParameters_createsInstance() {
        // Arrange & Act
        let modifier = ModifierInfo(
            name: "background",
            parameters: [],
            returnType: "some View"
        )
        
        // Assert
        XCTAssertEqual(modifier.name, "background")
        XCTAssertNil(modifier.availability)
        XCTAssertNil(modifier.documentation)
        XCTAssertFalse(modifier.isGeneric)
    }
    
    // MARK: - Parameter Tests
    
    func test_parameter_withLabel_createsInstance() {
        // Arrange & Act
        let param = ModifierInfo.Parameter(
            label: "alignment",
            name: "alignment",
            type: "Alignment"
        )
        
        // Assert
        XCTAssertEqual(param.label, "alignment")
        XCTAssertEqual(param.name, "alignment")
        XCTAssertEqual(param.type, "Alignment")
        XCTAssertFalse(param.hasDefaultValue)
        XCTAssertNil(param.defaultValue)
    }
    
    func test_parameter_withoutLabel_createsInstance() {
        // Arrange & Act
        let param = ModifierInfo.Parameter(
            label: nil,
            name: "value",
            type: "CGFloat"
        )
        
        // Assert
        XCTAssertNil(param.label)
        XCTAssertEqual(param.name, "value")
    }
    
    func test_parameter_withDefaultValue_createsInstance() {
        // Arrange & Act
        let param = ModifierInfo.Parameter(
            label: "edges",
            name: "edges",
            type: "Edge.Set",
            hasDefaultValue: true,
            defaultValue: ".all"
        )
        
        // Assert
        XCTAssertTrue(param.hasDefaultValue)
        XCTAssertEqual(param.defaultValue, ".all")
    }
    
    // MARK: - Equality Tests
    
    func test_equality_sameModifiers_areEqual() {
        // Arrange
        let modifier1 = ModifierInfo(
            name: "padding",
            parameters: [],
            returnType: "some View"
        )
        let modifier2 = ModifierInfo(
            name: "padding",
            parameters: [],
            returnType: "some View"
        )
        
        // Act & Assert
        XCTAssertEqual(modifier1, modifier2)
    }
    
    func test_equality_differentNames_areNotEqual() {
        // Arrange
        let modifier1 = ModifierInfo(
            name: "padding",
            parameters: [],
            returnType: "some View"
        )
        let modifier2 = ModifierInfo(
            name: "background",
            parameters: [],
            returnType: "some View"
        )
        
        // Act & Assert
        XCTAssertNotEqual(modifier1, modifier2)
    }
}
