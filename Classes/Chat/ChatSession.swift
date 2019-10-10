//
//  ChatManager.swift
//
//  Created by Robert on 6/30/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import SocketIO

public protocol ChatSessionDelegate {
    func didRecieveNewMessages(chatSession: ChatSession, messages: [Message])
    func didJoinSession(chatSession: ChatSession)
    func didDisconnectSession(chatSession: ChatSession)
    func didSendMessage(chatSession: ChatSession, message: String)
}

public class ChatSession: Equatable {
    
    public var delegate: ChatSessionDelegate?
    
    var manager = SocketManager(socketURL: URL(string: Configuration.API.BaseChatURL)!, config: [.log(true), .compress])
    var socket: SocketIOClient?
    
    var user: User
    var room: String
    public var messages = [Message]()

    required init(user: User, room: String) {
        self.user = user
        self.room = room
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        socket = manager.defaultSocket
        
        socket?.on(clientEvent: .connect) { [weak self]data, ack in
            guard let self = self else { return }
            self.join()
        }
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            guard let self = self else { return }
            self.delegate?.didDisconnectSession(chatSession: self)
        }
        socket?.on("newMessage") { [weak self] data, ack in
            guard let self = self else { return }
            var newMessages = [Message]()
            
            for i in data {
                if let messageData = i as? [String : Any] {
                    let jsonData = try! JSONSerialization.data(withJSONObject: messageData, options: .prettyPrinted)
                    guard let message = try? JSONDecoder().decode(Message.self, from: jsonData) else {
                        print("Error: Couldn't decode data into Message")
                        return
                    }
                    newMessages.append(message)
                }
            }
            self.messages.append(contentsOf: newMessages)
            self.delegate?.didRecieveNewMessages(chatSession: self, messages: newMessages)
        }
        
        socket?.connect()
    }
    
    public func join() {
        guard let userData = try? user.asDictionary() else { return }
        socket?.emit("join", ["user": userData, "room": room], completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.didJoinSession(chatSession: self)
        })
    }
    
    
    public func leave() {
        guard let userData = try? user.asDictionary() else { return }
        socket?.emit("leave", ["user": userData, "room": room], completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.didDisconnectSession(chatSession: self)
        })
    }
    
    public func sendMessage(message: String) {
        guard let userData = try? user.asDictionary() else { return }
        socket?.emit("createMessage", ["text": message, "user": userData], completion: { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSendMessage(chatSession: self, message: message)
        })
    }
}

extension ChatSession {
    public static func == (lhs: ChatSession, rhs: ChatSession) -> Bool {
        return lhs.room == rhs.room
    }
}
