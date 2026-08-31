//
//  SgptStore.swift
//  MyPT
//

import Foundation

struct SgptLiveState {
    var bookedCount: Int?
    var remainingSeats: Int?
    var maxSize: Int?
    var status: String?
    var startedAtIso: String?
    var endsAtIso: String?
    var durationMins: Int?
    var cancelReason: String?
    var attendedCount: Int?
    var pendingCount: Int?
}

enum SgptStoreEvent {
    case seatsChanged(sessionId: String)
    case statusChanged(sessionId: String, status: String)
    case memberStatusChanged(sessionId: String, memberId: Int, memberStatus: String)
    case sessionUpdated(sessionId: String, changed: [String])
    case sessionCreated
    case pricingPublished
}

final class SgptStore {

    static let shared = SgptStore()

    private var live: [String: SgptLiveState] = [:]
    private var observers: [UUID: (SgptStoreEvent) -> Void] = [:]

    private var sessionRefcounts: [String: Int] = [:]
    private var listingRefcount = 0
    private var pricingRefcount = 0

    func state(for sessionId: String) -> SgptLiveState? {
        live[sessionId]
    }

    @discardableResult
    func observe(_ onEvent: @escaping (SgptStoreEvent) -> Void) -> UUID {
        let token = UUID()
        observers[token] = onEvent
        return token
    }

    func removeObserver(_ token: UUID?) {
        guard let token = token else { return }
        observers.removeValue(forKey: token)
    }

    func startWatching(sessionId: String) {
        guard !sessionId.isEmpty else { return }
        let next = (sessionRefcounts[sessionId] ?? 0) + 1
        sessionRefcounts[sessionId] = next
        guard next == 1 else { return }
        SgptRealtimeManager.shared.subscribe(sessionId: sessionId) { [weak self] event, data in
            self?.ingest(event: event, data: data)
        }
    }

    func stopWatching(sessionId: String) {
        guard !sessionId.isEmpty, let count = sessionRefcounts[sessionId] else { return }
        if count <= 1 {
            sessionRefcounts.removeValue(forKey: sessionId)
            SgptRealtimeManager.shared.unsubscribe(sessionId: sessionId)
        } else {
            sessionRefcounts[sessionId] = count - 1
        }
    }

    func startWatchingListing() {
        listingRefcount += 1
        guard listingRefcount == 1 else { return }
        SgptRealtimeManager.shared.subscribeToListing { [weak self] event, data in
            self?.ingest(event: event, data: data)
        }
    }

    func stopWatchingListing() {
        guard listingRefcount > 0 else { return }
        listingRefcount -= 1
        guard listingRefcount == 0 else { return }
        SgptRealtimeManager.shared.unsubscribeFromListing()
    }

    func startWatchingPricing() {
        pricingRefcount += 1
        guard pricingRefcount == 1 else { return }
        SgptRealtimeManager.shared.subscribeToPricing { [weak self] event, data in
            self?.ingest(event: event, data: data)
        }
    }

    func stopWatchingPricing() {
        guard pricingRefcount > 0 else { return }
        pricingRefcount -= 1
        guard pricingRefcount == 0 else { return }
        SgptRealtimeManager.shared.unsubscribeFromPricing()
    }

    // MARK: - Ingest

    private func intValue(_ data: [String: Any], _ key: String) -> Int? {
        if let v = data[key] as? Int { return v }
        if let v = data[key] as? String { return Int(v) }
        if let v = data[key] as? Double { return Int(v) }
        return nil
    }

    private func stringValue(_ data: [String: Any], _ key: String) -> String? {
        guard let v = data[key] as? String, !v.isEmpty else { return nil }
        return v
    }

    private func ingest(event: String, data: [String: Any]) {
        let sessionId = stringValue(data, "sessionId") ?? ""

        var storeEvent: SgptStoreEvent?

        switch event {
        case "SGPT_ROSTER_CHANGED":
            guard !sessionId.isEmpty else { return }
            var s = live[sessionId] ?? SgptLiveState()
            if let v = intValue(data, "bookedCount") { s.bookedCount = v }
            if let v = intValue(data, "remainingSeats") { s.remainingSeats = v }
            if let v = intValue(data, "maxSize") { s.maxSize = v }
            live[sessionId] = s
            storeEvent = .seatsChanged(sessionId: sessionId)

        case "SGPT_SESSION_STATUS_CHANGED":
            guard !sessionId.isEmpty else { return }
            var s = live[sessionId] ?? SgptLiveState()
            let status = stringValue(data, "status") ?? ""
            if !status.isEmpty { s.status = status }
            s.startedAtIso = stringValue(data, "startedAt")
            s.endsAtIso = stringValue(data, "endsAt")
            if let v = intValue(data, "durationMins") { s.durationMins = v }
            s.cancelReason = stringValue(data, "cancelReason")
            live[sessionId] = s
            storeEvent = .statusChanged(sessionId: sessionId, status: status)

        case "SGPT_MEMBER_STATUS_CHANGED":
            guard !sessionId.isEmpty else { return }
            var s = live[sessionId] ?? SgptLiveState()
            if let v = intValue(data, "attendedCount") { s.attendedCount = v }
            if let v = intValue(data, "pendingCount") { s.pendingCount = v }
            live[sessionId] = s
            storeEvent = .memberStatusChanged(
                sessionId: sessionId,
                memberId: intValue(data, "memberId") ?? 0,
                memberStatus: stringValue(data, "memberStatus") ?? ""
            )

        case "SGPT_SESSION_UPDATED":
            guard !sessionId.isEmpty else { return }
            var s = live[sessionId] ?? SgptLiveState()
            if let v = intValue(data, "maxSize") { s.maxSize = v }
            if let v = intValue(data, "durationMins") { s.durationMins = v }
            live[sessionId] = s
            storeEvent = .sessionUpdated(sessionId: sessionId, changed: data["changed"] as? [String] ?? [])

        case "SGPT_SESSION_CREATED":
            storeEvent = .sessionCreated

        case "SGPT_PRICING_PUBLISHED":
            storeEvent = .pricingPublished

        default:
            return
        }

        guard let resolved = storeEvent else { return }
        for callback in observers.values {
            callback(resolved)
        }
    }

    func clear() {
        live.removeAll()
    }
}
