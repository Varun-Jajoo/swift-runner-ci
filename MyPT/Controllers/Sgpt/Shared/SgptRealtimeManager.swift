//
//  SgptRealtimeManager.swift
//  MyPT
//

import Foundation

final class SgptRealtimeManager: NSObject {

    static let shared = SgptRealtimeManager()

    private enum Config {
        static let scheme = "wss"
        static let host = isTesting ? AppBaseUrl.baseDevUrl.rawValue : AppBaseUrl.baseProductionUrl.rawValue
        static let port: Int? = 443
        static let appKey = "6j6bpvkxjw3s9flj3cvr"
    }

    private static let listingChannel = "sgpt-sessions"
    private static let pricingChannel = "sgpt-pricing"
    private static let baseReconnectDelay: Double = 2
    private static let maxReconnectDelay: Double = 30

    private var session: URLSession?
    private var socket: URLSessionWebSocketTask?
    private var socketId: String?
    private var isConnecting = false

    private var subscriptions: [String: (String, [String: Any]) -> Void] = [:]
    private var pendingSubscribes: Set<String> = []

    private var listingCallback: ((String, [String: Any]) -> Void)?
    private var isListingSubscribed = false
    private var pendingListingSubscribe = false

    private var pricingCallback: ((String, [String: Any]) -> Void)?
    private var isPricingSubscribed = false
    private var pendingPricingSubscribe = false

    private var reconnectAttempt = 0
    private var reconnectWorkItem: DispatchWorkItem?

    // MARK: - Public API

    func subscribe(sessionId: String, onEvent: @escaping (_ event: String, _ data: [String: Any]) -> Void) {
        guard !sessionId.isEmpty else { return }
        subscriptions[sessionId] = onEvent
        if let socketId = socketId {
            sendSubscribe(sessionId: sessionId, socketId: socketId)
        } else {
            pendingSubscribes.insert(sessionId)
            connectIfNeeded()
        }
    }

    func unsubscribe(sessionId: String) {
        guard !sessionId.isEmpty else { return }
        subscriptions.removeValue(forKey: sessionId)
        pendingSubscribes.remove(sessionId)
        send(["event": "pusher:unsubscribe", "data": ["channel": channelName(sessionId)]])
        disconnectIfIdle()
    }

    func subscribeToListing(onEvent: @escaping (_ event: String, _ data: [String: Any]) -> Void) {
        listingCallback = onEvent
        guard !isListingSubscribed else { return }
        if socketId != nil {
            send(["event": "pusher:subscribe", "data": ["channel": Self.listingChannel]])
        } else {
            pendingListingSubscribe = true
            connectIfNeeded()
        }
    }

    func unsubscribeFromListing() {
        guard listingCallback != nil else { return }
        listingCallback = nil
        isListingSubscribed = false
        pendingListingSubscribe = false
        send(["event": "pusher:unsubscribe", "data": ["channel": Self.listingChannel]])
        disconnectIfIdle()
    }

    func subscribeToPricing(onEvent: @escaping (_ event: String, _ data: [String: Any]) -> Void) {
        pricingCallback = onEvent
        guard !isPricingSubscribed else { return }
        if socketId != nil {
            send(["event": "pusher:subscribe", "data": ["channel": Self.pricingChannel]])
        } else {
            pendingPricingSubscribe = true
            connectIfNeeded()
        }
    }

    func unsubscribeFromPricing() {
        guard pricingCallback != nil else { return }
        pricingCallback = nil
        isPricingSubscribed = false
        pendingPricingSubscribe = false
        send(["event": "pusher:unsubscribe", "data": ["channel": Self.pricingChannel]])
        disconnectIfIdle()
    }

    // MARK: - Connection

    private func disconnectIfIdle() {
        if subscriptions.isEmpty && listingCallback == nil && pricingCallback == nil {
            disconnect()
        }
    }

    private func connectIfNeeded() {
        guard socket == nil, !isConnecting else { return }
        isConnecting = true

        var components = URLComponents()
        components.scheme = Config.scheme
        components.host = Config.host
        components.port = Config.port
        components.path = "/app/\(Config.appKey)"
        components.queryItems = [
            URLQueryItem(name: "protocol", value: "7"),
            URLQueryItem(name: "client", value: "mypt-ios"),
            URLQueryItem(name: "version", value: "1.0"),
        ]
        guard let url = components.url else {
            isConnecting = false
            return
        }

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        self.session = session
        self.socket = task
        task.resume()
        listen()
    }

    private func disconnect() {
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        reconnectAttempt = 0
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
        session = nil
        socketId = nil
        isConnecting = false
        pendingSubscribes.removeAll()
        isListingSubscribed = false
        isPricingSubscribed = false
    }

    private func scheduleReconnect() {
        reconnectWorkItem?.cancel()
        guard !subscriptions.isEmpty || listingCallback != nil || pricingCallback != nil else { return }

        pendingSubscribes.formUnion(subscriptions.keys)
        if listingCallback != nil { pendingListingSubscribe = true }
        if pricingCallback != nil { pendingPricingSubscribe = true }

        let delay = min(Self.baseReconnectDelay * pow(2, Double(min(reconnectAttempt, 4))), Self.maxReconnectDelay)
        reconnectAttempt += 1

        let workItem = DispatchWorkItem { [weak self] in self?.connectIfNeeded() }
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func listen() {
        socket?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.socket = nil
                self.session = nil
                self.socketId = nil
                self.isConnecting = false
                self.isListingSubscribed = false
                self.isPricingSubscribed = false
                self.scheduleReconnect()
            case .success(let message):
                self.handle(message)
                self.listen()
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        guard case .string(let text) = message,
              let outer = Self.decodeJSONObject(text),
              let event = outer["event"] as? String else { return }

        switch event {
        case "pusher:connection_established":
            isConnecting = false
            guard let dataString = outer["data"] as? String,
                  let inner = Self.decodeJSONObject(dataString),
                  let newSocketId = inner["socket_id"] as? String else { return }
            socketId = newSocketId
            reconnectAttempt = 0
            for sessionId in pendingSubscribes {
                sendSubscribe(sessionId: sessionId, socketId: newSocketId)
            }
            pendingSubscribes.removeAll()
            if pendingListingSubscribe {
                send(["event": "pusher:subscribe", "data": ["channel": Self.listingChannel]])
                pendingListingSubscribe = false
            }
            if pendingPricingSubscribe {
                send(["event": "pusher:subscribe", "data": ["channel": Self.pricingChannel]])
                pendingPricingSubscribe = false
            }

        case "pusher:ping":
            send(["event": "pusher:pong", "data": [String: String]()])

        case "pusher_internal:subscription_succeeded":
            if let channel = outer["channel"] as? String {
                if channel == Self.listingChannel { isListingSubscribed = true }
                if channel == Self.pricingChannel { isPricingSubscribed = true }
            }

        case "pusher:error":
            break

        default:
            guard let channel = outer["channel"] as? String else { return }

            var payload: [String: Any] = [:]
            if let dataString = outer["data"] as? String, let decoded = Self.decodeJSONObject(dataString) {
                payload = decoded
            } else if let dataDict = outer["data"] as? [String: Any] {
                payload = dataDict
            }

            if channel == Self.listingChannel {
                guard let callback = listingCallback else { return }
                DispatchQueue.main.async { callback(event, payload) }
            } else if channel == Self.pricingChannel {
                guard let callback = pricingCallback else { return }
                DispatchQueue.main.async { callback(event, payload) }
            } else if let sessionId = sessionId(fromChannel: channel), let callback = subscriptions[sessionId] {
                DispatchQueue.main.async { callback(event, payload) }
            }
        }
    }

    // MARK: - Subscribe handshake

    private func sendSubscribe(sessionId: String, socketId: String) {
        let channel = channelName(sessionId)
        authorize(channel: channel, socketId: socketId) { [weak self] auth in
            guard let self = self, let auth = auth, self.subscriptions[sessionId] != nil else { return }
            self.send(["event": "pusher:subscribe", "data": ["channel": channel, "auth": auth]])
        }
    }

    private func authorize(channel: String, socketId: String, completion: @escaping (String?) -> Void) {
        guard let url = URLBuilder().set(path: "/broadcasting/auth").build() else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let token = appUserDefaults.getAccessToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let allowed = CharacterSet.urlQueryAllowed
        let encodedChannel = channel.addingPercentEncoding(withAllowedCharacters: allowed) ?? channel
        let encodedSocketId = socketId.addingPercentEncoding(withAllowedCharacters: allowed) ?? socketId
        request.httpBody = "channel_name=\(encodedChannel)&socket_id=\(encodedSocketId)".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let auth = json["auth"] as? String else {
                completion(nil)
                return
            }
            completion(auth)
        }.resume()
    }

    // MARK: - Helpers

    private func channelName(_ sessionId: String) -> String {
        "private-sgpt-session.\(sessionId)"
    }

    private func sessionId(fromChannel channel: String) -> String? {
        guard channel.hasPrefix("private-sgpt-session.") else { return nil }
        let value = channel.replacingOccurrences(of: "private-sgpt-session.", with: "")
        return value.isEmpty ? nil : value
    }

    private func send(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let text = String(data: data, encoding: .utf8) else { return }
        socket?.send(.string(text)) { _ in }
    }

    private static func decodeJSONObject(_ text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}
