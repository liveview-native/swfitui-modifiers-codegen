/// Represents type information for SwiftUI modifiers.
///
/// This enum captures information about types used in modifier parameters
/// and return values, including generic types, protocols, and type aliases.
public indirect enum TypeInfo: Equatable, Sendable {
    /// A simple named type (e.g., "String", "CGFloat").
    case simple(name: String)
    
    /// A generic type with parameters (e.g., "Array<String>").
    case generic(name: String, parameters: [TypeInfo])
    
    /// An optional type.
    case optional(TypeInfo)
    
    /// A closure/function type.
    case closure(parameters: [TypeInfo], returnType: TypeInfo, isEscaping: Bool)
    
    /// The raw type string as it appears in the interface.
    public var rawType: String {
        switch self {
        case .simple(let name):
            return name
        case .generic(let name, let parameters):
            let params = parameters.map { $0.rawType }.joined(separator: ", ")
            return "\(name)<\(params)>"
        case .optional(let wrapped):
            return "\(wrapped.rawType)?"
        case .closure(let params, let returnType, let isEscaping):
            let paramStr = params.map { $0.rawType }.joined(separator: ", ")
            let prefix = isEscaping ? "@escaping " : ""
            return "\(prefix)(\(paramStr)) -> \(returnType.rawType)"
        }
    }
    
    /// The base type name (without generic parameters).
    public var baseName: String {
        switch self {
        case .simple(let name):
            return name
        case .generic(let name, _):
            return name
        case .optional(let wrapped):
            return wrapped.baseName
        case .closure:
            return "Closure"
        }
    }
    
    /// Generic type parameters if this is a generic type.
    public var genericParameters: [TypeInfo] {
        switch self {
        case .generic(_, let parameters):
            return parameters
        case .optional(let wrapped):
            return wrapped.genericParameters
        default:
            return []
        }
    }
    
    /// Whether this is an optional type.
    public var isOptional: Bool {
        if case .optional = self {
            return true
        }
        return false
    }
    
    /// Whether this is a closure/function type.
    public var isClosure: Bool {
        if case .closure = self {
            return true
        }
        return false
    }
    
    /// Closure parameter types if this is a closure.
    public var closureParameters: [TypeInfo] {
        if case .closure(let params, _, _) = self {
            return params
        }
        return []
    }
    
    /// Closure return type if this is a closure.
    public var closureReturnType: TypeInfo? {
        if case .closure(_, let returnType, _) = self {
            return returnType
        }
        return nil
    }
    
    /// Whether this is an escaping closure.
    public var isEscaping: Bool {
        if case .closure(_, _, let isEscaping) = self {
            return isEscaping
        }
        return false
    }
    

}
