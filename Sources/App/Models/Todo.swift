import Vapor
import FluentSQLite

final class Todo: Codable  {
    
    //MARK: Properties
    var id: Int?
    var title: String
    
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

extension Todo: Content {}
extension Todo: Parameter {}
extension Todo: SQLiteModel {}
extension Todo: Migration {}
