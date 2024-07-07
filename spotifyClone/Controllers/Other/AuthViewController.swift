//
//  AuthViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit
import WebKit
// this where we gonna load up the authentifccation page in web view
class AuthViewController: UIViewController , WKNavigationDelegate{
    
    // this gone be a closure that take a bool as paremtre and retunr void  and this gona tell our welcome controller that the user has succesfuly sign in
    public var completionHandler : ((Bool)-> Void)?

    /*
     { [weak self] success in
         DispatchQueue.main.async {
             self?.handleSignIn(success: success)
         }
     }
     */
    
    private let webView : WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config  = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        //        create a webview and intilize it with necessery frame and configuration )
        let webView = WKWebView( frame: .zero, configuration: config )
        return webView
    }()
    // we want to return smth from this auth controller to other controller so it knows that
    // we succfuly done and login in
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor =  .systemBackground
        //    Provide a delegate object when you want to manage or restrict navigation in your web content, track the progress of navigation requests, and handle authentication challenges for any new content. The object you specify must conform to the WKNavigationDelegate protocol.
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInUrl else {
            return
        }
        webView.load(URLRequest (url : url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    // tell the deligate that navigation from main frame has started and we have to get the code
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //        get the url that started to load
        guard let url = webView.url else {
            return
        }
        // if url has a parametre named code we want to exctract it get the code and exchange it for access token
        let component = URLComponents(string: url.absoluteString)
        //        var queryItems: [URLQueryItem]? { get set } it return optional so must be wrapped
        guard  let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else {
            return
        }
        AuthManager.shared.exchangeCodeForToken(code: code, completion: { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.completionHandler?(success)
            }
            
        })
    }
    
    
    
    
    
}
