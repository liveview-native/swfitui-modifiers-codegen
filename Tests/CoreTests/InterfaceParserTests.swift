import XCTest
@testable import Core

final class InterfaceParserTests: XCTestCase {
    var sut: InterfaceParser!
    
    override func setUp() {
        super.setUp()
        sut = InterfaceParser()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Parsing Tests
    
    func test_parse_withSimpleModifier_extractsModifier() throws {
        // Arrange
        let source = """
        extension View {
            public func padding() -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertEqual(modifiers[0].name, "padding")
        XCTAssertTrue(modifiers[0].parameters.isEmpty)
        XCTAssertEqual(modifiers[0].returnType, "some View")
    }
    
    func test_parse_withParameterizedModifier_extractsParameters() throws {
        // Arrange
        let source = """
        extension View {
            public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertEqual(modifiers[0].name, "padding")
        XCTAssertEqual(modifiers[0].parameters.count, 2)
        
        // First parameter
        XCTAssertNil(modifiers[0].parameters[0].label)
        XCTAssertEqual(modifiers[0].parameters[0].name, "edges")
        XCTAssertEqual(modifiers[0].parameters[0].type, "Edge.Set")
        XCTAssertTrue(modifiers[0].parameters[0].hasDefaultValue)
        XCTAssertEqual(modifiers[0].parameters[0].defaultValue, ".all")
        
        // Second parameter
        XCTAssertNil(modifiers[0].parameters[1].label)
        XCTAssertEqual(modifiers[0].parameters[1].name, "length")
        XCTAssertEqual(modifiers[0].parameters[1].type, "CGFloat?")
        XCTAssertTrue(modifiers[0].parameters[1].hasDefaultValue)
        XCTAssertEqual(modifiers[0].parameters[1].defaultValue, "nil")
    }
    
    func test_parse_withLabeledParameter_extractsLabel() throws {
        // Arrange
        let source = """
        extension View {
            public func background(alignment: Alignment = .center) -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertEqual(modifiers[0].parameters.count, 1)
        XCTAssertEqual(modifiers[0].parameters[0].label, "alignment")
        XCTAssertEqual(modifiers[0].parameters[0].name, "alignment")
        XCTAssertEqual(modifiers[0].parameters[0].type, "Alignment")
    }
    
    func test_parse_withDifferentLabelAndName_extractsBoth() throws {
        // Arrange
        let source = """
        extension View {
            public func frame(width w: CGFloat?, height h: CGFloat?) -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertEqual(modifiers[0].parameters.count, 2)
        
        // First parameter
        XCTAssertEqual(modifiers[0].parameters[0].label, "width")
        XCTAssertEqual(modifiers[0].parameters[0].name, "w")
        XCTAssertEqual(modifiers[0].parameters[0].type, "CGFloat?")
        
        // Second parameter
        XCTAssertEqual(modifiers[0].parameters[1].label, "height")
        XCTAssertEqual(modifiers[0].parameters[1].name, "h")
        XCTAssertEqual(modifiers[0].parameters[1].type, "CGFloat?")
    }
    
    // MARK: - Multiple Modifiers Tests
    
    func test_parse_withMultipleModifiers_extractsAll() throws {
        // Arrange
        let source = """
        extension View {
            public func padding() -> some View {
                return self
            }
            
            public func background() -> some View {
                return self
            }
            
            public func foregroundColor(_ color: Color?) -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 3)
        XCTAssertEqual(modifiers[0].name, "padding")
        XCTAssertEqual(modifiers[1].name, "background")
        XCTAssertEqual(modifiers[2].name, "foregroundColor")
    }
    
    // MARK: - Access Control Tests
    
    func test_parse_withPrivateFunction_doesNotExtract() throws {
        // Arrange
        let source = """
        extension View {
            private func internalHelper() -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
    
    func test_parse_withInternalFunction_doesNotExtract() throws {
        // Arrange
        let source = """
        extension View {
            func internalModifier() -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
    
    // MARK: - Non-View Extension Tests
    
    func test_parse_withNonViewExtension_doesNotExtract() throws {
        // Arrange
        let source = """
        extension String {
            public func something() -> String {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
    
    func test_parse_withViewModifierExtension_doesNotExtract() throws {
        // Arrange
        let source = """
        extension ViewModifier {
            public func something() -> some View {
                return EmptyView()
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
    
    // MARK: - Generic Modifiers Tests
    
    func test_parse_withGenericModifier_setsIsGeneric() throws {
        // Arrange
        let source = """
        extension View {
            public func overlay<Content: View>(_ content: Content) -> some View {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertTrue(modifiers[0].isGeneric)
    }
    
    func test_parse_withGenericConstraints_extractsConstraints() throws {
        // Arrange
        let source = """
        extension View {
            public func something<T>() -> some View where T: Equatable {
                return self
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertEqual(modifiers.count, 1)
        XCTAssertTrue(modifiers[0].isGeneric)
        XCTAssertEqual(modifiers[0].genericConstraints.count, 1)
        XCTAssertTrue(modifiers[0].genericConstraints[0].contains("Equatable"))
    }
    
    // MARK: - Edge Cases Tests
    
    func test_parse_withEmptySource_returnsEmpty() throws {
        // Arrange
        let source = ""
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
    
    func test_parse_withNoExtensions_returnsEmpty() throws {
        // Arrange
        let source = """
        struct MyView: View {
            var body: some View {
                Text("Hello")
            }
        }
        """
        
        // Act
        let modifiers = try sut.parse(source: source)
        
        // Assert
        XCTAssertTrue(modifiers.isEmpty)
    }
}
