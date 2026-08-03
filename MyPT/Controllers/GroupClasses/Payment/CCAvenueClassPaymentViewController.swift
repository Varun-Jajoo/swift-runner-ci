//
//  CCAvenueClassPaymentViewController.swift
//  MyPT
//
//  Card-payment WebView for a group-class booking, reached from Class Payment's
//  "CONFIRM AND PAY" CTA when Card is selected.
//
//  Android reference (ground truth): `CCavenueWebCLassActivity.kt` +
//  `activity_ccavenue_web_class.xml`.
//
//  Deliberately NOT built on top of the existing `CCAvenuePaymentViewController`
//  (used by subscription purchases): that screen's `POST api/payment/session`
//  returns `{data: {html, ...}}` — a JSON-wrapped contract with no confirmed
//  support for a class-booking `payment_for`/`schedule_id`. This screen instead
//  ports Android's own, currently-working contract verbatim: `GET api/pay?amount=`
//  returns the CCAvenue gateway page as raw HTML, loaded straight into the
//  WebView (see the migration plan's Phase 8 section for the reasoning — the
//  live/staging backend was not available to verify the JSON contract, so this
//  follows the one path known to work in production today).
//
//  One deliberate improvement over Android: `CCavenueWebCLassActivity` navigates
//  straight to `SlotConfirmedActivity` the moment the redirect URL contains
//  "payment/success", without ever POSTing `book-class` itself — it relies on
//  `SlotConfirmedActivity`'s own deferred `sendBookingData()` (fired only because
//  Android passes `schedule_id` through), which does not correct course if that
//  POST fails. Since money has already changed hands by this point, this screen
//  POSTs `book-class` explicitly and only proceeds to Slot Confirmed on a
//  genuine success — the same shape Phase 7's Tabby path already uses, for the
//  same reason.
//

import UIKit
@preconcurrency import WebKit

final class CCAvenueClassPaymentViewController: CommonViewController, WKNavigationDelegate {

    // MARK: - Input

    var scheduleId: String = ""
    var classTitle: String = ""
    var classTime: String = ""
    var classLocation: String = ""
    var trainerName: String = ""
    var distance: String = ""
    /// Already-cleaned numeric price string (e.g. `"179"`), as
    /// `ClassPaymentViewController.cleanedPrice()` produces.
    var price: String = ""

    // MARK: - Views

    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        return WKWebView(frame: .zero, configuration: configuration)
    }()

    private let backButton = GlassCircularIconButton()
    private let headerTitleLabel = UILabel()

    // MARK: - Lifecycle

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color
        buildLayout()
        loadPaymentGateway()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Network — GET api/pay?amount= (raw HTML gateway page)

    /// Port of `CCavenueWebCLassActivity.getCcavenueWeb()`.
    private func loadPaymentGateway() {
        webView.navigationDelegate = self

        NetworkManager.shared.genericAPICall(serviceEndPoint: .class_ccavenue_pay,
                                             method: .get,
                                             queries: ["amount": price],
                                             isShowLoading: true) { [weak self] data, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleGatewayResponse(data)
            }
        }
    }

    private func handleGatewayResponse(_ data: Data?) {
        guard let data = data, let html = String(data: data, encoding: .utf8), !html.isEmpty else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Unable to load the payment page. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        // Android: `respStr.contains("Unauthenticated"/"Unauthorized", ignoreCase = true)`.
        if html.range(of: "unauthenticated", options: .caseInsensitive) != nil ||
            html.range(of: "unauthorized", options: .caseInsensitive) != nil {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Session expired. Please log in again.", actions: ["OK"]) { [weak self] _ in
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
                self?.navigationController?.popViewController(animated: false)
            }
            return
        }

        webView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let absoluteString = url.absoluteString
        if absoluteString.range(of: "payment/success", options: .caseInsensitive) != nil {
            // Android: `url.substringAfterLast("/")`.
            let transactionId = url.pathComponents.last ?? ""
            completeBooking(transactionId: transactionId)
            decisionHandler(.cancel)
            return
        }

        if absoluteString.range(of: "payment/cancelled", options: .caseInsensitive) != nil {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Transaction Failed!", actions: ["OK"]) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    // MARK: - Network — POST api/book-class (see the file-header note on this divergence)

    private func completeBooking(transactionId: String) {
        UpcomingClassVM.bookGroupClassApi(scheduleId: scheduleId,
                                          transactionId: transactionId,
                                          paymentType: "ccavenue") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleBookingResponse(result)
            }
        }
    }

    private func handleBookingResponse(_ result: BookClassBaseModel?) {
        guard let result = result else {
            AlertHelper.shared.showCustomeAlert(title: "", message: "Booking failed. Please try again.", actions: ["OK"], completion: nil)
            return
        }

        if result.status == true {
            pushSlotConfirmed()
            return
        }

        if isBlacklisted(result) {
            let controller = BookingPausedViewController()
            controller.reason = result.blacklistDetail?.reason ?? "2 consecutive no-shows for group classes"
            controller.resumesOn = result.blacklistDetail?.resumesOn ?? "12 August 2026"
            controller.daysRemaining = result.blacklistDetail?.daysRemaining?.value ?? "6"
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let trimmedMessage = (result.msg ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? "Booking failed. Please try again." : trimmedMessage
        AlertHelper.shared.showCustomeAlert(title: "", message: message, actions: ["OK"], completion: nil)
    }

    private func isBlacklisted(_ model: BookClassBaseModel) -> Bool {
        if model.isBlacklisted == true { return true }
        if model.code == "BLACKLISTED" { return true }
        let lowered = (model.msg ?? "").lowercased()
        return lowered.contains("blacklisted") || lowered.contains("paused")
    }

    private func pushSlotConfirmed() {
        let controller = SlotConfirmedViewController()
        controller.classTitle = classTitle
        controller.classTime = classTime
        controller.classLocation = classLocation
        controller.trainerName = trainerName
        controller.distance = distance
        controller.classPrice = price
        // scheduleId intentionally left blank — this screen already POSTed
        // book-class above; see Phase 6's SlotConfirmedViewController.sendBookingData.
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Layout

private extension CCAvenueClassPaymentViewController {

    func buildLayout() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .clear
        view.addSubview(header)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: CCAvenueClassPaymentViewController.icon(["ic_chevron_left_24", "ic_back_arrow", "ic_arrow_left"]),
                             diameter: 40)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        header.addSubview(backButton)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        headerTitleLabel.textColor = .white
        headerTitleLabel.text = "Secure Payment"
        header.addSubview(headerTitleLabel)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: header.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            headerTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            headerTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: header.trailingAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            webView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension CCAvenueClassPaymentViewController {

    static func icon(_ names: [String]) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        return nil
    }
}
