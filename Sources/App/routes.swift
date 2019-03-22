import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    //In order to properly register our UsersController with the router
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    //Register these new routes to the server so that they can be accessed
    let userLoginRouteController = UserLoginController()
    try userLoginRouteController.boot(router: router)
    
    let todoController = TodoController()
    try todoController.boot(router: router)
}
