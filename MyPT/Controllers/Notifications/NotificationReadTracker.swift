//
//  NotificationReadTracker.swift
//  MyPT
//
//  Fire-and-forget mark-read call, shared by NotificationsViewController's
//  row tap and AppDelegate's actual push-tap handler - see
//  NotificationController::markReadByContext()'s doc comment on the backend
//  for why this is a best-effort (type + schedule_id) match rather than an
//  exact id lookup on this platform. Android equivalent:
//  NotificationsActivity.markReadByContext() (companion function).
//

import Foundation

enum NotificationReadTracker {

    static func markReadByContext(pushType: String, scheduleId: String?) {
        guard !pushType.isEmpty else { return }
        var params: [String: Any] = ["type": pushType]
        if let scheduleId = scheduleId, !scheduleId.isEmpty {
            params["schedule_id"] = scheduleId
        }
        NetworkManager.shared.genericAPICall(serviceEndPoint: .notifications_mark_read_by_context,
                                             method: .post,
                                             parameters: params,
                                             isShowLoading: false) { _, _ in }
    }
}
