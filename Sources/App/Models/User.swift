import Vapor
import FluentSQLite
import Fluent
import Authentication


final class User: Codable {
    var id: Int?
    var name: String
    var username: String
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}
extension User: SQLiteModel {}
extension User: Migration {}

/*Considering that our CRUD endpoints should be able to receive JSON data as the HTTP body and return the responses with the JSON format, Vapor provides Content protocol, which allows us to convert the model to the JSON format. Since our User model has already conformed Codable protocol
 */
extension User: Content {}
// in order to retrieve User model more easily with our endpoints
extension User: Parameter {}
extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.name
    static let passwordKey: WritableKeyPath<User, String> = \.username
}
