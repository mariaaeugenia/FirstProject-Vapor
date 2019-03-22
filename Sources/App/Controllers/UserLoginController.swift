import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

class UserLoginController: RouteCollection {
    //The function will throw if that process fails (which in this case will case a 400 Bad Request)
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(UserLogin.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserLoginController {
    
    func registerUserHandler(_ request: Request, newUser: UserLogin) throws -> Future<HTTPResponseStatus> {
        
        //We take the user from our request and search our database. We want to find all User objects whose e-mail is the same as the e-mail for the new user, and return the first one we find. Because the query and filter operations require an asynchronous search of our database (it’s very common for the database to reside in a different server than our HTTP routers, so that a single database can be shared amongst many instances of our HTTP routers), we’ll use a Future to indicate that our callback won’t be executed immediately.
        return try UserLogin.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            
            guard existingUser == nil else {
                //Vapor is built heavily on Swift’s error handling functionality, meaning you can throw from almost anywhere, and it will bubble up as an HTTP status code
                throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: nil)
            }
            
            //We’re going to use BCryptto hash the password that was given to us before storing it
            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = UserLogin(id: nil, email: newUser.email, password: hashedPassword)
            
            //Assuming nothing goes wrong, we’ll return an HTTPResponseStatus of .created (201)
            return persistedUser.save(on: request).transform(to: .created)
        }
    }
}
