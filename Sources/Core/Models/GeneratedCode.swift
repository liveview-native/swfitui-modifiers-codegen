/// Represents generated Swift code output.
///
/// This struct holds the generated code along with metadata about
/// what was generated and any warnings or errors encountered.
public struct GeneratedCode: Equatable, Sendable {
    /// The generated Swift source code.
    public let sourceCode: String
    
    /// The name of the file this code should be written to.
    public let fileName: String
    
    /// The number of modifiers that were successfully generated.
    public let modifierCount: Int
    
    /// Warnings encountered during generation.
    public let warnings: [String]
    
    /// Errors encountered during generation.
    public let errors: [String]
    
    /// Creates a new generated code instance.
    ///
    /// - Parameters:
    ///   - sourceCode: The generated Swift source code.
    ///   - fileName: The name of the file this code should be written to.
    ///   - modifierCount: The number of modifiers that were successfully generated. Defaults to 0.
    ///   - warnings: Warnings encountered during generation. Defaults to empty array.
    ///   - errors: Errors encountered during generation. Defaults to empty array.
    public init(
        sourceCode: String,
        fileName: String,
        modifierCount: Int = 0,
        warnings: [String] = [],
        errors: [String] = []
    ) {
        self.sourceCode = sourceCode
        self.fileName = fileName
        self.modifierCount = modifierCount
        self.warnings = warnings
        self.errors = errors
    }
    
    /// Whether the generation was successful (no errors).
    public var isSuccessful: Bool {
        errors.isEmpty
    }
    
    /// Whether there are any warnings.
    public var hasWarnings: Bool {
        !warnings.isEmpty
    }
}
