//
//  ViewController.swift
//
//  Created by Robert on 6/29/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import UIKit
import CFFoundation

class ViewController: RAViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    @IBOutlet weak var stackViewToBottomLayoutConstraint: NSLayoutConstraint!
    
    var signUpMode = true {
        didSet {
            var submitButtonText = "Log In"
            var switchModeButtonText = "Don't have an account?"
            
            if signUpMode {
                usernameTextField.isHidden = false
                submitButtonText = "Sign Up"
                switchModeButtonText = "Already have an account?"
            } else {
                usernameTextField.isHidden = true
            }
            submitButton.setTitle(submitButtonText, for: [])
            switchModeButton.setTitle(switchModeButtonText, for: [])
        }
    }
    
    lazy var signInCompletionHandler: ((Result<CFUserProtocol,NetworkError>) -> Void) = { (result) in
        switch result {
        case .success(let user):
            self.loggedIn()
            print(user)
        case .failure(let error):
            self.loginFailed()
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomLayoutConstraint = stackViewToBottomLayoutConstraint
        emailTextField.becomeFirstResponder()
        signUpMode = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CFFoundation.shared.isLoggedIn {
            loggedIn()
        }
    }
    
    @IBAction func switchModeButtonTapped(_ sender: Any) {
        signUpMode = !signUpMode
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
        let password = passwordTextField.text,
            let username = usernameTextField.text else {
            return
        }
        if signUpMode {
            CFFoundation.shared.signUp(email: email, username: username, password: password, completionHandler: signInCompletionHandler)
        } else {
            CFFoundation.shared.signIn(email: email, password: password, completionHandler: signInCompletionHandler)
        }
    }
  
    func loggedIn() {
        view.backgroundColor = .green
        performSegue(withIdentifier: "ChatRoomSeque", sender: nil)
    }
    
    func loginFailed() {
        view.backgroundColor = .red
    }

}
