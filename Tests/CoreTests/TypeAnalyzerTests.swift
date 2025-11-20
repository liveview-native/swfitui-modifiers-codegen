import XCTest
@testable import Core

final class TypeAnalyzerTests: XCTestCase {
    var sut: TypeAnalyzer!
    
    override func setUp() {
        super.setUp()
        sut = TypeAnalyzer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Simple Type Analysis Tests
    
    func test_analyze_simpleType_returnsSimpleTypeInfo() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "String")
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "String")
        XCTAssertEqual(typeInfo.rawType, "String")
        XCTAssertFalse(typeInfo.isOptional)
        XCTAssertFalse(typeInfo.isClosure)
    }
    
    func test_analyze_simpleTypeWithWhitespace_trimsWhitespace() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "  CGFloat  ")
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "CGFloat")
        XCTAssertEqual(typeInfo.rawType, "CGFloat")
    }
    
    // MARK: - Optional Type Analysis Tests
    
    func test_analyze_optionalType_returnsOptionalTypeInfo() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "String?")
        
        // Assert
        XCTAssertTrue(typeInfo.isOptional)
        XCTAssertEqual(typeInfo.baseName, "String")
        XCTAssertEqual(typeInfo.rawType, "String?")
    }
    
    func test_analyze_optionalGenericType_preservesGeneric() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "Array<String>?")
        
        // Assert
        XCTAssertTrue(typeInfo.isOptional)
        XCTAssertEqual(typeInfo.baseName, "Array")
        XCTAssertEqual(typeInfo.rawType, "Array<String>?")
    }
    
    // MARK: - Generic Type Analysis Tests
    
    func test_analyze_genericType_returnsGenericTypeInfo() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "Array<String>")
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "Array")
        XCTAssertEqual(typeInfo.rawType, "Array<String>")
        XCTAssertEqual(typeInfo.genericParameters.count, 1)
        XCTAssertEqual(typeInfo.genericParameters[0].baseName, "String")
    }
    
    func test_analyze_genericTypeWithMultipleParameters_parsesAll() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "Dictionary<String, Int>")
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "Dictionary")
        XCTAssertEqual(typeInfo.genericParameters.count, 2)
        XCTAssertEqual(typeInfo.genericParameters[0].baseName, "String")
        XCTAssertEqual(typeInfo.genericParameters[1].baseName, "Int")
    }
    
    func test_analyze_nestedGenericType_parsesCorrectly() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "Array<Dictionary<String, Int>>")
        
        // Assert
        XCTAssertEqual(typeInfo.baseName, "Array")
        XCTAssertEqual(typeInfo.genericParameters.count, 1)
        
        let innerType = typeInfo.genericParameters[0]
        XCTAssertEqual(innerType.baseName, "Dictionary")
        XCTAssertEqual(innerType.genericParameters.count, 2)
    }
    
    // MARK: - Closure Type Analysis Tests
    
    func test_analyze_closureWithNoParameters_returnsClosureTypeInfo() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "() -> Void")
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertTrue(typeInfo.closureParameters.isEmpty)
        XCTAssertEqual(typeInfo.closureReturnType?.baseName, "Void")
        XCTAssertFalse(typeInfo.isEscaping)
    }
    
    func test_analyze_closureWithParameter_parsesParameter() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "(String) -> Int")
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertEqual(typeInfo.closureParameters.count, 1)
        XCTAssertEqual(typeInfo.closureParameters[0].baseName, "String")
        XCTAssertEqual(typeInfo.closureReturnType?.baseName, "Int")
    }
    
    func test_analyze_closureWithMultipleParameters_parsesAll() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "(String, Int, Bool) -> Void")
        
        // Assert
        XCTAssertEqual(typeInfo.closureParameters.count, 3)
        XCTAssertEqual(typeInfo.closureParameters[0].baseName, "String")
        XCTAssertEqual(typeInfo.closureParameters[1].baseName, "Int")
        XCTAssertEqual(typeInfo.closureParameters[2].baseName, "Bool")
    }
    
    func test_analyze_escapingClosure_setsEscapingFlag() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "@escaping () -> Void")
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertTrue(typeInfo.isEscaping)
    }
    
    func test_analyze_escapingClosureWithParameters_parsesCorrectly() throws {
        // Act
        let typeInfo = try sut.analyze(typeString: "@escaping (String) -> Bool")
        
        // Assert
        XCTAssertTrue(typeInfo.isClosure)
        XCTAssertTrue(typeInfo.isEscaping)
        XCTAssertEqual(typeInfo.closureParameters.count, 1)
        XCTAssertEqual(typeInfo.closureReturnType?.baseName, "Bool")
    }
    
    // MARK: - Categorization Tests
    
    func test_categorize_layoutModifiers_groupsCorrectly() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "frame", parameters: [], returnType: "some View"),
            ModifierInfo(name: "padding", parameters: [], returnType: "some View"),
            ModifierInfo(name: "offset", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Layout"]?.count, 3)
        XCTAssertEqual(categories["Layout"]?.map { $0.name }.sorted(), ["frame", "offset", "padding"])
    }
    
    func test_categorize_appearanceModifiers_groupsCorrectly() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "background", parameters: [], returnType: "some View"),
            ModifierInfo(name: "foregroundColor", parameters: [], returnType: "some View"),
            ModifierInfo(name: "opacity", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Appearance"]?.count, 3)
    }
    
    func test_categorize_textModifiers_groupsCorrectly() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "font", parameters: [], returnType: "some View"),
            ModifierInfo(name: "bold", parameters: [], returnType: "some View"),
            ModifierInfo(name: "italic", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Text"]?.count, 3)
    }
    
    func test_categorize_interactionModifiers_groupsCorrectly() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "onTapGesture", parameters: [], returnType: "some View"),
            ModifierInfo(name: "disabled", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Interaction"]?.count, 2)
    }
    
    func test_categorize_accessibilityModifiers_groupsCorrectly() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "accessibilityLabel", parameters: [], returnType: "some View"),
            ModifierInfo(name: "accessibilityHint", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Accessibility"]?.count, 2)
    }
    
    func test_categorize_mixedModifiers_groupsIntoMultipleCategories() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View"),
            ModifierInfo(name: "background", parameters: [], returnType: "some View"),
            ModifierInfo(name: "font", parameters: [], returnType: "some View"),
            ModifierInfo(name: "onTapGesture", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories.keys.count, 4)
        XCTAssertEqual(categories["Layout"]?.count, 1)
        XCTAssertEqual(categories["Appearance"]?.count, 1)
        XCTAssertEqual(categories["Text"]?.count, 1)
        XCTAssertEqual(categories["Interaction"]?.count, 1)
    }
    
    func test_categorize_unknownModifier_groupsIntoOther() {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "unknownModifier", parameters: [], returnType: "some View")
        ]
        
        // Act
        let categories = sut.categorize(modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(categories["Other"]?.count, 1)
    }
}
