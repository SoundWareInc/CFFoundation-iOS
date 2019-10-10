//
//  CFFoundation.swift
//  ios-foundation
//
//  Created by Robert on 8/22/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation

public class CFFoundation {
    
    public static let shared = CFFoundation()
    
    public var isLoggedIn: Bool {
        return APISession.currentUser != nil
    }
    public var currentUser: User? {
        return APISession.currentUser
    }
    public var chatSessions: [ChatSession]?
    
    //MARK: User Authentication
    public func signUp(email: String, username: String, password: String, completionHandler: @escaping (Result<User,NetworkError>) -> Void) {
        APIClient.signUp(email: email, username: username, password: password, completionHandler: completionHandler)
    }
    
    public func signIn(email: String, password: String, completionHandler: @escaping (Result<User,NetworkError>) -> Void) {
        APIClient.signIn(email: email, password: password, completionHandler: completionHandler)
    }
    
    public func logOut() {
        APISession.logOut()
    }
    
    //MARK: Chat
    public func joinChat(room: String) -> ChatSession? {
        guard let user = currentUser else { return nil }
        let chatSession = ChatSession(user: user, room: room)
        chatSessions?.append(chatSession)
        return chatSession
    }
    
    public func leave(chatSession: ChatSession) {
        chatSessions?.removeAll(where: { (session) -> Bool in
            session == chatSession
        })
        chatSession.leave()
    }
}
