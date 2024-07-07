//
//  AuthManager.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//
// this file is in order to making sure the user is sign in
//managers typically refers to the components responsible for coodinating and managing specific aspects of the application's functionality (managers are objects from the app allow us to perform operation across the whole app 

import Foundation
// this object is responsible for handling all the authentification related logic   
final class AuthManager {
    static let shared = AuthManager()
    
    private var refreshingToken = false
    struct Constants {
        static let clientID = "f75a375c73864402ba83737748761e5c"
        static let clientSecret = "abb991226df84130bca652fcf7b2e48a"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://github.com/ahmed-abdelmoula"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    private init() {}
    var isSingedIn :Bool {
        get {
            return acccessToken != nil
        }
    }
    //    show dialoag true in order request every time to accepet the scope (permision)
    public var signInUrl : URL? {
        let baseUrl = "https://accounts.spotify.com/authorize"
        let stringURL = "\(baseUrl)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=true"
        return URL(string: stringURL)
    }
    
    private var acccessToken :String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken :String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate : Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    
    private var shouldRefreshToken : Bool {
        get {
            guard let expirationDate = tokenExpirationDate else {
                return false
            }
            let  currentDate = Date()
            print(currentDate)
            let fiveMin : TimeInterval = 300
            return currentDate.addingTimeInterval(fiveMin) >= expirationDate // if we add five min to our current date did we reah
            // the expiration Date if yes then refresh else no still valid
        }
    }
    //    completion to let the caller know that it's suceeeded
    public func exchangeCodeForToken(code : String ,
                                     completion : @escaping ((Bool)->Void)
    ){
        
        // get token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        // prepartion of request body parametre and set with httpBody
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
            
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // preapartion of header Parametre
        let  basicToken  = Constants.clientID+":"+Constants.clientSecret
        // so that we can encode a string to base 64 we need to transform it to data first
        let data = basicToken.data(using: .utf8)
        //encoding
        guard let base64String =  data?.base64EncodedString() else {
            print("failed to get base 64")
            completion(false)
            return
        }
        // setting the request header
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic "+base64String, forHTTPHeaderField: "Authorization")
        
        //     setting the request body
        //        The data sent as the message body of a request, such as for an HTTP POST request.
        request.httpBody = components.query?.data(using: .utf8)
        
        // Creates a task that retrieves data from a specific URL (content of URL) and calls a handler upon completion.
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, err in
            guard let data = data else {
                completion(false)
                return
            }
            do {
              //  JSONSerialization.jsonObject(with: data , options: .allowFragments)
                // convert the data into json , we have created a codable object so we can automaticly convert json to object
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print(err?.localizedDescription ?? "Error Ocured")
                completion(false)
            }
        }
        // kick off the api call
        task.resume()
    
}
    public func refreshAccesTokenIfNeccessary(completion : ((Bool) -> Void)? ) {
        // checcking if we are in the action of refreshing the token
        guard !refreshingToken else { return }

        // a small check so we don't refresh token every time we enter the app : shouldRefreshTOken will be false (so no need to refresh the token) in two case even accessToken is still valid so no need to refresh it
        // or we don't have a token registered
           guard shouldRefreshToken else {
               completion?(true)
               return
           }
           guard let refreshToken = self.refreshToken else { return }
           guard let url = URL(string: Constants.tokenAPIURL) else { return }
           refreshingToken = true
           var components = URLComponents()
           components.queryItems = [
               URLQueryItem(name: "grant_type", value: "refresh_token"),
               URLQueryItem(name: "refresh_token", value: refreshToken)
           ]
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           let basicToken = Constants.clientID+":"+Constants.clientSecret
           let data = basicToken.data(using: .utf8)
           guard let base64String = data?.base64EncodedString() else {
               print("Failed to get base64")
               return
           }
           request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
           request.httpBody = components.query?.data(using: .utf8)
           let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, err in
               self?.refreshingToken = false
               guard let data = data else {
                   completion?(false)
                   return
               }
               do {
                   let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                   self?.onRefreshBlocks.forEach( { $0(result.access_token)})
                   self?.onRefreshBlocks.removeAll()
                   self?.cacheToken(result: result)
                   print("refresh succesfuly")
                   completion?(true)
               } catch {
                   print(err?.localizedDescription as Any)
                   completion?(false)
               }
           }
           task.resume()
}
    
    private var onRefreshBlocks = [((String) -> Void)]()
        // this function return for us or suplies us with a valid token  and this the necessery function 
        public func withValidToken(completion: @escaping ((String) -> Void)) {
           // the action of guard let if condition true then continue and procede else return
            guard !refreshingToken else { // if we are not in the action of refreshing token so continue
                onRefreshBlocks.append(completion)
                return
            }
            if shouldRefreshToken {
                refreshAccesTokenIfNeccessary { [weak self] success in
                    if success {
                        if let token = self?.acccessToken {
                            completion(token)
                        }
                    }
                }
            } else if let token = acccessToken {
               // print("should it ??\(tokenExpirationDate) ")

                completion(token)
            }
        }
    
private func storeToken(){
    
}
private func cacheToken (result :AuthResponse) {
    UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
    // we exectue refreshTOken func the returned result will  have a nil on refresh token because we are trying to generate an access token and the returned result will not have a refreshTOken field on it 
    // if we didn't check refresh token in result if exsiste or not , it will overide the refresh token with nil
    if let _refreshToken = result.refresh_token {
        UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
    }
    UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
}
    func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expires_in")
        completion(true)
    }

}
