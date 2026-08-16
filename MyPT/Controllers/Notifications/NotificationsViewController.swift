//
//  NotificationsViewController.swift
//  MyPT
//
//  Real notification list. Android reference: NotificationsActivity.kt /
//  NotificationsAdapter.kt (same grouping, same icon/colour-per-type rules,
//  same read/unread visual language) - kept in lockstep deliberately so a
//  design change to one obviously needs the same change on the other.
//
//  Backend: GET api/notifications (paginated, `unread_count` in the
//  envelope), POST api/notifications/mark-read-by-context (best-effort
//  match on notification_type + schedule_id - see
//  NotificationController::markReadByContext()'s own doc comment on why
//  this isn't an exact id lookup on this platform; Android's list-tap path
//  uses the exact-id endpoint instead, this one uses context-match for
//  both list-tap and push-tap so iOS only needs the one endpoint).
//

import UIKit

struct NotificationEntry {
    let id: Int
    let title: String
    let message: String
    let notificationType: String
    let data: [String: String]
    var isRead: Bool
    let createdAt: Date
}

final class NotificationsViewController: CommonViewController {

    private enum Palette {
        static let bg = UIColor(hex: "#000A04")
        static let title = UIColor.white
        static let sectionLabel = UIColor(hex: "#959595")
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let cardUnreadFill = UIColor(hex: "#0A0A0B")
        static let cardUnreadStroke = UIColor(hex: "#E0FE08").withAlphaComponent(0.05)
        static let cardReadFill = UIColor(hex: "#1E1E1F")
        static let cardReadStroke = UIColor(hex: "#232323")
        static let tileReadFill = UIColor(hex: "#131416")
        static let tileReadStroke = UIColor(hex: "#101113")
        static let subtext = UIColor(hex: "#959595")
        static let time = UIColor.white.withAlphaComponent(0.28)
        static let dotUnread = UIColor(hex: "#E0FE08")
        static let dotRead = UIColor.white.withAlphaComponent(0.30)
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    private var sections: [(label: String, entries: [NotificationEntry])] = []
    private var allEntries: [NotificationEntry] = []
    private var currentPage = 1
    private var lastPage = 1
    private var isLoadingMore = false

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        buildLayout()
        loadPage(1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: Networking

    private func loadPage(_ page: Int) {
        isLoadingMore = true
        if page == 1 { spinner.startAnimating() }

        NetworkManager.shared.genericAPICall(serviceEndPoint: .notifications,
                                             method: .get,
                                             queries: ["page": "\(page)"],
                                             isShowLoading: false) { [weak self] responseData, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingMore = false
                self.spinner.stopAnimating()
                self.handleListResponse(responseData, page: page)
            }
        }
    }

    private func handleListResponse(_ responseData: Data?, page: Int) {
        guard let data = responseData,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              json["status"] as? Bool == true,
              let payload = json["data"] as? [String: Any],
              let array = payload["notifications"] as? [[String: Any]] else {
            if page == 1 { showEmptyState(true) }
            return
        }

        currentPage = payload["current_page"] as? Int ?? page
        lastPage = payload["last_page"] as? Int ?? page

        let parsed = array.compactMap { NotificationsViewController.parseEntry($0) }
        allEntries = page == 1 ? parsed : allEntries + parsed
        sections = NotificationsViewController.bucket(allEntries)
        tableView.reloadData()
        showEmptyState(allEntries.isEmpty)
    }

    private static func parseEntry(_ obj: [String: Any]) -> NotificationEntry? {
        guard let id = obj["id"] as? Int else { return nil }
        var dataMap: [String: String] = [:]
        if let dataObj = obj["data"] as? [String: Any] {
            for (key, value) in dataObj { dataMap[key] = "\(value)" }
        }
        return NotificationEntry(
            id: id,
            title: obj["title"] as? String ?? "MyPT",
            message: obj["message"] as? String ?? "",
            notificationType: obj["notification_type"] as? String ?? "",
            data: dataMap,
            isRead: obj["is_read"] as? Bool ?? false,
            createdAt: NotificationsViewController.parseDate(obj["created_at"] as? String) ?? Date()
        )
    }

    /// Carbon's default `created_at` JSON format is 6-digit microseconds
    /// (`"2026-08-15T16:00:26.000000Z"`) - `ISO8601DateFormatter` is usually
    /// fine with that, but a wrong grouping (a real timestamp silently
    /// falling back to "now" via the `?? Date()` at every call site) is bad
    /// enough to guard explicitly rather than trust it blindly: truncate to
    /// milliseconds and retry once more before giving up.
    private static func parseDate(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) { return date }

        if let dotIndex = string.firstIndex(of: "."), let zIndex = string.firstIndex(of: "Z") {
            let fractional = string[string.index(after: dotIndex)..<zIndex]
            let truncated = String(fractional.prefix(3))
            let rebuilt = String(string[string.startIndex...dotIndex]) + truncated + "Z"
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: rebuilt) { return date }
        }
        return nil
    }

    /// Today / Yesterday / This Week / This Month / Older, in that order -
    /// sections with nothing in them are dropped entirely, same as Android.
    private static func bucket(_ entries: [NotificationEntry]) -> [(label: String, entries: [NotificationEntry])] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfToday)!
        let startOfMonth = calendar.date(byAdding: .day, value: -30, to: startOfToday)!

        var today: [NotificationEntry] = []
        var yesterday: [NotificationEntry] = []
        var thisWeek: [NotificationEntry] = []
        var thisMonth: [NotificationEntry] = []
        var older: [NotificationEntry] = []

        for entry in entries {
            if entry.createdAt >= startOfToday { today.append(entry) }
            else if entry.createdAt >= startOfYesterday { yesterday.append(entry) }
            else if entry.createdAt >= startOfWeek { thisWeek.append(entry) }
            else if entry.createdAt >= startOfMonth { thisMonth.append(entry) }
            else { older.append(entry) }
        }

        var result: [(label: String, entries: [NotificationEntry])] = []
        if !today.isEmpty { result.append(("TODAY", today)) }
        if !yesterday.isEmpty { result.append(("YESTERDAY", yesterday)) }
        if !thisWeek.isEmpty { result.append(("THIS WEEK", thisWeek)) }
        if !thisMonth.isEmpty { result.append(("THIS MONTH", thisMonth)) }
        if !older.isEmpty { result.append(("OLDER", older)) }
        return result
    }

    private func showEmptyState(_ isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    // MARK: Row tap

    private func rowTapped(_ entry: NotificationEntry) {
        if !entry.isRead, let index = allEntries.firstIndex(where: { $0.id == entry.id }) {
            allEntries[index].isRead = true
            sections = NotificationsViewController.bucket(allEntries)
            tableView.reloadData()
            NotificationReadTracker.markReadByContext(
                pushType: NotificationRouting.pushType(forNotificationType: entry.notificationType),
                scheduleId: entry.data["schedule_id"])
        }
        NotificationRouting.route(notificationType: entry.notificationType, data: entry.data)
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Layout

private extension NotificationsViewController {

    func buildLayout() {
        let closeButton = GlassCircularIconButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.configure(icon: UIImage(systemName: "chevron.left"), diameter: 40)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Notifications"
        titleLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        titleLabel.textColor = Palette.title
        view.addSubview(titleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationRowCell.self, forCellReuseIdentifier: NotificationRowCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.sectionHeaderTopPadding = 0
        view.addSubview(tableView)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No notifications yet"
        emptyLabel.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        emptyLabel.textColor = Palette.subtext
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            // Left-aligned right after the close button + a gap - not
            // centered on the screen (reads as unrelated to the icon) and
            // not centered in the remaining space either (still visually
            // drifts away from the icon).
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 80),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource / Delegate

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationRowCell.reuseIdentifier, for: indexPath) as? NotificationRowCell else {
            return UITableViewCell()
        }
        let entry = sections[indexPath.section].entries[indexPath.row]
        cell.configure(entry: entry, palette: (Palette.cardUnreadFill, Palette.cardUnreadStroke, Palette.cardReadFill, Palette.cardReadStroke, Palette.tileReadFill, Palette.tileReadStroke, Palette.subtext, Palette.time, Palette.dotUnread, Palette.dotRead))
        cell.onTapped = { [weak self] in self?.rowTapped(entry) }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .clear

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sections[section].label
        label.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        label.textColor = Palette.sectionLabel
        container.addSubview(label)

        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = Palette.divider
        container.addSubview(line)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            line.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 32 : 52
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == sections.count - 1,
              indexPath.row >= sections[indexPath.section].entries.count - 5,
              !isLoadingMore, currentPage < lastPage else { return }
        loadPage(currentPage + 1)
    }
}
