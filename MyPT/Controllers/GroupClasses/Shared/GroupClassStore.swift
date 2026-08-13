//
//  GroupClassStore.swift
//  MyPT
//
//  Single owner of Group Class realtime state.
//
//  Before this existed, every screen that wanted live updates
//  (GroupTrainingDetailViewController, GroupClassesCarouselView,
//  SeeAllGroupClassesViewController, SlotOpenViewController) each subscribed
//  to GroupClassRealtimeManager directly and each re-implemented the same
//  three things: a switch over raw event-name strings, the same
//  Int/Double/String coercion for `price`, and the same
//  classId/scheduleId matching rules. Four copies of identical parsing is
//  four places for the shapes to drift apart.
//
//  This type does that parsing exactly once, keeps the resulting values as
//  canonical live state, and hands screens a typed `GroupClassStoreEvent`
//  plus a merged `GroupClassLiveState` to read from. Screens keep their own
//  REST-populated models (UpcomingClassModel / ClassDetailsModel) as the
//  base rendering data - this only layers "what changed since that fetch"
//  on top, which is why adopting it needed no change to any existing fetch
//  or render path.
//
//  Deliberately closure-based rather than Combine: this project uses
//  completion closures everywhere (NetworkManager, the VM layer,
//  GroupClassRealtimeManager) and has no Combine usage at all, so
//  @Published/AnyCancellable would be a new paradigm here for no gain.
//

import Foundation

// MARK: - Live state

/// The subset of a class's data that realtime events can change. Every
/// field is optional: nil means "no realtime update has arrived for this
/// field, keep whatever the REST fetch said".
struct GroupClassLiveState {
    var bookedCount: Int?
    var remainingSeats: Int?
    var capacity: Int?
    /// Kept as String to match how both `UpcomingClassModel.price`
    /// (FlexibleValue) and the detail screen's `classPrice` already store it.
    var price: String?
    /// Queue length for this occurrence. Moves independently of the seat
    /// counts above - joining/leaving a waitlist never changes a booked seat.
    var waitlistCount: Int?
}

// MARK: - Typed events

/// What a screen actually needs to know, with the wire format already
/// parsed away. Screens switch on this instead of on raw event-name strings.
enum GroupClassStoreEvent {
    /// A booking was made/cancelled on this specific occurrence.
    case seatsChanged(classId: Int, scheduleId: Int)
    /// The queue length for this occurrence changed (someone joined or left
    /// the waitlist, or a queued member was promoted/claimed a spot).
    case waitlistChanged(classId: Int, scheduleId: Int)
    /// Class-wide capacity edit (affects every schedule of the class).
    case capacityChanged(classId: Int)
    /// Class-wide price edit.
    case priceChanged(classId: Int)
    /// Completed/Cancelled - significant enough that screens re-fetch via
    /// REST rather than trying to patch it.
    case classStatusChanged(classId: Int)
    /// free/paid/mixed changed. Screens re-fetch rather than patch: this
    /// changes per-user visibility and free-for-this-member resolution,
    /// neither of which a single fan-out payload can carry (see
    /// AccessChanged.php).
    case accessChanged(classId: Int)
    /// A brand-new class exists. Carries no per-user personalization
    /// (one broadcast, many recipients - see ClassCreated.php), so screens
    /// re-fetch rather than inserting the payload directly.
    case classCreated
}

// MARK: - Store

final class GroupClassStore {

    static let shared = GroupClassStore()

    /// Class-wide overrides (capacity, price), keyed by classId.
    private var classState: [Int: GroupClassLiveState] = [:]
    /// Per-occurrence overrides (seat counts), keyed by scheduleId.
    private var scheduleState: [Int: GroupClassLiveState] = [:]

    private var observers: [UUID: (GroupClassStoreEvent) -> Void] = [:]
    /// Per-class channel subscriptions this store currently holds, with a
    /// refcount so two screens watching the same class (e.g. Detail pushed
    /// on top of Slot Open) don't unsubscribe each other on the way out.
    private var classRefcounts: [Int: Int] = [:]
    private var listingRefcount = 0

    private init() {}

    // MARK: Reading state

    /// Merged live overrides for a card/screen: class-wide fields first,
    /// then the per-occurrence seat counts on top. Returns an all-nil state
    /// when no realtime update has touched this class yet.
    func liveState(classId: Int?, scheduleId: Int?) -> GroupClassLiveState {
        var merged = GroupClassLiveState()
        if let classId = classId, let classLevel = classState[classId] {
            merged.capacity = classLevel.capacity
            merged.price = classLevel.price
        }
        if let scheduleId = scheduleId, let scheduleLevel = scheduleState[scheduleId] {
            merged.bookedCount = scheduleLevel.bookedCount
            merged.remainingSeats = scheduleLevel.remainingSeats
            merged.waitlistCount = scheduleLevel.waitlistCount
        }
        // A capacity edit invalidates whatever seat count was last broadcast
        // for this occupancy: CAPACITY_CHANGED intentionally carries no
        // remaining-seats figure (it's class-wide, so it can't be right for
        // every schedule of a multi-schedule class), so derive it here from
        // the new capacity against this occurrence's own booked count.
        if let capacity = merged.capacity, let booked = merged.bookedCount {
            merged.remainingSeats = max(0, capacity - booked)
        }
        return merged
    }

    // MARK: Observation

    /// Registers an observer. Always called on the main thread (the
    /// underlying GroupClassRealtimeManager already hops there). Keep the
    /// returned token and pass it to `removeObserver` on screen teardown.
    @discardableResult
    func observe(_ onEvent: @escaping (GroupClassStoreEvent) -> Void) -> UUID {
        let token = UUID()
        observers[token] = onEvent
        return token
    }

    func removeObserver(_ token: UUID?) {
        guard let token = token else { return }
        observers.removeValue(forKey: token)
    }

    // MARK: Channel lifetime

    /// Starts watching one class's private channel. Refcounted, so calling
    /// this from two screens for the same class is safe.
    func startWatching(classId: Int) {
        guard classId > 0 else { return }
        classRefcounts[classId, default: 0] += 1
        guard classRefcounts[classId] == 1 else { return }
        GroupClassRealtimeManager.shared.subscribe(classId: classId) { [weak self] event, data in
            self?.ingest(event: event, data: data)
        }
    }

    func stopWatching(classId: Int) {
        guard classId > 0, let count = classRefcounts[classId] else { return }
        if count <= 1 {
            classRefcounts.removeValue(forKey: classId)
            GroupClassRealtimeManager.shared.unsubscribe(classId: classId)
        } else {
            classRefcounts[classId] = count - 1
        }
    }

    /// Starts watching the public listing channel. Refcounted the same way -
    /// Home and See All can both hold it while See All sits on top of Home.
    func startWatchingListing() {
        listingRefcount += 1
        guard listingRefcount == 1 else { return }
        GroupClassRealtimeManager.shared.subscribeToListing { [weak self] event, data in
            self?.ingest(event: event, data: data)
        }
    }

    func stopWatchingListing() {
        guard listingRefcount > 0 else { return }
        listingRefcount -= 1
        guard listingRefcount == 0 else { return }
        GroupClassRealtimeManager.shared.unsubscribeFromListing()
    }

    // MARK: Ingest (the single parsing site)

    /// The one place raw broadcast payloads are decoded. Both the private
    /// per-class channel and the public listing channel funnel through here,
    /// and the same event arriving on both (the backend broadcasts most
    /// events to both - see the Event classes' broadcastOn()) is naturally
    /// idempotent: it writes the same values into the same keys twice.
    private func ingest(event: String, data: [String: Any]) {
        switch event {
        case "PARTICIPANT_JOINED", "PARTICIPANT_LEFT":
            guard let classId = data["classId"] as? Int,
                  let scheduleId = data["scheduleId"] as? Int else { return }
            var state = scheduleState[scheduleId] ?? GroupClassLiveState()
            if let booked = data["bookedCount"] as? Int { state.bookedCount = booked }
            if let remaining = data["remainingSeats"] as? Int { state.remainingSeats = remaining }
            scheduleState[scheduleId] = state
            broadcast(.seatsChanged(classId: classId, scheduleId: scheduleId))

        case "WAITLIST_CHANGED":
            guard let classId = data["classId"] as? Int,
                  let scheduleId = data["scheduleId"] as? Int,
                  let count = data["waitlistCount"] as? Int else { return }
            var state = scheduleState[scheduleId] ?? GroupClassLiveState()
            state.waitlistCount = count
            scheduleState[scheduleId] = state
            broadcast(.waitlistChanged(classId: classId, scheduleId: scheduleId))

        case "CAPACITY_CHANGED":
            guard let classId = data["classId"] as? Int,
                  let capacity = data["capacity"] as? Int else { return }
            var state = classState[classId] ?? GroupClassLiveState()
            state.capacity = capacity
            classState[classId] = state
            broadcast(.capacityChanged(classId: classId))

        case "PRICE_CHANGED":
            guard let classId = data["classId"] as? Int,
                  let price = GroupClassStore.priceString(from: data["price"]) else { return }
            var state = classState[classId] ?? GroupClassLiveState()
            state.price = price
            classState[classId] = state
            broadcast(.priceChanged(classId: classId))

        case "CLASS_STATUS_CHANGED":
            guard let classId = data["classId"] as? Int else { return }
            broadcast(.classStatusChanged(classId: classId))

        case "ACCESS_CHANGED":
            guard let classId = data["classId"] as? Int else { return }
            broadcast(.accessChanged(classId: classId))

        case "CLASS_CREATED":
            broadcast(.classCreated)

        default:
            break
        }
    }

    private func broadcast(_ event: GroupClassStoreEvent) {
        for observer in observers.values {
            observer(event)
        }
    }

    /// `classes.price` has changed column type more than once (int ->
    /// decimal -> int), so the same field can arrive as a JSON number or a
    /// string depending on the row and the backend version. Coerced once
    /// here rather than at each call site - this is the exact duplication
    /// that previously lived in three separate screens.
    static func priceString(from raw: Any?) -> String? {
        if let value = raw as? Int { return "\(value)" }
        if let value = raw as? Double { return "\(value)" }
        if let value = raw as? String { return value }
        return nil
    }
}
