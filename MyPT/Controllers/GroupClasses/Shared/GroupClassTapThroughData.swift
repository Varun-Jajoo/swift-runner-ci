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
    /// Seeded from the launching card so the detail screen doesn't flash
    /// "Book Slot" before flipping to "BOOKED" / "ON WAITLIST" once
    /// `fetchClassDetail()` confirms it a moment later.
    var isBooked: Bool = false
    var isWaitlisted: Bool = false
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
    /// Studio names in this app follow two conventions: "Venue, City" (take
    /// the part before the comma - the specific venue) or "Gym Type - Branch"
    /// (take the part after the hyphen - the specific branch, e.g.
    /// "Mixed Gym - Silicon Oasis" -> "Silicon Oasis").
    static func cleanStudioName(_ rawName: String?) -> String {
        let raw = (rawName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return defaultStudio }
        if let comma = raw.range(of: ",") {
            return String(raw[..<comma.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        guard let separator = raw.range(of: "-") else { return raw }
        return String(raw[separator.upperBound...]).trimmingCharacters(in: .whitespaces)
    }

    /// The other half of the same "Gym Type - Branch" name - the TYPE prefix
    /// (e.g. "DSO Ladies - Silicon Oasis" -> "DSO Ladies"), not the branch
    /// suffix `cleanStudioName` returns. Used for the group-class filter
    /// chips: was previously two hardcoded "Mixed Gym"/"Ladies Gym" tabs
    /// matched by fuzzy substring search, showing the same two labels
    /// regardless of which club a class actually belonged to - this derives
    /// the real per-studio label from the same raw name the card itself
    /// already carries. Android counterpart: `groupClassChipLabel()` in
    /// `GroupClassLocationUtils.kt`.
    static func chipLabel(_ rawName: String?) -> String {
        let raw = (rawName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return raw }
        if let range = raw.range(of: " - ") {
            return String(raw[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        if let comma = raw.range(of: ",") {
            return String(raw[..<comma.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return raw
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

    /// Card variant of `locationText`: same field priority/defaults, but keeps
    /// the studio-TYPE prefix (e.g. "DSO Ladies", "DSO Mixed") via `chipLabel`
    /// instead of the branch suffix `cleanStudioName` returns. Home carousel
    /// and See All cards use this; the detail page and booking-confirmation
    /// screens intentionally keep `cleanStudioName`'s branch text unchanged.
    static func cardLocationText(for item: UpcomingClassModel) -> String {
        let studioName = (item.studioName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !studioName.isEmpty { return chipLabel(studioName) }
        let location = (item.location ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !location.isEmpty { return chipLabel(location) }
        return chipLabel(defaultLocation)
    }

    // MARK: Time

    /// Formats the backend time into the card's `EEE, d MMM • h-h a` shape.
    /// Already-formatted values (they contain the bullet) are passed straight
    /// through, matching Android.
    static func formatTimeForUI(_ rawTimeStr: String?, dateStr: String? = nil) -> String {
        let raw = (rawTimeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return defaultTime }
        if raw.contains("•") { return raw }

        let clean = raw.replacingOccurrences(of: "GMT", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let hasDateInTime = clean.contains("202") || clean.contains("Jan") || clean.contains("Feb") ||
            clean.contains("Mar") || clean.contains("Apr") || clean.contains("May") ||
            clean.contains("Jun") || clean.contains("Jul") || clean.contains("Aug") ||
            clean.contains("Sep") || clean.contains("Oct") || clean.contains("Nov") || clean.contains("Dec")

        if hasDateInTime {
            let inputFormatter = DateFormatter()
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            inputFormatter.dateFormat = (clean.contains("-") && clean.count > 15) ? "yyyy-MM-dd HH:mm:ss" : "dd MMMM, HH:mm"

            if let date = inputFormatter.date(from: clean) {
                let dayFormatter = DateFormatter()
                dayFormatter.locale = Locale(identifier: "en_US_POSIX")
                dayFormatter.dateFormat = "EEE, d MMM"
                let dayText = dayFormatter.string(from: date)

                let startHour = Calendar.current.component(.hour, from: date)
                let endHour = (startHour + 1) % 24
                let start12 = (startHour % 12 == 0) ? 12 : startHour % 12
                let end12 = (endHour % 12 == 0) ? 12 : endHour % 12
                let amPm = (endHour >= 12 && endHour != 24) ? "PM" : "AM"

                return "\(dayText) • \(start12)-\(end12) \(amPm)"
            }
        } else if let dateStr = dateStr, !dateStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanDate = dateStr.replacingOccurrences(of: "GMT", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = cleanDate.contains("-") ? "yyyy-MM-dd" : "dd MMMM"

            if let date = dateFormatter.date(from: cleanDate) {
                let dayFormatter = DateFormatter()
                dayFormatter.locale = Locale(identifier: "en_US_POSIX")
                dayFormatter.dateFormat = "EEE, d MMM"
                let dayText = dayFormatter.string(from: date)
                let timeClean = clean.components(separatedBy: " ").first ?? clean
                return "\(dayText) • \(timeClean)"
            }
        }

        return raw
    }

    // MARK: Sorting

    /// The API has no raw sortable date field - each item only carries a
    /// pre-formatted display string like "Fri, 28 Aug • 7-8 AM" (year
    /// omitted), and the response array is grouped by category/class rather
    /// than sorted chronologically across all of them. This parses that
    /// string back into a comparable date so the home carousel can show the
    /// actual N closest-date upcoming classes, matching Android.
    ///
    /// Items whose time string fails to parse sort last rather than being
    /// dropped, so a formatting surprise never hides a class.
    static func closestUpcoming(_ classes: [UpcomingClassModel], limit: Int = 10) -> [UpcomingClassModel] {
        return classes
            .sorted { scheduleDate(for: $0) < scheduleDate(for: $1) }
            .prefix(limit)
            .map { $0 }
    }

    private static func scheduleDate(for item: UpcomingClassModel) -> Date {
        let raw = (item.time?.isEmpty == false) ? item.time : item.start_end
        return parseFormattedSchedule(raw ?? "")
    }

    /// Expects "EEE, d MMM • h-h a" (e.g. "Fri, 28 Aug • 7-8 AM").
    private static func parseFormattedSchedule(_ raw: String) -> Date {
        guard !raw.isEmpty else { return .distantFuture }

        let parts = raw.components(separatedBy: "•")
        guard parts.count == 2 else { return .distantFuture }

        let datePart = parts[0].trimmingCharacters(in: .whitespaces)
        let timePart = parts[1].trimmingCharacters(in: .whitespaces)

        guard let commaRange = datePart.range(of: ",") else { return .distantFuture }
        let dayMonth = String(datePart[commaRange.upperBound...]).trimmingCharacters(in: .whitespaces)

        let thisYear = Calendar.current.component(.year, from: Date())
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "d MMM yyyy"
        guard let parsedDate = inputFormatter.date(from: "\(dayMonth) \(thisYear)") else { return .distantFuture }

        // The API omits AM/PM on the start hour ("7-8 AM" means 7-8, both AM) -
        // borrow the trailing AM/PM for the start hour too.
        let isPM = timePart.uppercased().contains("PM")
        let startHourToken = timePart.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces) ?? "0"
        let startHour12 = Int(startHourToken) ?? 0
        let startHour24 = isPM ? (startHour12 % 12) + 12 : startHour12 % 12

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day], from: parsedDate)
        components.hour = startHour24
        components.minute = 0
        components.second = 0
        guard var finalDate = calendar.date(from: components) else { return .distantFuture }

        // The API only ever returns classes from today onward, so a parse
        // that lands in the past means the omitted year wrapped (e.g. today
        // is 28 Dec, class is "5 Jan" - that's next year, not this one).
        if finalDate < calendar.startOfDay(for: Date()) {
            finalDate = calendar.date(byAdding: .year, value: 1, to: finalDate) ?? finalDate
        }
        return finalDate
    }

    // MARK: Distance

    /// Great-circle distance from the device to the studio. Device location
    /// first (real GPS/cached UserDefaults reading), server-supplied
    /// `distance` string only as a last-resort fallback when the studio has
    /// no coordinates - never synthesizes a distance from `fallbackLatitude`/
    /// `fallbackLongitude` (Dubai defaults) the way this used to, since that's
    /// just as meaningless for a member nowhere near Dubai as trusting the
    /// server's own Dubai-default-based figure was. Android counterpart:
    /// `computeDeviceDistanceText()` in `GroupClassLocationUtils.kt`.
    static func distanceText(userLat: Double?,
                             userLng: Double?,
                             studioLat: Double?,
                             studioLng: Double?,
                             fallback: String?) -> String {

        var resolvedLat = userLat ?? 0
        var resolvedLng = userLng ?? 0

        if resolvedLat == 0 || resolvedLng == 0 {
            let stored = appUserDefaults.getLatLong()?.components(separatedBy: ",")
            resolvedLat = Double(stored?.first ?? "") ?? 0
            resolvedLng = Double(stored?.last ?? "") ?? 0
        }

        if resolvedLat != 0, resolvedLng != 0,
           let studioLat = studioLat, let studioLng = studioLng, studioLat != 0, studioLng != 0 {
            let meters = CLLocation(latitude: resolvedLat, longitude: resolvedLng)
                .distance(from: CLLocation(latitude: studioLat, longitude: studioLng))
            if meters < 1000 {
                return "\(Int(meters)) m away"
            }
            return String(format: "%.1f km away", meters / 1000.0)
        }

        let cleanFallback = (fallback ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanFallback.isEmpty,
              !cleanFallback.hasPrefix("0.0"),
              cleanFallback.caseInsensitiveCompare("away") != .orderedSame,
              !cleanFallback.hasPrefix("2.1 km") else { return "" }
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
        if raw.lowercased().hasPrefix("http://") {
            // Laravel's `asset()` mirrors the request scheme it was called under,
            // so a backend `APP_URL` misconfigured as plain http leaks a "http://"
            // image URL here. Info.plist's ATS exception list only covers the
            // CCAvenue payment domain, not the API host, so a plain-http image
            // silently fails to load (blank card fill) instead of erroring loudly
            // - the same class renders fine on Android, which has no such
            // restriction. The app's own API traffic to this exact host is
            // always https (`AppBaseUrl.baseScheme`), so upgrading is safe.
            return "https://" + String(raw.dropFirst("http://".count))
        }
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
        data.isBooked = item.isBooked ?? false
        data.isWaitlisted = item.isWaitlisted ?? false
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
