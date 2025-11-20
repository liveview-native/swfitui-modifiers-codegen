import XCTest
@testable import Core

final class EnumGeneratorTests: XCTestCase {
    var sut: EnumGenerator!
    
    override func setUp() {
        super.setUp()
        sut = EnumGenerator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Generation Tests
    
    func test_generate_withSimpleModifier_generatesEnum() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.isSuccessful)
        XCTAssertEqual(result.modifierCount, 1)
        XCTAssertTrue(result.sourceCode.contains("public enum LayoutModifier"))
        XCTAssertTrue(result.sourceCode.contains("case padding"))
        XCTAssertTrue(result.sourceCode.contains("self.padding()"))
    }
    
    func test_generate_withParameterizedModifier_generatesEnumWithAssociatedValues() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(
                name: "padding",
                parameters: [
                    .init(label: nil, name: "edges", type: "Edge.Set"),
                    .init(label: nil, name: "length", type: "CGFloat?")
                ],
                returnType: "some View"
            )
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("case padding(Edge.Set, CGFloat?)"))
    }
    
    func test_generate_withLabeledParameters_usesLabels() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(
                name: "background",
                parameters: [
                    .init(label: "alignment", name: "alignment", type: "Alignment")
                ],
                returnType: "some View"
            )
        ]
        
        // Act
        let result = try sut.generate(enumName: "AppearanceModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("case background(alignment: Alignment)"))
        XCTAssertTrue(result.sourceCode.contains("self.background(alignment: alignment)"))
    }
    
    // MARK: - Multiple Modifiers Tests
    
    func test_generate_withMultipleModifiers_generatesAllCases() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View"),
            ModifierInfo(name: "background", parameters: [], returnType: "some View"),
            ModifierInfo(name: "foregroundColor", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "CommonModifiers", modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(result.modifierCount, 3)
        XCTAssertTrue(result.sourceCode.contains("case padding"))
        XCTAssertTrue(result.sourceCode.contains("case background"))
        XCTAssertTrue(result.sourceCode.contains("case foregroundColor"))
    }
    
    // MARK: - Switch Case Generation Tests
    
    func test_generate_includesSwitchStatement() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("switch modifier {"))
        XCTAssertTrue(result.sourceCode.contains("case .padding:"))
    }
    
    func test_generate_withParameters_generatesSwitchWithBindings() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(
                name: "frame",
                parameters: [
                    .init(label: "width", name: "w", type: "CGFloat?"),
                    .init(label: "height", name: "h", type: "CGFloat?")
                ],
                returnType: "some View"
            )
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("case .frame(let width, let height):"))
        XCTAssertTrue(result.sourceCode.contains("self.frame(width: width, height: height)"))
    }
    
    // MARK: - Documentation Tests
    
    func test_generate_includesDocumentation() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("/// Generated modifier enum"))
        XCTAssertTrue(result.sourceCode.contains("/// This enum provides type-safe access"))
    }
    
    // MARK: - Extension Generation Tests
    
    func test_generate_includesViewExtension() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("extension View {"))
        XCTAssertTrue(result.sourceCode.contains("func modifier(_ modifier: LayoutModifier)"))
    }
    
    func test_generate_marksMethodAsInlinable() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("@inlinable"))
    }
    
    // MARK: - File Name Tests
    
    func test_generate_setsCorrectFileName() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertEqual(result.fileName, "LayoutModifier.swift")
    }
    
    // MARK: - Error Cases Tests
    
    func test_generate_withEmptyModifiers_throwsError() {
        // Arrange
        let modifiers: [ModifierInfo] = []
        
        // Act & Assert
        XCTAssertThrowsError(try sut.generate(enumName: "Empty", modifiers: modifiers)) { error in
            if case EnumGenerator.GenerationError.invalidModifierInfo(let message) = error {
                XCTAssertTrue(message.contains("no modifiers"))
            } else {
                XCTFail("Expected invalidModifierInfo error")
            }
        }
    }
    
    // MARK: - Conformance Tests
    
    func test_generate_enumConformsToEquatable() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("Equatable"))
    }
    
    func test_generate_enumConformsToSendable() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "padding", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "LayoutModifier", modifiers: modifiers)
        
        // Assert
        XCTAssertTrue(result.sourceCode.contains("Sendable"))
    }
    
    // MARK: - Special Cases Tests
    
    func test_generate_withUnderscorePrefix_generatesValidCaseName() throws {
        // Arrange
        let modifiers = [
            ModifierInfo(name: "_makeView", parameters: [], returnType: "some View")
        ]
        
        // Act
        let result = try sut.generate(enumName: "InternalModifier", modifiers: modifiers)
        
        // Assert
        // Should convert _makeView to underscoreMakeView or similar valid case name
        XCTAssertTrue(result.sourceCode.contains("case underscore"))
    }
}
