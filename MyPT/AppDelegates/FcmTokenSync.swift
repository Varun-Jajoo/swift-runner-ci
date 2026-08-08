//
//  FcmTokenSync.swift
//  MyPT
//
//  Keeps the server's copy of this device's FCM registration token current.
//
//  Registering the token only at login is not enough: Firebase rotates tokens
//  on reinstall, app data clear, device restore and Firebase Installation ID
//  reissue, and expires registrations inactive for 270 days. Without this,
//  `AppDelegate.messaging(_:didReceiveRegistrationToken:)` saved a refreshed
//  token to UserDefaults ("Optionally send to your server" was never
//  implemented) and the backend kept pushing to the old, dead token until the
//  user happened to log in again - the exact bug behind notifications working
//  for a while and then silently stopping.
//
//  Port of Android's `co.com.FCM.FcmTokenSync` (`onNewToken` calls
//  `FcmTokenSync.upload(this, token)` there); mirrors it 1:1 so both
//  platforms behave the same way.
//

import Foundation

enum FcmTokenSync {

    private static let syncedTokenKey = "fcm_token_synced_value"
    private static let syncedAtKey = "fcm_token_synced_at"

    /// Firebase recommends refreshing at least monthly; a week for headroom.
    private static let refreshIntervalSeconds: TimeInterval = 7 * 24 * 60 * 60

    /// Uploads `token` if the server's copy is missing, different, or older
    /// than `refreshIntervalSeconds`. Safe to call on every app start and from
    /// the token-refresh callback.
    static func sync(token: String?) {
        guard let token = token, !token.isEmpty else { return }
        if needsUpload(token) {
            upload(token)
        }
    }

    /// No-op when the user isn't logged in - the login/OTP request already
    /// carries the token in that case, and this runs again once a session exists.
    static func upload(_ token: String) {
        guard let accessToken = appUserDefaults.getAccessToken(), !accessToken.isEmpty else {
            return
        }

        let params: [String: Any] = [
            "device_token": token,
            "device_type": "ios"
        ]

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sync_device_token,
                                             method: .post,
                                             parameters: params,
                                             isShowLoading: false) { responseData, _ in
            // Deliberately silent on failure: this is background maintenance
            // and the next app start (or next token refresh) retries it -
            // there's no user-facing action to blame a network hiccup on here.
            guard let responseData = responseData,
                  let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                  (json["status"] as? Bool) == true else {
                return
            }
            UserDefaults.standard.set(token, forKey: syncedTokenKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: syncedAtKey)
        }
    }

    private static func needsUpload(_ token: String) -> Bool {
        let syncedToken = UserDefaults.standard.string(forKey: syncedTokenKey) ?? ""
        if syncedToken != token { return true }

        let syncedAt = UserDefaults.standard.double(forKey: syncedAtKey)
        return Date().timeIntervalSince1970 - syncedAt > refreshIntervalSeconds
    }
}
