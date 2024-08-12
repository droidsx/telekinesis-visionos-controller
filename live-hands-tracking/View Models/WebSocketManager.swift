//
//  WebSocketManager.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import Foundation
import SwiftUI

class WebSocketManager: NSObject, ObservableObject, Service {
    
    @Published private var webSocketTask: URLSessionWebSocketTask?
    @Published private var successfulMessageCount: Int = 0
    
    private var urlSession: URLSession!
    
    var inferredStatus: InferredStatus {
        .init(taskState: webSocketTask?.state ?? .suspended, didPingAtLeastOnce: successfulMessageCount > 0)
    }
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect(url: URL) {
        self.resetMessageCount()
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func sendMessage(data: [String: Any]) {
//        self.log("ℹ️ Attempting to send message: \(data)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask?.send(message) { error in
                if let error = error {
                    self.log("⛔️ WebSocket sending error: \(error)")
                } else {
//                    self.log("✅ Message sent with no errors.")
                    DispatchQueue.main.async {
                        self.successfulMessageCount += 1
                    }
                }
            }
        } catch {
            self.log("⛔️ Error serializing JSON: \(error)")
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.log("⛔️ WebSocket receiving error: \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.log("✅ Received data: \(data)")
                case .string(let text):
                    self?.log("✅ Received text: \(text)")
                @unknown default:
                    fatalError()
                }
                self?.receiveMessage()
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.resetMessageCount()
    }
    
    func resetMessageCount() {
        self.successfulMessageCount = 0
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.log("⚠️ WebSocket closed with code: \(closeCode)")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.log("✅ WebSocket connected")
    }
}

extension WebSocketManager {
    enum InferredStatus: String {
        case disconnected
        case connected
        case connecting
        
        init(taskState: URLSessionTask.State, didPingAtLeastOnce: Bool) {
            switch taskState {
            case .running:
                if didPingAtLeastOnce {
                    self = .connected
                } else {
                    self = .connecting
                }
            case .suspended, .canceling, .completed:
                self = .disconnected
            @unknown default:
                self = .disconnected
            }
        }
        
        var associatedColor: Color {
            switch self {
            case .disconnected: .red
            case .connected: .green
            case .connecting: .yellow
            }
        }
        
        var userFacingName: String {
            switch self {
            case .connecting: "Connecting..."
            default: rawValue.capitalized
            }
        }
    }
}
