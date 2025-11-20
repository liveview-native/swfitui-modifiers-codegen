# Swift and SwiftUI Programming Skill

## Purpose

This skill ensures you write **highest quality, well-tested, highly performant, and properly documented Swift and SwiftUI code** using Swift's standard library and modern SwiftUI patterns.

---

## When to Use This Skill

Load this skill automatically when:
- Writing or refactoring Swift code
- Implementing SwiftUI views and components
- Designing types, protocols, and APIs
- Managing state and data flow in SwiftUI
- Writing tests
- Documenting public APIs

---

## Core Philosophy

**Modern Swift and SwiftUI emphasizes:**
1. **Safety** - Type safety, optionals, error handling
2. **Clarity** - Readable, expressive code
3. **Performance** - Efficient state management, minimal recomposition
4. **Declarative UI** - Describe what you want, not how to build it

---

# Part 1: Code Quality

## Naming Conventions

```swift
// Types: PascalCase
struct UserProfile { }
class NetworkManager { }
enum LoadingState { }
protocol DataSource { }

// Functions, variables, parameters: camelCase
func fetchUserData(userId: String) async throws -> User { }
func calculateTotal(items: [Item]) -> Double { }
var isLoading: Bool = false
let itemCount: Int = 10

// Constants: camelCase (same as variables)
let maxRetryCount: Int = 3
let defaultTimeout: TimeInterval = 30.0

// Private: Use 'private' or 'fileprivate'
private func internalHelper() { }
private var internalState: State = .idle

// SwiftUI Views: PascalCase
struct ContentView: View { }
struct ProfileHeaderView: View { }
```

---

## Error Handling

### Domain-Specific Error Types

```swift
// Define clear, specific errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(statusCode: Int)
    case timeout
}

// Custom error with associated values
enum ValidationError: Error {
    case missingField(String)
    case invalidFormat(field: String, reason: String)
    case outOfRange(field: String, min: Int, max: Int)
}

// Conform to LocalizedError for user-facing messages
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Failed to decode response"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .timeout:
            return "Request timed out"
        }
    }
}
```

### Modern Error Handling (async/await)

```swift
// ✅ GOOD: Using async/await with throws
func fetchUser(id: String) async throws -> User {
    guard let url = URL(string: "https://api.example.com/users/\(id)") else {
        throw NetworkError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.serverError(
            statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0
        )
    }
    
    do {
        return try JSONDecoder().decode(User.self, from: data)
    } catch {
        throw NetworkError.decodingFailed
    }
}

// Usage
Task {
    do {
        let user = try await fetchUser(id: "123")
        print("Fetched user: \(user.name)")
    } catch let error as NetworkError {
        print("Network error: \(error.localizedDescription)")
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

### Result Type for Non-Async Code

```swift
// Result type for synchronous operations
func parseConfiguration(_ data: Data) -> Result<Configuration, ValidationError> {
    guard !data.isEmpty else {
        return .failure(.missingField("data"))
    }
    
    do {
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        return .success(config)
    } catch {
        return .failure(.invalidFormat(field: "data", reason: error.localizedDescription))
    }
}

// Usage
switch parseConfiguration(data) {
case .success(let config):
    print("Parsed config: \(config)")
case .failure(let error):
    print("Parse error: \(error)")
}
```

---

## Memory Management

### Automatic Reference Counting (ARC)

```swift
// Swift uses ARC - no manual memory management needed
// But be aware of strong reference cycles

// ✅ GOOD: Weak reference to avoid retain cycle
class ViewController {
    var onDismiss: (() -> Void)?
    
    func setupDismissHandler() {
        // Use weak self to avoid cycle
        onDismiss = { [weak self] in
            guard let self = self else { return }
            self.dismiss()
        }
    }
}

// ✅ GOOD: Unowned when you know the reference will never be nil
class Child {
    unowned let parent: Parent  // Parent always outlives Child
    
    init(parent: Parent) {
        self.parent = parent
    }
}

// ❌ BAD: Creates retain cycle
class BadExample {
    var closure: (() -> Void)?
    
    func setup() {
        closure = {
            self.doSomething()  // Captures self strongly - cycle!
        }
    }
}
```

### Value Types vs Reference Types

```swift
// Value types (struct, enum) - Copied on assignment
struct Point {
    var x: Double
    var y: Double
}

var point1 = Point(x: 0, y: 0)
var point2 = point1  // Copy made
point2.x = 10
// point1.x is still 0

// Reference types (class) - Shared reference
class MutablePoint {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

let refPoint1 = MutablePoint(x: 0, y: 0)
let refPoint2 = refPoint1  // Same reference
refPoint2.x = 10
// refPoint1.x is now 10 (same object)

// ✅ Prefer struct for data models
struct User {
    let id: String
    var name: String
    var email: String
}

// ✅ Use class for shared state or identity
class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
}
```

---

## Type Safety

### Optionals

```swift
// ✅ GOOD: Safe unwrapping with if let
if let user = optionalUser {
    print("User name: \(user.name)")
}

// ✅ GOOD: Guard for early exit
func processUser(_ user: User?) {
    guard let user = user else {
        print("No user provided")
        return
    }
    
    // user is non-optional here
    print("Processing: \(user.name)")
}

// ✅ GOOD: Nil coalescing for defaults
let userName = optionalUser?.name ?? "Guest"

// ✅ GOOD: Optional chaining
let cityName = user?.address?.city?.name

// ❌ BAD: Force unwrapping (crashes if nil)
let user = optionalUser!  // Don't do this unless you're 100% sure
```

### Type Inference and Explicit Types

```swift
// ✅ Type inference is fine for simple cases
let count = 10  // Int inferred
let name = "John"  // String inferred

// ✅ Explicit types for clarity
let timeout: TimeInterval = 30.0
let items: [Item] = []
let handler: ((Result<User, Error>) -> Void)? = nil

// ✅ Explicit when ambiguous
let point = CGPoint(x: 0, y: 0)  // Could be CGPoint or custom Point
```

### Enums for State Management

```swift
// ✅ Use enums for mutually exclusive states
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}

// Usage in SwiftUI
struct ContentView: View {
    @State private var state: LoadingState<[User]> = .idle
    
    var body: some View {
        switch state {
        case .idle:
            Text("Tap to load")
                .onTapGesture { loadData() }
        case .loading:
            ProgressView()
        case .loaded(let users):
            List(users) { user in
                Text(user.name)
            }
        case .failed(let error):
            Text("Error: \(error.localizedDescription)")
        }
    }
    
    func loadData() {
        state = .loading
        Task {
            do {
                let users = try await fetchUsers()
                state = .loaded(users)
            } catch {
                state = .failed(error)
            }
        }
    }
}
```

---

## SwiftUI Patterns

### View Composition

```swift
// ✅ GOOD: Break down complex views into smaller components
struct UserProfileView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            ProfileHeaderView(user: user)
            ProfileStatsView(user: user)
            ProfileBioView(bio: user.bio)
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### State Management

```swift
// @State for local view state
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}

// @Binding for child view state
struct CounterButtonView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Increment") {
            count += 1
        }
    }
}

// @StateObject for observable objects (owned by view)
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            Text(item.title)
        }
        .onAppear {
            viewModel.loadItems()
        }
    }
}

// @ObservedObject for observable objects (passed in)
struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        Text(viewModel.title)
    }
}

// @Environment for system-wide values
struct MyView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Current scheme: \(colorScheme == .dark ? "Dark" : "Light")")
            Button("Close") {
                dismiss()
            }
        }
    }
}
```

### View Modifiers

```swift
// ✅ Extract reusable modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// Usage
Text("Hello")
    .cardStyle()

// ✅ Conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// Usage
Text("Hello")
    .if(isHighlighted) { view in
        view.background(Color.yellow)
    }
```

---

# Part 2: Performance

## SwiftUI Performance

### Minimize View Updates

```swift
// ✅ GOOD: Separate state to minimize redraws
struct OptimizedListView: View {
    @State private var items: [Item] = []
    @State private var selectedItemID: Item.ID?
    
    var body: some View {
        List(items) { item in
            ItemRow(item: item, isSelected: item.id == selectedItemID)
                .onTapGesture {
                    selectedItemID = item.id
                }
        }
    }
}

struct ItemRow: View {
    let item: Item
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(item.title)
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}

// ❌ BAD: Passing entire state object causes unnecessary redraws
struct BadListView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        List(viewModel.items) { item in
            // Every item redraws when ANY viewModel property changes
            ItemRow(item: item, viewModel: viewModel)
        }
    }
}
```

### Lazy Loading

```swift
// ✅ Use LazyVStack/LazyHStack for large lists
struct LazyListView: View {
    let items: [Item]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
        }
    }
}

// ✅ Use LazyVGrid for grids
struct GridView: View {
    let items: [Item]
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    ItemCard(item: item)
                }
            }
        }
    }
}
```

### Task Management

```swift
// ✅ Cancel tasks when view disappears
struct DataView: View {
    @State private var data: [Item] = []
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        List(data) { item in
            Text(item.title)
        }
        .task {
            // Automatically cancelled when view disappears
            do {
                data = try await fetchData()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

// ✅ Manual task management
struct ManualTaskView: View {
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        Text("Loading...")
            .onAppear {
                task = Task {
                    await loadData()
                }
            }
            .onDisappear {
                task?.cancel()
            }
    }
    
    func loadData() async {
        // Check for cancellation
        guard !Task.isCancelled else { return }
        
        // Long running operation
    }
}
```

---

# Part 3: Testing

## Test Coverage Requirements

Every public API MUST have tests for:
1. **Happy path** - Normal, expected usage
2. **Edge cases** - Empty input, boundary conditions, nil values
3. **Error cases** - Invalid input, network errors, decoding failures
4. **Async behavior** - Concurrent operations, cancellation

## Unit Testing

```swift
import XCTest
@testable import MyApp

// Test naming: test_unitOfWork_stateUnderTest_expectedBehavior
class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = UserViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_loadUsers_withValidData_populatesUsers() async throws {
        // Arrange
        let expectedUsers = [
            User(id: "1", name: "Alice"),
            User(id: "2", name: "Bob")
        ]
        mockNetworkService.usersToReturn = expectedUsers
        
        // Act
        await sut.loadUsers()
        
        // Assert
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertEqual(sut.users[0].name, "Alice")
        XCTAssertEqual(sut.users[1].name, "Bob")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Error Tests
    
    func test_loadUsers_withNetworkError_setsError() async throws {
        // Arrange
        mockNetworkService.shouldFail = true
        mockNetworkService.errorToThrow = NetworkError.noData
        
        // Act
        await sut.loadUsers()
        
        // Assert
        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Edge Cases
    
    func test_loadUsers_withEmptyResponse_handlesGracefully() async throws {
        // Arrange
        mockNetworkService.usersToReturn = []
        
        // Act
        await sut.loadUsers()
        
        // Assert
        XCTAssertTrue(sut.users.isEmpty)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
}

// Mock network service
class MockNetworkService: NetworkServiceProtocol {
    var usersToReturn: [User] = []
    var shouldFail = false
    var errorToThrow: Error?
    
    func fetchUsers() async throws -> [User] {
        if shouldFail {
            throw errorToThrow ?? NetworkError.noData
        }
        return usersToReturn
    }
}
```

## SwiftUI View Testing

```swift
import XCTest
import ViewInspector  // Third-party library for view testing
@testable import MyApp

class ContentViewTests: XCTestCase {
    func test_contentView_displaysUserName() throws {
        // Arrange
        let user = User(id: "1", name: "Alice")
        let sut = ContentView(user: user)
        
        // Act
        let text = try sut.inspect().find(text: "Alice")
        
        // Assert
        XCTAssertNotNil(text)
    }
    
    func test_button_whenTapped_triggersAction() throws {
        // Arrange
        var actionTriggered = false
        let sut = ContentView {
            actionTriggered = true
        }
        
        // Act
        try sut.inspect().find(button: "Submit").tap()
        
        // Assert
        XCTAssertTrue(actionTriggered)
    }
}
```

## TDD Workflow

1. **Understand requirements** - Know what you're building
2. **Write failing test** - Test the desired behavior
3. **Minimal implementation** - Make it compile
4. **Make test pass** - Implement the feature
5. **Add edge case tests** - Cover all scenarios
6. **Refactor** - Clean up code without changing tests

---

# Part 4: Documentation

## Documentation Requirements

**Public API MUST be documented.**
**Private/internal code MAY skip documentation.**

### What to Document

✅ **MUST document:**
- Public functions, methods, properties
- Public types (struct, class, enum, protocol)
- Public initializers
- Complex algorithms

❌ **MAY skip documentation:**
- Private members
- Self-explanatory code
- Test code
- Computed properties with obvious purpose

### Documentation Comments

```swift
/// Fetches user data from the remote server.
///
/// This method performs an asynchronous network request to retrieve
/// user information. It handles authentication, rate limiting, and
/// error conditions automatically.
///
/// - Parameter userId: The unique identifier of the user to fetch.
/// - Returns: A `User` object containing the user's information.
/// - Throws: `NetworkError` if the request fails or the response is invalid.
///
/// ## Example
/// ```swift
/// do {
///     let user = try await fetchUser(id: "123")
///     print("User name: \(user.name)")
/// } catch {
///     print("Failed to fetch user: \(error)")
/// }
/// ```
public func fetchUser(id: String) async throws -> User {
    // Implementation
}

/// Represents a user in the system.
///
/// A user contains personal information and authentication details.
/// Users are uniquely identified by their `id` property.
public struct User: Identifiable {
    /// The unique identifier for this user.
    public let id: String
    
    /// The user's display name.
    public var name: String
    
    /// The user's email address.
    public var email: String
    
    /// Creates a new user with the specified information.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the user.
    ///   - name: The user's display name.
    ///   - email: The user's email address.
    public init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
```

### MARK Comments for Organization

```swift
class UserViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: UserViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Setup code
    }
    
    private func bindViewModel() {
        // Binding code
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        // Action code
    }
}
```

---

# Part 5: Common Patterns

## Protocol-Oriented Programming

```swift
// Define protocols for abstraction
protocol DataSource {
    associatedtype Item
    func fetchItems() async throws -> [Item]
}

// Implement concrete types
struct UserDataSource: DataSource {
    func fetchItems() async throws -> [User] {
        // Implementation
    }
}

// Use protocol extensions for default behavior
extension DataSource {
    func fetchItemsWithRetry(maxAttempts: Int = 3) async throws -> [Item] {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await fetchItems()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
                }
            }
        }
        
        throw lastError ?? NetworkError.timeout
    }
}
```

## Async/Await Patterns

```swift
// ✅ Sequential async operations
func loadUserProfile() async throws -> UserProfile {
    let user = try await fetchUser()
    let posts = try await fetchPosts(for: user.id)
    let followers = try await fetchFollowers(for: user.id)
    
    return UserProfile(user: user, posts: posts, followers: followers)
}

// ✅ Parallel async operations
func loadUserProfile() async throws -> UserProfile {
    let user = try await fetchUser()
    
    async let posts = fetchPosts(for: user.id)
    async let followers = fetchFollowers(for: user.id)
    
    let (loadedPosts, loadedFollowers) = try await (posts, followers)
    
    return UserProfile(user: user, posts: loadedPosts, followers: loadedFollowers)
}

// ✅ Task groups for dynamic parallel operations
func loadAllUsers(_ ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }
        
        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

## SwiftUI Animation

```swift
// ✅ Simple animations
struct AnimatedView: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: isExpanded ? 200 : 100, height: 100)
                .animation(.spring(), value: isExpanded)
            
            Button("Toggle") {
                isExpanded.toggle()
            }
        }
    }
}

// ✅ Explicit animations
struct ExplicitAnimationView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 100 * scale, height: 100 * scale)
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    scale = scale == 1.0 ? 1.5 : 1.0
                }
            }
    }
}
```

---

# Part 6: Common Mistakes to Avoid

## ❌ Force Unwrapping

```swift
// WRONG: Crashes if nil
let user = optionalUser!
let name = user.name!

// RIGHT: Safe unwrapping
guard let user = optionalUser else { return }
let name = user.name ?? "Unknown"
```

## ❌ Retain Cycles

```swift
// WRONG: Creates retain cycle
class ViewController {
    var completion: (() -> Void)?
    
    func setup() {
        completion = {
            self.dismiss()  // Retains self
        }
    }
}

// RIGHT: Use weak or unowned
class ViewController {
    var completion: (() -> Void)?
    
    func setup() {
        completion = { [weak self] in
            self?.dismiss()
        }
    }
}
```

## ❌ Main Thread Violations

```swift
// WRONG: UI update on background thread
Task.detached {
    let data = await fetchData()
    self.items = data  // Crash! Not on main thread
}

// RIGHT: Use MainActor
Task.detached {
    let data = await fetchData()
    await MainActor.run {
        self.items = data
    }
}

// BETTER: Mark property with @MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func loadItems() async {
        let data = await fetchData()
        items = data  // Safe - ViewModel is @MainActor
    }
}
```

---

# Quick Reference

## Checklist for Every Function

- [ ] Correct naming (camelCase)
- [ ] Clear parameter names
- [ ] Return type specified
- [ ] Error handling (throws or Result)
- [ ] Documentation (if public)
- [ ] Tests (happy path, edge cases, errors)

## Checklist for Every View

- [ ] Correct naming (PascalCase, ends with "View")
- [ ] Proper state management (@State, @Binding, @StateObject)
- [ ] Broken into smaller components
- [ ] Modifiers in logical order
- [ ] Accessibility support
- [ ] Preview provider

## Performance Checklist

- [ ] Minimize view body computation
- [ ] Use lazy loading for large lists
- [ ] Cancel tasks on disappear
- [ ] Avoid unnecessary state updates
- [ ] Profile with Instruments if needed

---

**Remember**: Write safe, clear, testable code. Document public APIs. Performance matters, but clarity and correctness come first.
