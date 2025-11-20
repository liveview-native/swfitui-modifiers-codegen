import Foundation

/// Analyzes types in modifier signatures and resolves type relationships.
///
/// This analyzer processes type information from parsed modifiers,
/// resolving generic types, protocols, and type aliases.
public struct TypeAnalyzer: Sendable {
    /// Errors that can occur during type analysis.
    public enum AnalysisError: Error, Equatable {
        case unresolvableType(String)
        case circularDependency([String])
        case invalidGenericConstraint(String)
    }
    
    /// Creates a new type analyzer.
    public init() {}
    
    /// Analyzes a type string and returns type information.
    ///
    /// - Parameter typeString: The type string to analyze.
    /// - Returns: A TypeInfo instance representing the analyzed type.
    /// - Throws: AnalysisError if the type cannot be analyzed.
    public func analyze(typeString: String) throws -> TypeInfo {
        let trimmed = typeString.trimmingCharacters(in: .whitespaces)
        
        // Check for optional types
        if trimmed.hasSuffix("?") {
            let unwrapped = String(trimmed.dropLast())
            let wrappedType = try analyze(typeString: unwrapped)
            return .optional(wrappedType)
        }
        
        // Check for closure types
        if trimmed.contains("->") {
            return try analyzeClosure(typeString: trimmed)
        }
        
        // Check for generic types
        if trimmed.contains("<") && trimmed.contains(">") {
            return try analyzeGeneric(typeString: trimmed)
        }
        
        // Simple type
        return .simple(name: trimmed)
    }
    
    /// Groups modifiers by category based on their type signatures.
    ///
    /// - Parameter modifiers: The modifiers to categorize.
    /// - Returns: A dictionary mapping category names to modifier groups.
    public func categorize(modifiers: [ModifierInfo]) -> [String: [ModifierInfo]] {
        var categories: [String: [ModifierInfo]] = [:]
        
        for modifier in modifiers {
            let category = determineCategory(for: modifier)
            categories[category, default: []].append(modifier)
        }
        
        return categories
    }
    
    // MARK: - Private Analysis Methods
    
    /// Analyzes a generic type string.
    private func analyzeGeneric(typeString: String) throws -> TypeInfo {
        // Find the base type name (before '<')
        guard let angleStart = typeString.firstIndex(of: "<"),
              let angleEnd = typeString.lastIndex(of: ">") else {
            throw AnalysisError.unresolvableType(typeString)
        }
        
        let baseName = String(typeString[..<angleStart])
        let parametersString = String(typeString[typeString.index(after: angleStart)..<angleEnd])
        
        // Parse generic parameters (split by comma, but handle nested generics)
        let parameters = try parseGenericParameters(parametersString)
        
        return .generic(name: baseName, parameters: parameters)
    }
    
    /// Parses generic parameters from a comma-separated list.
    private func parseGenericParameters(_ string: String) throws -> [TypeInfo] {
        var parameters: [TypeInfo] = []
        var currentParam = ""
        var angleDepth = 0
        var parenDepth = 0
        
        for char in string {
            switch char {
            case "<":
                angleDepth += 1
                currentParam.append(char)
            case ">":
                angleDepth -= 1
                currentParam.append(char)
            case "(":
                parenDepth += 1
                currentParam.append(char)
            case ")":
                parenDepth -= 1
                currentParam.append(char)
            case "," where angleDepth == 0 && parenDepth == 0:
                // This is a top-level separator
                if !currentParam.isEmpty {
                    parameters.append(try analyze(typeString: currentParam))
                    currentParam = ""
                }
            default:
                currentParam.append(char)
            }
        }
        
        // Add the last parameter
        if !currentParam.isEmpty {
            parameters.append(try analyze(typeString: currentParam))
        }
        
        return parameters
    }
    
    /// Analyzes a closure/function type string.
    private func analyzeClosure(typeString: String) throws -> TypeInfo {
        let isEscaping = typeString.contains("@escaping")
        let cleaned = typeString.replacingOccurrences(of: "@escaping", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Find the arrow position
        guard let arrowRange = cleaned.range(of: "->") else {
            throw AnalysisError.unresolvableType(typeString)
        }
        
        // Extract parameter list (between parentheses)
        var paramString = String(cleaned[..<arrowRange.lowerBound])
            .trimmingCharacters(in: .whitespaces)
        
        // Remove outer parentheses
        if paramString.hasPrefix("(") && paramString.hasSuffix(")") {
            paramString = String(paramString.dropFirst().dropLast())
        }
        
        // Parse parameters
        let parameters: [TypeInfo]
        if paramString.isEmpty {
            parameters = []
        } else {
            parameters = try parseGenericParameters(paramString)
        }
        
        // Extract return type
        let returnString = String(cleaned[arrowRange.upperBound...])
            .trimmingCharacters(in: .whitespaces)
        let returnType = try analyze(typeString: returnString)
        
        return .closure(parameters: parameters, returnType: returnType, isEscaping: isEscaping)
    }
    
    // MARK: - Categorization Methods
    
    /// Determines the category for a modifier based on its name and signature.
    private func determineCategory(for modifier: ModifierInfo) -> String {
        let name = modifier.name.lowercased()
        
        // Layout modifiers
        if ["frame", "padding", "offset", "position", "scaleeffect", "rotationeffect"].contains(name) {
            return "Layout"
        }
        
        // Appearance modifiers
        if ["background", "foregroundcolor", "foregroundstyle", "opacity", "border", "shadow"].contains(name) {
            return "Appearance"
        }
        
        // Text modifiers
        if ["font", "bold", "italic", "underline", "strikethrough", "kerning", "tracking"].contains(name) {
            return "Text"
        }
        
        // Interaction modifiers
        if ["ontapgesture", "onlongpressgesture", "disabled", "gesture"].contains(name) {
            return "Interaction"
        }
        
        // Accessibility modifiers
        if name.hasPrefix("accessibility") {
            return "Accessibility"
        }
        
        // Animation modifiers
        if ["animation", "transition", "withanimation"].contains(name) {
            return "Animation"
        }
        
        // Environment modifiers
        if name.hasPrefix("environment") {
            return "Environment"
        }
        
        // Default category
        return "Other"
    }
}
