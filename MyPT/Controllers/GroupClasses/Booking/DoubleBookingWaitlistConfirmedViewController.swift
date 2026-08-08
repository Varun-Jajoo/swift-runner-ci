//
//  DoubleBookingWaitlistConfirmedViewController.swift
//  MyPT
//
//  Double Booking Waitlist Confirmation Screen.
//

import UIKit

final class DoubleBookingWaitlistConfirmedViewController: CommonViewController {

    var classTitle: String = "Morning Flow Yoga"
    var classTime: String = "Wed, 9 Jul • 7-8 AM"
    var classLocation: String = "Silicon Oasis"
    var trainerName: String = ""
    var distance: String = ""

    private enum Metric {
        static let horizontalInset: CGFloat = 20
        static let backButtonDiameter: CGFloat = 40
        static let badgeSide: CGFloat = 120
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let iconTileSide: CGFloat = 38
        static let notifyIconTileSide: CGFloat = 38
        static let ctaHeight: CGFloat = 48
    }

    private enum Palette {
        static let headerTitle = UIColor(hex: "#FAFAFA")
        static let headerSubtext = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let divider = UIColor.white.withAlphaComponent(0.10)
        static let cardFill = UIColor(hex: "#18191C")
        static let cardStroke = UIColor(hex: "#232323")
        static let tileFill = UIColor(hex: "#101113")
        static let pillStroke = UIColor(hex: "#FAFAFA")
        static let pillFill = UIColor.white.withAlphaComponent(0.10)
        static let pillText = UIColor(hex: "#FFCC33")
        static let rowTitle = UIColor(hex: "#FAFAFA")
        static let rowSubtitle = UIColor(hex: "#FAFAFA").withAlphaComponent(0.55)
        static let infoBoxFill = UIColor(hex: "#121415")
        static let infoBoxBorder = UIColor(hex: "#FFCC33").withAlphaComponent(0.3)
        static let infoBoxText = UIColor(hex: "#FAFAFA").withAlphaComponent(0.85)
        static let ctaFill = UIColor(hex: "#CCFF00")
        static let ctaText = UIColor.black
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let backButton = UIButton(type: .custom)
    private let badgeView = SlotConfirmedSuccessBadgeView()

    private let headerTitleLabel = UILabel()
    private let headerSubtextLabel = UILabel()

    private let detailsCardView = UIView()
    private let categoryPillLabel = UILabel()
    private let classTitleLabel = UILabel()
    private let dateTimeLabel = UILabel()

    private let locationRowView = UIView()
    private let locationTitleLabel = UILabel()
    private let locationDistanceLabel = UILabel()

    private let trainerRowView = UIView()
    private let trainerNameLabel = UILabel()

    private let infoBoxView = UIView()
    private let infoTextLabel = UILabel()

    private let ctaContainerView = UIView()
    private let viewBookingButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        populateData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#050607")
        setupScrollView()
        setupHeader()
        setupDetailsCard()
        setupInfoBox()
        setupCTA()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHeader() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "ic_back_chevron_20") ?? UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        backButton.layer.cornerRadius = Metric.backButtonDiameter / 2
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        badgeView.translatesAutoresizingMaskIntoConstraints = false

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        headerTitleLabel.textColor = Palette.headerTitle
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.text = "You're on the waitlist"

        headerSubtextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtextLabel.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        headerSubtextLabel.textColor = Palette.headerSubtext
        headerSubtextLabel.textAlignment = .center
        headerSubtextLabel.numberOfLines = 0
        headerSubtextLabel.text = "You already have an overlapping booking. We'll notify you as soon as a spot opens up and your priority window opens."

        contentView.addSubview(backButton)
        contentView.addSubview(badgeView)
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerSubtextLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            backButton.widthAnchor.constraint(equalToConstant: Metric.backButtonDiameter),
            backButton.heightAnchor.constraint(equalToConstant: Metric.backButtonDiameter),

            badgeView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            badgeView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: Metric.badgeSide),
            badgeView.heightAnchor.constraint(equalToConstant: Metric.badgeSide),

            headerTitleLabel.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: 20),
            headerTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            headerTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            headerSubtextLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 8),
            headerSubtextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            headerSubtextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset)
        ])
    }

    private func setupDetailsCard() {
        detailsCardView.translatesAutoresizingMaskIntoConstraints = false
        detailsCardView.backgroundColor = Palette.cardFill
        detailsCardView.layer.cornerRadius = Metric.cardCornerRadius
        detailsCardView.layer.borderWidth = 1
        detailsCardView.layer.borderColor = Palette.cardStroke.cgColor

        categoryPillLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryPillLabel.font = AppFont.medium.size(11.0, familyName: familyFunnelSans)
        categoryPillLabel.textColor = Palette.pillText
        categoryPillLabel.text = "OVERLAPPING WAITLIST"

        classTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        classTitleLabel.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        classTitleLabel.textColor = .white
        classTitleLabel.numberOfLines = 2

        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        dateTimeLabel.textColor = Palette.rowSubtitle

        locationRowView.translatesAutoresizingMaskIntoConstraints = false
        locationTitleLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        locationTitleLabel.textColor = Palette.rowTitle
        locationDistanceLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        locationDistanceLabel.textColor = Palette.rowSubtitle

        trainerRowView.translatesAutoresizingMaskIntoConstraints = false
        trainerNameLabel.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        trainerNameLabel.textColor = Palette.rowTitle

        contentView.addSubview(detailsCardView)
        detailsCardView.addSubview(categoryPillLabel)
        detailsCardView.addSubview(classTitleLabel)
        detailsCardView.addSubview(dateTimeLabel)

        NSLayoutConstraint.activate([
            detailsCardView.topAnchor.constraint(equalTo: headerSubtextLabel.bottomAnchor, constant: 24),
            detailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            detailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            categoryPillLabel.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: Metric.cardPadding),
            categoryPillLabel.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: Metric.cardPadding),

            classTitleLabel.topAnchor.constraint(equalTo: categoryPillLabel.bottomAnchor, constant: 8),
            classTitleLabel.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: Metric.cardPadding),
            classTitleLabel.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -Metric.cardPadding),

            dateTimeLabel.topAnchor.constraint(equalTo: classTitleLabel.bottomAnchor, constant: 4),
            dateTimeLabel.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: Metric.cardPadding),
            dateTimeLabel.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: -Metric.cardPadding)
        ])
    }

    private func setupInfoBox() {
        infoBoxView.translatesAutoresizingMaskIntoConstraints = false
        infoBoxView.backgroundColor = Palette.infoBoxFill
        infoBoxView.layer.cornerRadius = 12
        infoBoxView.layer.borderWidth = 1
        infoBoxView.layer.borderColor = Palette.infoBoxBorder.cgColor

        infoTextLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTextLabel.font = AppFont.medium.size(13.0, familyName: familyFunnelSans)
        infoTextLabel.textColor = Palette.infoBoxText
        infoTextLabel.numberOfLines = 0
        infoTextLabel.text = "Priority Notice: Your waitlist position for this overlapping slot becomes active 3 hours prior to class start or if your existing booking is cancelled."

        contentView.addSubview(infoBoxView)
        infoBoxView.addSubview(infoTextLabel)

        NSLayoutConstraint.activate([
            infoBoxView.topAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: 16),
            infoBoxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            infoBoxView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            infoTextLabel.topAnchor.constraint(equalTo: infoBoxView.topAnchor, constant: 14),
            infoTextLabel.leadingAnchor.constraint(equalTo: infoBoxView.leadingAnchor, constant: 14),
            infoTextLabel.trailingAnchor.constraint(equalTo: infoBoxView.trailingAnchor, constant: -14),
            infoTextLabel.bottomAnchor.constraint(equalTo: infoBoxView.bottomAnchor, constant: -14)
        ])
    }

    private func setupCTA() {
        ctaContainerView.translatesAutoresizingMaskIntoConstraints = false
        ctaContainerView.backgroundColor = UIColor(hex: "#0A0D0C")

        viewBookingButton.translatesAutoresizingMaskIntoConstraints = false
        viewBookingButton.setTitle("View Bookings", for: .normal)
        viewBookingButton.setTitleColor(Palette.ctaText, for: .normal)
        viewBookingButton.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        viewBookingButton.backgroundColor = Palette.ctaFill
        viewBookingButton.layer.cornerRadius = 24
        viewBookingButton.addTarget(self, action: #selector(didTapViewBookings), for: .touchUpInside)

        view.addSubview(ctaContainerView)
        ctaContainerView.addSubview(viewBookingButton)

        NSLayoutConstraint.activate([
            ctaContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ctaContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ctaContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            viewBookingButton.topAnchor.constraint(equalTo: ctaContainerView.topAnchor, constant: 12),
            viewBookingButton.leadingAnchor.constraint(equalTo: ctaContainerView.leadingAnchor, constant: 20),
            viewBookingButton.trailingAnchor.constraint(equalTo: ctaContainerView.trailingAnchor, constant: -20),
            viewBookingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            viewBookingButton.heightAnchor.constraint(equalToConstant: Metric.ctaHeight),

            scrollView.bottomAnchor.constraint(equalTo: ctaContainerView.topAnchor)
        ])
    }

    private func populateData() {
        classTitleLabel.text = classTitle
        dateTimeLabel.text = classTime
        locationTitleLabel.text = classLocation
        locationDistanceLabel.text = distance.isEmpty ? "" : (distance.contains("away") ? distance : "\(distance) away")
        trainerNameLabel.text = trainerName.isEmpty ? "" : (trainerName.hasPrefix("Trainer:") ? trainerName : "Trainer: \(trainerName)")
    }

    @objc private func didTapBack() {
        dismiss(animated: true)
    }

    @objc private func didTapViewBookings() {
        dismiss(animated: true)
    }
}
