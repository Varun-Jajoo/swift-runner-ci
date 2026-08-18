//
//  GroupClassRealtimeManager.swift
//  MyPT
//
//  Minimal native client for Laravel Reverb's Pusher-compatible WebSocket
//  protocol (mypt-backend now broadcasts on `group-class.{classId}` - see
//  routes/channels.php and app/Events/GroupClass/*). Deliberately NOT the
//  official Pusher Swift SDK: this project manages dependencies via SPM only
//  and adding/resolving a new remote package needs Xcode itself (no
//  xcodebuild/Xcode available in this environment to safely do that and
//  verify the project still opens). The wire protocol Reverb speaks is
//  simple documented JSON over a plain WebSocket, so a small
//  URLSessionWebSocketTask client covers exactly what a private-channel
//  subscribe/unsubscribe + named-event delivery needs, matching §11a/§11c
//  of the realtime architecture plan (private channel, screen-scoped
//  subscription lifetime) without a new third-party dependency.
//
//  Scope: the private per-class channel (Detail screen) plus the public
//  `group-classes` listing channel (Home carousel / See All / Slot Open) -
//  no presence roster, no client events.
//

import Foundation

final class GroupClassRealtimeManager: NSObject {

    static let shared = GroupClassRealtimeManager()

    /// Reverb speaks Pusher's protocol; APP_KEY (never the secret) is meant
    /// to ship in client code, same as any Pusher-protocol client SDK.
    /// Proxied through the existing Apache vhost on 443 (see
    /// mypt-le-ssl.conf's ProxyPass /app/ -> ws://127.0.0.1:8080/app/) rather
    /// than exposing Reverb's raw 8080 port directly - same port everything
    /// else uses.
    private enum Config {
        static let scheme = "wss"
        // Deliberately NOT gated on the app-wide `isTesting` flag - group
        // classes are pointed at production while the rest of the app
        // (isTesting=true) stays on UAT. Revisit together with
        // GroupClassTapThroughData.swift's own `host` if that ever changes -
        // group-class listing/booking data itself still comes from
        // URLBuilder's isTesting-gated baseURL (UAT), so this only makes
        // sense once that's pointed at the same backend too.
        static let host = AppBaseUrl.baseProductionUrl.rawValue
        static let port: Int? = 443
        static let appKey = "6j6bpvkxjw3s9flj3cvr"
    }

    private var session: URLSession?
    private var socket: URLSessionWebSocketTask?
    private var socketId: String?
    private var isConnecting = false

    /// classId -> event callback, one entry per currently-subscribed channel.
    private var subscriptions: [Int: (String, [String: Any]) -> Void] = [:]
    /// classIds requested before the socket handshake handed back a socket_id.
    private var pendingSubscribes: Set<Int> = []
    /// The public `group-classes` listing channel is shared by every
    /// listening screen (Home carousel, See All) - one callback slot, not
    /// keyed by id like the per-class channels above.
    private var listingCallback: ((String, [String: Any]) -> Void)?
    private var isListingSubscribed = false
    private var pendingListingSubscribe = false

    /// Cancelled on every successful connection_established - a fresh drop
    /// always gets a fresh backoff instead of stacking retries.
    private var reconnectAttempt = 0
    private var reconnectWorkItem: DispatchWorkItem?
    private static let baseReconnectDelay: TimeInterval = 2
    private static let maxReconnectDelay: TimeInterval = 30

    private override init() {
        super.init()
    }

    // MARK: - Public API

    /// Subscribes to `group-class.{classId}`, opening the underlying socket
    /// connection first if none is open yet. Safe to call again with the
    /// same classId (e.g. on every viewWillAppear) - just replaces the
    /// callback and re-confirms the subscription.
    func subscribe(classId: Int, onEvent: @escaping (_ event: String, _ data: [String: Any]) -> Void) {
        guard classId > 0 else { return }
        subscriptions[classId] = onEvent
        if let socketId = socketId {
            sendSubscribe(classId: classId, socketId: socketId)
        } else {
            pendingSubscribes.insert(classId)
            connectIfNeeded()
        }
    }

    /// Unsubscribes from `group-class.{classId}`. Closes the underlying
    /// connection once no channel is left subscribed - matches §11c's
    /// "connection stays open while at least one relevant screen is
    /// visible, closes when the last one closes" rule.
    func unsubscribe(classId: Int) {
        guard classId > 0 else { return }
        subscriptions.removeValue(forKey: classId)
        pendingSubscribes.remove(classId)
        send(["event": "pusher:unsubscribe", "data": ["channel": channelName(classId)]])
        if subscriptions.isEmpty && listingCallback == nil {
            disconnect()
        }
    }

    /// Subscribes to the public `group-classes` listing channel - no
    /// `/broadcasting/auth` handshake needed (public channel, matches
    /// classDetail()'s own public-read stance, §11b). Safe to call again
    /// (e.g. re-appearing on Home) - just replaces the callback.
    func subscribeToListing(onEvent: @escaping (_ event: String, _ data: [String: Any]) -> Void) {
        listingCallback = onEvent
        if isListingSubscribed {
            return
        }
        if socketId != nil {
            send(["event": "pusher:subscribe", "data": ["channel": Self.listingChannel]])
        } else {
            pendingListingSubscribe = true
            connectIfNeeded()
        }
    }

    /// Unsubscribes from `group-classes`. Closes the underlying connection
    /// once no channel (private or listing) is left subscribed.
    func unsubscribeFromListing() {
        guard listingCallback != nil else { return }
        listingCallback = nil
        isListingSubscribed = false
        pendingListingSubscribe = false
        send(["event": "pusher:unsubscribe", "data": ["channel": Self.listingChannel]])
        if subscriptions.isEmpty {
            disconnect()
        }
    }

    // MARK: - Connection

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
    }

    /// Reconnects automatically after an unexpected drop, instead of leaving
    /// the manager permanently dead until some screen's viewWillAppear
    /// happens to call subscribe() again.
    ///
    /// That used to be the ONLY recovery path (see the removed comment in
    /// listen()'s `.failure` case), which is fine for a drop that coincides
    /// with the screen backgrounding - but a screen that stays continuously
    /// in the foreground (or a socket that dies while nothing is being
    /// touched at all) had no path back to a live connection, ever - it
    /// would sit there silently showing stale data forever. Verified live on
    /// the Android counterpart: a class's seat count stopped updating after
    /// an earlier disconnect and never recovered despite the detail screen
    /// staying open and several real admin changes happening in the
    /// meantime - this manager has the identical structure, so the same gap.
    ///
    /// Only reconnects while something still wants a connection
    /// (subscriptions/listingCallback non-empty) - an intentional
    /// disconnect() (last subscriber left) cancels this instead, matching
    /// §11c's "closes when the last relevant screen closes" rule; this must
    /// not fight that by reopening a connection nothing asked for.
    private func scheduleReconnect() {
        reconnectWorkItem?.cancel()
        guard !subscriptions.isEmpty || listingCallback != nil else { return }

        // Re-queue everything that was live on the dead connection so the
        // next connection_established resubscribes it all, exactly like a
        // fresh subscribe() would.
        pendingSubscribes.formUnion(subscriptions.keys)
        if listingCallback != nil { pendingListingSubscribe = true }

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
            // A connection that actually completes its handshake is healthy -
            // the next failure (whenever it happens) should start backing
            // off from zero again, not continue counting up from whatever
            // this manager had reached before.
            reconnectAttempt = 0
            for classId in pendingSubscribes {
                sendSubscribe(classId: classId, socketId: newSocketId)
            }
            pendingSubscribes.removeAll()
            if pendingListingSubscribe {
                send(["event": "pusher:subscribe", "data": ["channel": Self.listingChannel]])
                pendingListingSubscribe = false
            }

        case "pusher:ping":
            send(["event": "pusher:pong", "data": [String: String]()])

        case "pusher_internal:subscription_succeeded":
            if let channel = outer["channel"] as? String, channel == Self.listingChannel {
                isListingSubscribed = true
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
            } else if let classId = classId(fromChannel: channel), let callback = subscriptions[classId] {
                DispatchQueue.main.async { callback(event, payload) }
            }
        }
    }

    // MARK: - Subscribe handshake

    private func sendSubscribe(classId: Int, socketId: String) {
        let channel = channelName(classId)
        authorize(channel: channel, socketId: socketId) { [weak self] auth in
            guard let self = self, let auth = auth, self.subscriptions[classId] != nil else { return }
            self.send(["event": "pusher:subscribe", "data": ["channel": channel, "auth": auth]])
        }
    }

    /// Hits the same `/broadcasting/auth` endpoint BroadcastServiceProvider
    /// registers (mypt-backend, `auth:sanctum` guard - see
    /// BroadcastServiceProvider::boot()), with the same bearer token
    /// NetworkManager's interceptor attaches to every REST call.
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

    /// Public channel - no `private-` prefix, matches routes/channels.php
    /// only defining an authorization closure for `group-class.{classId}`,
    /// not `group-classes`.
    private static let listingChannel = "group-classes"

    private func channelName(_ classId: Int) -> String {
        "private-group-class.\(classId)"
    }

    private func classId(fromChannel channel: String) -> Int? {
        guard channel.hasPrefix("private-group-class.") else { return nil }
        return Int(channel.replacingOccurrences(of: "private-group-class.", with: ""))
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
