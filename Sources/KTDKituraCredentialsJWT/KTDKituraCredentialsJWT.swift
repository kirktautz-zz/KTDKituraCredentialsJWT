//
//  KTDKituraCredentialsJWT.swift
//
//  Modified IBM's Kitura-Credentials
//
//  Created by Kirk Tautz on 1/8/18.
//
//

import Foundation
import Kitura
import KituraNet
import Credentials
import JWT
import SwiftyJSON

public class KTDKituraCredentialsJWT: CredentialsPluginProtocol {
    
    // the name of the plugin
    public var name: String {
        return "JWT"
    }
    
    // An indication as to whether the plugin is redirecting or not.
    public var redirecting: Bool {
        return false
    }
    
    // user profile cache
    public var usersCache: NSCache<NSString, BaseCacheElement>?
    
    // The secret key for the JWT
    private let secretKey: String
    
    // public init - get JWT secret
    public init(secretKey: String) {
        
        self.secretKey = secretKey
    }
    
    
    /// Authenticate incoming request using JSON Web Tokens (JWT).
    ///
    /// - Parameter request: The `RouterRequest` object used to get information
    ///                     about the request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                       request.
    /// - Parameter options: The dictionary of plugin specific options.
    /// - Parameter onSuccess: The closure to invoke in the case of successful authentication.
    /// - Parameter onFailure: The closure to invoke in the case of an authentication failure.
    /// - Parameter onPass: The closure to invoke when the plugin doesn't recognize the
    ///                     authentication data in the request.
    /// - Parameter inProgress: The closure to invoke to cause a redirect to the login page in the
    ///                     case of redirecting authentication.
    public func authenticate (request: RouterRequest, response: RouterResponse,
                              options: [String:Any], onSuccess: @escaping (UserProfile) -> Void,
                              onFailure: @escaping (HTTPStatusCode?, [String:String]?) -> Void,
                              onPass: @escaping (HTTPStatusCode?, [String:String]?) -> Void,
                              inProgress: @escaping () -> Void){
        
        
        // Validate there is an Authorization header
        guard let authorizationHeader = request.headers["Authorization"] else {
            onPass(.badRequest,["WWW-Authenticate" : "Token not supplied"])
            return
            
        }
        
        // confirm there are two parts to the header
        let authComponents = authorizationHeader.components(separatedBy: " ")
        guard authComponents.count == 2, authComponents[0] == "Bearer" else {
            onPass(.badRequest, ["WWW-Authenticate" : "Token not supplied"])
            return
        }
        
        // grab the token from the header
        let suppliedToken = authComponents[1]
        
        do {
            
            // verify the token
            let receivedToken = try JWT(token: suppliedToken)
            try receivedToken.verifySignature(using: HS512(key: secretKey.bytes))
            
            
            // get information from the payload and set it to the UserProfile
            // payload must contain at least a username and id
            let payload = receivedToken.payload
            if let displayName = payload["display_name"]?.string, let userId = payload["user_id"]?.string {
                
                onSuccess(UserProfile(id: userId, displayName: displayName, provider: "JWT"))
            } else {
                onFailure(.badRequest, nil)
            }
            
            
        } catch {
            onFailure(HTTPStatusCode.unauthorized, nil)
        }
        
        onFailure(HTTPStatusCode.badRequest, nil)
    }
    
}

