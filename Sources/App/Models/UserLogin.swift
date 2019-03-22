import Vapor
import Fluent
import FluentSQLite
import Authentication

struct UserLogin: Codable {
    
    var id: UUID?
    private(set) var email: String
    private(set) var password: String
}

extension UserLogin: Content {}
extension UserLogin: SQLiteUUIDModel {}
extension UserLogin: Migration {}
extension UserLogin: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<UserLogin, String> = \.email
    static let passwordKey: WritableKeyPath<UserLogin, String> = \.password
}
