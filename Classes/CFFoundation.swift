//
//  CFFoundation.swift
//  ios-foundation
//
//  Created by Robert on 8/22/19.
//  Copyright © 2019 avellar. All rights reserved.
//

import Foundation
import Combine

public class CFFoundation {
    
    public static let shared = CFFoundation()
    
    public var hostURL = "localhost:3000"
    
    public var isLoggedIn: Bool {
        return APISession.token != nil || APISession.customToken != nil
    }
    
    public var currentUser: CFUser? {
        set {
            APISession.currentUser = newValue
        } get {
            return APISession.currentUser
        }
    }
    
    public var currentUserID: String? {
        set {
            APISession.currentUserID = newValue
        } get {
            return APISession.currentUserID
        }
    }
    
    public var token: String? {
        return APISession.token
    }
    
    public var customToken: String? {
        set {
            APISession.customToken = newValue
        } get {
            return APISession.customToken
        }
    }
    
    public var chatSessions: [CFChatSession]?
    public var paymentsManager: PaymentsManager?
    
    //MARK: User Authentication
    public func signUp<T: CFUserProtocol>(email: String, username: String, password: String, userType: T.Type) -> Future<T,NetworkError> {
        return APIClient.signUp(email: email, username: username, password: password, userType: userType)
    }
    
    public func signIn<T: CFUserProtocol>(email: String, password: String, userType: T.Type) -> Future<T,NetworkError> {
        return APIClient.signIn(email: email, password: password, userType: userType)
    }
    
    public func logOut() {
        APISession.logOut()
    }
    
    //MARK: Chat
    public func joinChat(room: String) -> CFChatSession? {
        guard let user = currentUser else { return nil }
        let chatSession = CFChatSession(user: user, room: room)
        chatSessions?.append(chatSession)
        return chatSession
    }
    
    public func leave(chatSession: CFChatSession) {
        chatSessions?.removeAll(where: { (session) -> Bool in
            session == chatSession
        })
        chatSession.leave()
    }
    
    //MARK: Generic Request
    public func getItem<T: Codable>(
        responseType: T.Type,
        from route: String,
        parameters: [String : Any]? = nil) -> Future<T,NetworkError> {
        return APIClient.getItem(
            responseType: responseType,
            from: route,
            parameters: parameters)
    }
    
    public func getItems<T: Codable>(
        responseType: [T].Type,
        from route: String,
        parameters: [String : Any]? = nil) -> Future<[T], NetworkError> {
        return APIClient.getItems(
            responseType: responseType,
            from: route,
            parameters: parameters)
    }
    
    public func postItem<T: Codable, Y: Decodable>(
        itemToPost: T,
        responseType: Y.Type,
        to route: String) -> Future<Y, NetworkError> {
        return APIClient.postItem(
            itemToPost: itemToPost,
            responseType: responseType,
            to: route)
    }
    
    public func putItem<T: Codable, Y: Decodable>(
        itemToPut: T,
        responseType: Y.Type,
        to route: String) -> Future<Y, NetworkError> {
        return APIClient.putItem(
            itemToPut: itemToPut,
            responseType: responseType,
            to: route)
    }
    
    public func deleteItem(route: String) -> Future<String,NetworkError> {
        return APIClient.deleteItem(route: route)
    }
    
    //MARK: Session
    
    public func cancelAllRequest() {
        APIClient.session.cancelAllRequests()
    }
}
