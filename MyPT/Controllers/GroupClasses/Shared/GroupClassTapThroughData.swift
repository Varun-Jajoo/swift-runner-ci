//
//  GroupClassTapThroughData.swift
//  MyPT
//
//  Tap-through payload + presentation helpers shared by the Group Classes module.
//
//  Android mirrors: `GroupClassesHomeAdapter.kt` (card formatting + the intent
//  extras it puts on `GroupTrainingDetailActivity`) and the `setupGroupClassesSection()`
//  free/member filter in `ActiveUserHomeFragmentNew.kt` / `GuestUserHomeFragmentNew.kt`.
//

import UIKit
import CoreLocation

// MARK: - GroupClassTapThroughData

/// Snapshot of a class card, handed to `GroupTrainingDetailViewController` so the
/// detail screen can paint itself instantly and only *then* refresh from
/// `GET class-detail` — the same "populate instantly, then refresh" pattern the
/// Android activity uses with its intent extras.
///
/// Field-for-field equivalent of the extras `GroupClassesHomeAdapter` puts on the
/// detail intent; `time` / `location` / `distance` are already display-formatted
/// here (exactly as Android passes the formatted label text, not the raw value).
struct GroupClassTapThroughData {

    var scheduleId: String = ""
    /// Resolved class title (already falls back to "Group Training").
    var title: String = ""
    /// Pre-formatted, e.g. `Wed, 9 Jul • 7-8 AM`.
    var time: String = ""
    /// Cleaned studio name (part after the first hyphen, when present).
    var location: String = ""
    var image: String = ""
    var trainedBy: String = ""
    var trainerImage: String = ""
    var price: String = ""
    /// `free` / `paid` / `mixed`. Defaults to `paid` to match Android, where both
    /// `optString("access", "paid")` and the model's own field default resolve an
    /// unknown access to paid rather than to a free/mixed CTA.
    var access: String = GroupClassCardFormatter.defaultAccess
    var isMember: Bool = false
    var bookedCount: Int = 0
    var totalCapacity: Int = 20
    var remainingSeats: Int = 20
    var startEnd: String = ""
    /// Pre-formatted, e.g. `2.1 km away`.
    var distance: String = ""
    var studioLat: Double = 0
    var studioLng: Double = 0
    /// Device location at the moment the card was tapped.
    var userLat: Double = 0
    var userLng: Double = 0
}

// MARK: - GroupClassCardFormatter

/// Pure formatting/derivation helpers for group-class list items.
///
/// Kept free of UIKit state so the home carousel (Phase 3) and the detail screen
/// (Phase 4) derive identical strings from identical inputs.
enum GroupClassCardFormatter {

    // Android hard-codes these placeholder fallbacks in `GroupClassesHomeAdapter`;
    // replicated verbatim so both platforms degrade identically on sparse data.
    static let defaultTitle = "Group Training"
    static let defaultTime = "Wed, 9 Jul • 7-8 AM"
    /// Used when a row carries *no* location at all — Android's
    /// `GroupClassesHomeAdapter.onBindViewHolder` substitutes this before it calls
    /// `cleanStudioName`, so this (not `defaultStudio`) is what an empty row shows.
    static let defaultLocation = "DSO Club"
    /// `cleanStudioName`'s own blank branch. Kept for parity with Android, where it
    /// is likewise unreachable from the card path because `defaultLocation` is
    /// substituted first.
    static let defaultStudio = "Silicon Oasis"
    static let defaultDistance = "2.1 km away"
    /// Android reads the field as `json.optString("access", "paid")` and its
    /// `FullNearUpcomingCLassModel.access` property also defaults to `"paid"`, so a
    /// class that omits `access` is treated as PAID (PREMIUM badge), never as free.
    static let defaultAccess = "paid"
    /// Dubai — Android's fallback centre when the device location is unknown.
    static let fallbackLatitude: Double = 25.2048
    static let fallbackLongitude: Double = 55.2708

    // MARK: Flexible number coercion

    /// `FlexibleValue.intValue` is a plain `Int(String)` and therefore returns nil
    /// for a JSON number that decoded as `"20.0"`; fall through the double reading
    /// before giving up, mirroring Android's coercing `optInt`.
    static func intValue(_ value: FlexibleValue?, defaultValue: Int) -> Int {
        if let intValue = value?.intValue { return intValue }
        if let doubleValue = value?.doubleValue { return Int(doubleValue) }
        return defaultValue
    }

    static func doubleValue(_ value: FlexibleValue?, defaultValue: Double) -> Double {
        return value?.doubleValue ?? defaultValue
    }

    // MARK: Visibility / access

    /// The value every access check runs on. Android resolves `access` **once**, at
    /// parse time, via `optString("access", "paid")` and stores it on the model
    /// (whose own default is `"paid"`); everything downstream — the free/member
    /// filter, the badge, the detail intent extra — then reads that resolved value.
    /// Mirroring that here is what keeps a row with a missing `access` on PREMIUM
    /// instead of flipping it to FREE.
    static func resolvedAccess(_ access: String?) -> String {
        let access = (access ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return access.isEmpty ? defaultAccess : access
    }

    /// Free classes are visible **only** to active members (Android:
    /// `if (itemAccess.equals("free", true) && !itemIsMember) continue`).
    static func isVisibleOnHome(access: String?, isMember: Bool) -> Bool {
        let access = resolvedAccess(access).lowercased()
        return !(access == "free" && !isMember)
    }

    /// Drives the PREMIUM vs FREE badge: paid always, mixed only for non-members.
    static func isPaid(access: String?, isMember: Bool) -> Bool {
        let access = resolvedAccess(access).lowercased()
        if access == "paid" { return true }
        if access == "mixed" { return !isMember }
        return false
    }

    // MARK: Title / location

    /// Android resolves the card title `class` -> `name` -> "Group Training"
    /// (`GroupClassesHomeAdapter.onBindViewHolder`).
    static func title(for item: UpcomingClassModel) -> String {
        let className = (item.className ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !className.isEmpty { return className }
        let name = (item.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty { return name }
        return defaultTitle
    }

    /// Studio names arrive as `"MyPT - Silicon Oasis"`; the card only shows the
    /// branch, so keep everything after the first hyphen.
    static func cleanStudioName(_ rawName: String?) -> String {
        let raw = (rawName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return defaultStudio }
        guard let separator = raw.range(of: "-") else { return raw }
        return String(raw[separator.upperBound...]).trimmingCharacters(in: .whitespaces)
    }

    /// `studio_name` -> `location` -> `"DSO Club"`, then cleaned — the exact order
    /// and placeholder Android uses when binding a card.
    static func locationText(for item: UpcomingClassModel) -> String {
        let studioName = (item.studioName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !studioName.isEmpty { return cleanStudioName(studioName) }
        let location = (item.location ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !location.isEmpty { return cleanStudioName(location) }
        return cleanStudioName(defaultLocation)
    }

    // MARK: Time

    /// Formats the backend time into the card's `EEE, d MMM • h-h a` shape.
    /// Already-formatted values (they contain the bullet) are passed straight
    /// through, matching Android.
    static func formatTimeForUI(_ rawTimeStr: String?) -> String {
        let raw = (rawTimeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return defaultTime }
        if raw.contains("•") { return raw }

        let clean = raw.replacingOccurrences(of: "GMT", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = clean.contains("-") ? "yyyy-MM-dd HH:mm:ss" : "dd MMMM, HH:mm"

        guard let date = inputFormatter.date(from: clean) else { return raw }

        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "EEE, d MMM"
        let dayText = dayFormatter.string(from: date)

        let startHour = Calendar.current.component(.hour, from: date)
        let endHour = (startHour + 1) % 24
        let start12 = (startHour % 12 == 0) ? 12 : startHour % 12
        let end12 = (endHour % 12 == 0) ? 12 : endHour % 12
        let amPm = (endHour >= 12) ? "PM" : "AM"

        return "\(dayText) • \(start12)-\(end12) \(amPm)"
    }

    // MARK: Distance

    /// Great-circle distance from the device to the studio, falling back to the
    /// server-supplied `distance` string when the studio has no coordinates.
    static func distanceText(userLat: Double?,
                             userLng: Double?,
                             studioLat: Double?,
                             studioLng: Double?,
                             fallback: String?) -> String {

        var resolvedLat = userLat ?? 0
        var resolvedLng = userLng ?? 0

        if resolvedLat == 0 || resolvedLng == 0 {
            let stored = appUserDefaults.getLatLong()?.components(separatedBy: ",")
            resolvedLat = Double(stored?.first ?? "") ?? fallbackLatitude
            resolvedLng = Double(stored?.last ?? "") ?? fallbackLongitude
        }

        if let studioLat = studioLat, let studioLng = studioLng, studioLat != 0, studioLng != 0 {
            let meters = CLLocation(latitude: resolvedLat, longitude: resolvedLng)
                .distance(from: CLLocation(latitude: studioLat, longitude: studioLng))
            if meters < 1000 {
                return "\(Int(meters)) m away"
            }
            return String(format: "%.1f km away", meters / 1000.0)
        }

        let cleanFallback = (fallback ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanFallback.isEmpty else { return defaultDistance }
        return cleanFallback.contains("away") ? cleanFallback : "\(cleanFallback) away"
    }

    // MARK: Spot availability

    /// Resolved availability of a class: bar colour, fill fraction and caption.
    struct SpotAvailability {
        var state: SpotAvailabilityState
        /// `0...1`, ready for `SpotProgressBarView.setProgress(_:)`.
        var progress: CGFloat
        var text: String
    }

    /// Thresholds match Android exactly: green ≤ 40%, gold > 40%, red > 80%,
    /// and a full/sold-out class swaps the caption for "Join Waitlist".
    static func availability(bookedCount: Int,
                             totalCapacity: Int,
                             remainingSeats: Int) -> SpotAvailability {

        let totalCapacity = totalCapacity > 0 ? totalCapacity : 20
        let ratio = Double(bookedCount) / Double(totalCapacity)
        let percentage = ratio * 100.0
        let progress = CGFloat(min(max(ratio, 0), 1))
        let spotsText = "\(remainingSeats)/\(totalCapacity) spots left"

        if percentage >= 100 || remainingSeats <= 0 {
            return SpotAvailability(state: .red, progress: progress, text: "Join Waitlist")
        }
        if percentage > 80 {
            return SpotAvailability(state: .red, progress: progress, text: spotsText)
        }
        if percentage > 40 {
            return SpotAvailability(state: .gold, progress: progress, text: spotsText)
        }
        return SpotAvailability(state: .green, progress: progress, text: spotsText)
    }

    // MARK: Images

    /// Backend image fields are sometimes absolute and sometimes a bare storage
    /// path; resolve against the same host the network layer talks to so the two
    /// can never drift apart between staging and production.
    static func absoluteImageURL(_ rawPath: String?) -> String? {
        let raw = (rawPath ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if raw.lowercased().hasPrefix("http") { return raw }
        let host = isTesting ? AppBaseUrl.baseDevUrl.rawValue : AppBaseUrl.baseProductionUrl.rawValue
        return AppBaseUrl.baseScheme.rawValue + "://" + host + "/storage/" + raw
    }

    // MARK: Tap-through payload

    /// Builds the payload pushed into the detail screen — the iOS equivalent of
    /// the `putExtra` block in `GroupClassesHomeAdapter.onBindViewHolder`.
    static func tapThroughData(for item: UpcomingClassModel,
                               userLat: Double,
                               userLng: Double) -> GroupClassTapThroughData {

        let studioLat = doubleValue(item.studioLat, defaultValue: 0)
        let studioLng = doubleValue(item.studioLng, defaultValue: 0)

        var data = GroupClassTapThroughData()
        data.scheduleId = item.scheduleID.map { "\($0)" } ?? ""
        data.title = title(for: item)
        data.time = formatTimeForUI(item.time?.isEmpty == false ? item.time : item.start_end)
        data.location = locationText(for: item)
        data.image = item.image ?? ""
        data.trainedBy = item.trainedBy ?? ""
        data.trainerImage = item.trainerImage ?? ""
        data.price = item.price?.value ?? ""
        data.access = resolvedAccess(item.access)
        data.isMember = item.isMember ?? false
        data.bookedCount = intValue(item.bookedCount, defaultValue: 0)
        data.totalCapacity = intValue(item.totalCapacity, defaultValue: 20)
        data.remainingSeats = intValue(item.remainingSeats, defaultValue: 20)
        data.startEnd = item.start_end ?? ""
        data.distance = distanceText(userLat: userLat,
                                     userLng: userLng,
                                     studioLat: studioLat,
                                     studioLng: studioLng,
                                     fallback: item.distance)
        data.studioLat = studioLat
        data.studioLng = studioLng
        data.userLat = userLat
        data.userLng = userLng
        return data
    }
}
