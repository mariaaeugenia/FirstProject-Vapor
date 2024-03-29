import Foundation
import Vapor
import Fluent
import Authentication

class TodoController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "todos")
        group.get(use: getTodosHandler)
        
        let basicAuthMiddleware = UserLogin.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = UserLogin.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.post(use: createTodoHandler)
        basicAuthGroup.delete(Todo.parameter, use: deleteTodoHandler)
    }
}

//MARK: Helper
private extension TodoController {
    
    func getTodosHandler(_ request: Request) throws -> Future<[Todo]> {
        return Todo.query(on: request).all()
    }
    
    func createTodoHandler(_ request: Request) throws -> Future<Todo> {
        return try request.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: request)
        }
    }
    
    func deleteTodoHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: request)
            }.transform(to: .ok)
    }
}
