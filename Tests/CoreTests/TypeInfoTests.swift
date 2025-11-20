import XCTest
@testable import Core

final class TypeInfoTests: XCTestCase {
    // MARK: - Simple Type Tests
    
    func test_simple_createsSimpleType() {
        // Act
        let typeInfo = TypeInfo.simple(name: "String")
        
        // Assert
        XCTAssertEqual(typeInfo.rawType, "String")
        XCTAssertEqual(typeInfo.baseName, "String")
        XCTAssertTrue(typeInfo.genericParameters.isEmpty)
        XCTAssertFalse(typeInfo.isOptional)
        XCTAssertFalse(typeInfo.isClosure)
    }
    
    func test_simple_withComplexType_createsType() {
        // Act
        let typeInfo = TypeInfo.simple(name: "CGFloat")
        
        // Assert
        XCTAssertEqual(typeInfo.rawType, "CGFloat")
        XCTAssertEqual(typeInfo.baseName, "CGFloat")
    }
    
    // MARK: - Optional Type Tests
    
    func test_optional_createsOptionalType() {
        // Arrange
        let baseType = TypeInfo.simple(name: "String")
        
        // Act
        let optionalType = TypeInfo.optional(baseType)
        
        // Assert
        XCTAssertEqual(optionalType.rawType, "String?")
        XCTAssertEqual(optionalType.baseName, "String")
        XCTAssertTrue(optionalType.isOptional)
    }
    
    func test_optional_withGenericType_preservesGenerics() {
        // Arrange
        let baseType = TypeInfo.generic(
            name: "Array",
            parameters: [.simple(name: "String")]
        )
        
        // Act
        let optionalType = TypeInfo.optional(baseType)
        
        // Assert
        XCTAssertEqual(optionalType.rawType, "Array<String>?")
        XCTAssertTrue(optionalType.isOptional)
        XCTAssertEqual(optionalType.genericParameters.count, 1)
    }
    
    // MARK: - Generic Type Tests
    
    func test_generic_withParameters_createsGenericType() {
        // Act
        let typeInfo = TypeInfo.generic(
            name: "Optional",
            parameters: [.simple(name: "String")]
        )
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "Optional")
        XCTAssertEqual(typeInfo.rawType, "Optional<String>")
        XCTAssertEqual(typeInfo.genericParameters.count, 1)
        XCTAssertEqual(typeInfo.genericParameters[0].baseName, "String")
    }
    
    func test_generic_withMultipleParameters_createsType() {
        // Act
        let typeInfo = TypeInfo.generic(
            name: "Dictionary",
            parameters: [
                .simple(name: "String"),
                .simple(name: "Int")
            ]
        )
        
        // Assert
        XCTAssertEqual(typeInfo.rawType, "Dictionary<String, Int>")
        XCTAssertEqual(typeInfo.genericParameters.count, 2)
    }
    
    // MARK: - Closure Type Tests
    
    func test_closure_withParameters_createsClosureType() {
        // Act
        let typeInfo = TypeInfo.closure(
            parameters: [.simple(name: "String")],
            returnType: .simple(name: "Void"),
            isEscaping: false
        )
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertEqual(typeInfo.closureParameters.count, 1)
        XCTAssertEqual(typeInfo.closureReturnType?.baseName, "Void")
        XCTAssertFalse(typeInfo.isEscaping)
        XCTAssertEqual(typeInfo.rawType, "(String) -> Void")
    }
    
    func test_closure_withEscaping_setsEscaping() {
        // Act
        let typeInfo = TypeInfo.closure(
            parameters: [],
            returnType: .simple(name: "Void"),
            isEscaping: true
        )
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertTrue(typeInfo.isEscaping)
        XCTAssertEqual(typeInfo.rawType, "@escaping () -> Void")
    }
    
    func test_closure_withMultipleParameters_formatsCorrectly() {
        // Act
        let typeInfo = TypeInfo.closure(
            parameters: [
                .simple(name: "String"),
                .simple(name: "Int")
            ],
            returnType: .simple(name: "Bool"),
            isEscaping: false
        )
        
        // Assert
        XCTAssertEqual(typeInfo.rawType, "(String, Int) -> Bool")
    }
    
    // MARK: - Equality Tests
    
    func test_equality_sameSimpleTypes_areEqual() {
        // Arrange
        let type1 = TypeInfo.simple(name: "String")
        let type2 = TypeInfo.simple(name: "String")
        
        // Act & Assert
        XCTAssertEqual(type1, type2)
    }
    
    func test_equality_differentSimpleTypes_areNotEqual() {
        // Arrange
        let type1 = TypeInfo.simple(name: "String")
        let type2 = TypeInfo.simple(name: "Int")
        
        // Act & Assert
        XCTAssertNotEqual(type1, type2)
    }
    
    func test_equality_sameOptionalTypes_areEqual() {
        // Arrange
        let type1 = TypeInfo.optional(.simple(name: "String"))
        let type2 = TypeInfo.optional(.simple(name: "String"))
        
        // Act & Assert
        XCTAssertEqual(type1, type2)
    }
    
    func test_equality_sameGenericTypes_areEqual() {
        // Arrange
        let type1 = TypeInfo.generic(
            name: "Array",
            parameters: [.simple(name: "String")]
        )
        let type2 = TypeInfo.generic(
            name: "Array",
            parameters: [.simple(name: "String")]
        )
        
        // Act & Assert
        XCTAssertEqual(type1, type2)
    }
}
