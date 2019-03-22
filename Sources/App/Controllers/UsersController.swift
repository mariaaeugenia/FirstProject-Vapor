import Vapor


final class UsersController: RouteCollection {
    
    //Inside this method, we tell the router which path, HTTP method and handler function should be used for each endpoint
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getOneHandler)
        usersRoute.post(use: createHandler)
        usersRoute.put(User.parameter, use: updateHandler)
        usersRoute.delete(User.parameter, use: deleteHandler)
    }
    
    /*
     Since our User model already conforms Content protocol, a User instance can be generated from the JSON data of the HTTP body with req.content.decode(User.self).
     
     In addition, since the model also conforms SQLiteModel protocol, the instance can be saved into the SQLite database with user.save(on: req)
     
     We hook up these two operations with flatMap, because both of them are asynchronous.
     */
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { (user) in
            return user.save(on: req)
        }
    }
    
  //On one hand, we retrieve all instances of our User model by querying the database.
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).decode(User.self).all()
    }
  //On the other hand, since our Usermodel conforms Parameter protocol, req.parameters.next(User.self) will fetch the instance with the given identifier from the database.
    func getOneHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    //The flatMap function we use here is different from the previous one. It actually waits both of req.parameters.next(User.self) and req.content.decode(User.self) finish, and then executes the block. Within the block, we just update the instance with the new values and then save it into the database.
    func updateHandler(_ req: Request) throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.name = updatedUser.name
            user.username = updatedUser.username
            return user.save(on: req)
        }
    }
    ///We retrieve the instance with req.parameters.next(User.self) and delete it from the database with user.delete(on: req). Since there is no content to return, we can just provide a 204 No Content response with transform(to: HTTPStatus.noContent), which will convert Future<User> to Future<HTTPStatus>
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { (user) in
            return user.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }

}
