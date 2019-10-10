//
//  ChatRoomViewController.swift
//  ios-foundation
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import UIKit
import CFFoundation

class ChatRoomViewController: RAViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTextFieldToBottomViewConstraint: NSLayoutConstraint!

    var chatSession: CFChatSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomLayoutConstraint = messageTextFieldToBottomViewConstraint
        messageTextField.becomeFirstResponder()
        setupTableView()
        setupChat()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupChat() {
        chatSession = CFFoundation.shared.joinChat(room: "room")
        chatSession?.delegate = self
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let message = messageTextField.text else { return }
        chatSession?.sendMessage(message: message)
        messageTextField.text = nil
        view.endEditing(true)
    }

}

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSession?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "DefaultCell")
        }
        guard let message = chatSession?.messages[indexPath.row] else { return cell! }

        if message.from == CFFoundation.shared.currentUser {
            cell?.textLabel?.text = nil
            cell?.detailTextLabel?.text = message.text
            
            cell?.textLabel?.textColor = .lightGray
            cell?.detailTextLabel?.textColor = .black
        } else {
            cell?.textLabel?.text = message.text
            cell?.detailTextLabel?.text = message.from?.username
            
            cell?.textLabel?.textColor = .black
            cell?.detailTextLabel?.textColor = .lightGray
        }
        return cell!
    }
}

extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ChatRoomViewController: ChatSessionDelegate {
    func didRecieveNewMessages(chatSession: CFChatSession, messages: [CFChatMessage]) {
        tableView.reloadData()
        print(messages)
    }
    
    func didJoinSession(chatSession: CFChatSession) {
        print(chatSession)
    }
    
    func didDisconnectSession(chatSession: CFChatSession) {
        print(chatSession)
    }
    
    func didSendMessage(chatSession: CFChatSession, message: String) {
        print(message)
    }
}
