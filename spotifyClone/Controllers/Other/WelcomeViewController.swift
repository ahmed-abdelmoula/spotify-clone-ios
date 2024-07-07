//
//  WelcomeViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit

class WelcomeViewController: UIViewController {

   private let signInButton : UIButton  = {
        let button  = UIButton()
       button.backgroundColor = .white
       button.setTitle("Sign In with Spotify ", for: .normal)
       button.setTitleColor(.blue, for: .normal)
       return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapIn), for: .touchUpInside)
        
       
        
    }
//    Called to notify the view controller that its view has just laid out (presenter) its subviews.

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20,
                                    y: view.height - (50 + view.safeAreaInsets.bottom)
                                    , width: view.width - 40 ,
                                    height: 50)
    }
//     when we tap in this button we will be dirrected to login page of spotify (so we will load up
//    the sign in page
    /*
     1) first step click in button login that will direct us to auht controller
     2) execute signIn method that take a success paremtre from authView Controller
     */
    @objc func didTapIn (){
        let authView = AuthViewController()
        
        // here i have just dispatched the function to AuthViewController that will handle it
        // this closure is likely used to handle a completion event or callback in the AuthViewController
        authView.completionHandler = { [weak self] success in
            
    /*
    This line dispatches the handleSignIn(success:) method on the main queue asynchronously so it will  be executed on the main thread.
     */
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        authView.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(authView, animated: true)
    }
    
    private func handleSignIn (success :Bool) {
        // log user in or yell at them for error
        guard success else {
            let alert =  UIAlertController(title: "Oops", message: "Somthing went wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler: nil))
            present(alert, animated: true)
            return
        }
        // user logged in and access to profile
        let mainAppTabBarVC = TabBarViewController()
           mainAppTabBarVC.modalPresentationStyle = .fullScreen
           present(mainAppTabBarVC, animated: true)
        
    }

 

}
