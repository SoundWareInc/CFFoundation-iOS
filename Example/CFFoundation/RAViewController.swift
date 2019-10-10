//
//  RAViewController.swift
//  ios-foundation
//
//  Created by Robert on 7/6/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import UIKit

class RAViewController: UIViewController {
    
    var bottomLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setBottom(height: keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        setBottom(height: 0)
    }
    
    func setBottom(height: CGFloat) {
        DispatchQueue.main.async {
            self.bottomLayoutConstraint?.constant = height
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
