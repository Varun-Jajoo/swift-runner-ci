//
//  GroupClassesCarouselView.swift
//  MyPT
//
//  Self-contained "Group Classes" home section: horizontal card carousel +
//  dots indicator (+ a currently-hidden "SEE ALL GROUP TRAININGS" CTA).
//
//  Android reference: the `groupClassesSection` block in
//  `res/layout/fragment_active_user_home_new.xml` /
//  `res/layout/fragment_guest_user_home_new.xml`, driven by
//  `setupGroupClassesSection()` in the two home fragments.
//

import UIKit

// MARK: - CapsuleView

/// A view that keeps itself a perfect capsule.
///
/// This exists because the two previous attempts at rounding the dots pill both
/// failed, for two different reasons:
///
///   1. `cornerRadius = bounds.height / 2` set inside `setupViews()` — bounds are
///      still `.zero` at construction, so the radius resolved to 0.
///   2. `cornerRadius = 999` — unlike CSS `border-radius`, CALayer does NOT clamp
///      an oversized radius to a capsule. On a 13pt-tall pill it renders square.
///
/// A third attempt (setting it from the *carousel's* `layoutSubviews`) also fails:
/// the pill is a grandchild — it sits inside `dotsRow` — so its frame has not been
/// resolved yet when the carousel lays out, and the height read there is still 0.
///
/// Doing it in the view's own `layoutSubviews` is the only placement that is
/// correct regardless of layout timing or of the pill's eventual height. Same
/// pattern `GroupClassUIComponents.swift` already uses for its circular button.
final class CapsuleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

// MARK: - GroupClassCarouselDotsView

/// Worm-style page indicator: the selected page is a 25×5 pill, the rest are
/// 5×5 dots. Port of Android's `utils/CarouselIndicatorView`.
final class GroupClassCarouselDotsView: UIView {

    private static let dotSize: CGFloat = 5
    private static let selectedWidth: CGFloat = 25
    private static let spacing: CGFloat = 4
    private static let selectedColor = UIColor(hex: "#FAFAFA")
    private static let unselectedColor = UIColor(hex: "#31343A")

    private let stackView = UIStackView()
    private var dotViews: [UIView] = []
    private var widthConstraints: [NSLayoutConstraint] = []

    private(set) var pageCount: Int = 0
    private(set) var selectedPage: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        // Cross-axis centring: the 5pt dots and the 5pt-tall host view already
        // match, but `.fill` (the default) fights a dot's own required height
        // constraint whenever it doesn't, which is what made the pill render
        // taller than Android's 5dp indicator.
        stackView.alignment = .center
        stackView.spacing = GroupClassCarouselDotsView.spacing
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func setPageCount(_ count: Int) {
        pageCount = max(count, 0)
        selectedPage = min(selectedPage, max(pageCount - 1, 0))

        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        widthConstraints.removeAll()

        for _ in 0..<pageCount {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = GroupClassCarouselDotsView.dotSize / 2
            dot.layer.masksToBounds = true

            let widthConstraint = dot.widthAnchor.constraint(equalToConstant: GroupClassCarouselDotsView.dotSize)
            widthConstraint.isActive = true
            widthConstraints.append(widthConstraint)
            dot.heightAnchor.constraint(equalToConstant: GroupClassCarouselDotsView.dotSize).isActive = true

            stackView.addArrangedSubview(dot)
            dotViews.append(dot)
        }

        applySelection()
    }

    func setSelectedPage(_ page: Int) {
        guard pageCount > 0 else { return }
        let clamped = min(max(page, 0), pageCount - 1)
        guard clamped != selectedPage else { return }
        selectedPage = clamped
        // The selected dot grows 5pt -> 25pt and swaps colour. Writing that
        // straight into the width constraint makes it jump; animating the layout
        // pass lets it glide instead. `.beginFromCurrentState` so a fast scroll
        // across several pages retargets mid-flight rather than restarting each
        // time. setPageCount()'s own applySelection() stays unanimated — that's
        // initial construction, not a transition.
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.applySelection()
            self.layoutIfNeeded()
        }
    }

    private func applySelection() {
        for (index, dot) in dotViews.enumerated() {
            let isSelected = (index == selectedPage)
            widthConstraints[index].constant = isSelected
                ? GroupClassCarouselDotsView.selectedWidth
                : GroupClassCarouselDotsView.dotSize
            dot.backgroundColor = isSelected
                ? GroupClassCarouselDotsView.selectedColor
                : GroupClassCarouselDotsView.unselectedColor
            // Exactly half the dot's own 5pt height, not a fixed larger
            // value assumed to clamp - Android's equivalent (`CarouselIndicatorView`)
            // used to request a flat 8dp against a 5dp bar and rendered with
            // visibly squared corners on some paths; this stays a guaranteed
            // capsule regardless of the bar's width.
            dot.layer.cornerRadius = GroupClassCarouselDotsView.dotSize / 2
            dot.layer.masksToBounds = true
        }
    }
}

// MARK: - GroupClassesCarouselView

final class GroupClassesCarouselView: UIView {

    // Card 230×318 with a 10pt gutter, inside a 328pt-tall strip — Android's
    // `item_group_class_card.xml` dimensions and the 328dp RecyclerView height
    // (bumped from 250dp when the card itself grew from 180×240 to fit the new
    // BOOKED/ON WAITLIST states; the old 250pt height here was never updated to
    // match, clipping the bottom of every card).
    private static let cardSpacing: CGFloat = 10
    private static let carouselHeight: CGFloat = 328
    private static let sectionHorizontalInset: CGFloat = 16
    // Android's `groupClassesSection` FrameLayout: fixed 780dp height (ported 1:1
    // as points, matching this file's existing dp->pt convention), `#32615C`
    // background fill, and the banner image (`match_parent` width / `wrap_content`
    // height / `fitStart` / `gravity="top"`, i.e. scaled to the full section width,
    // preserving its own aspect ratio, anchored to the top) - the carousel/dots/
    // button column sits bottom-aligned inside a 20dp-bottom-padded area on top of
    // whichever is taller, the image or that column.
    private static let sectionHeight: CGFloat = 780
    // Must track the artwork's actual pixel dimensions - it was re-exported at
    // 1290×2235 (was 430×745), so this needs updating again if the asset changes.
    private static let bannerAspectRatio: CGFloat = 2235.0 / 1290.0
    private static let sectionBottomInset: CGFloat = 20
    private static let sectionFill = UIColor(hex: "#32615C")

    /// Fired when a card is tapped, with the fully-derived tap-through payload.
    var onSelectClass: ((GroupClassTapThroughData) -> Void)?
    /// Fired when "SEE ALL GROUP TRAININGS" is tapped. The carousel has no
    /// navigation controller of its own, so the owning screen supplies this.
    var onSeeAllTapped: (() -> Void)?

    private(set) var classes: [UpcomingClassModel] = []

    /// Fingerprint of the currently-rendered payload, so a repeat fetch that
    /// returns the same data doesn't trigger a visible rebuild.
    private var renderedSignature: String?

    /// Device location used for the fetch and for per-card distance maths.
    private var userLat: Double = GroupClassCardFormatter.fallbackLatitude
    private var userLng: Double = GroupClassCardFormatter.fallbackLongitude

    private let backgroundView = UIImageView()
    private let contentStack = UIStackView()
    private let collectionView: UICollectionView
    private let dotsView = GroupClassCarouselDotsView()
    private let dotsPill = CapsuleView()
    private let seeAllButton = GradientCTAButton()

    // MARK: Init

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = GroupClassCardCollectionViewCell.cardSize
        layout.minimumLineSpacing = GroupClassesCarouselView.cardSpacing
        layout.minimumInteritemSpacing = GroupClassesCarouselView.cardSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = GroupClassCardCollectionViewCell.cardSize
        layout.minimumLineSpacing = GroupClassesCarouselView.cardSpacing
        layout.minimumInteritemSpacing = GroupClassesCarouselView.cardSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        setupViews()
    }

    // MARK: Setup

    private func setupViews() {
        backgroundColor = GroupClassesCarouselView.sectionFill
        clipsToBounds = true

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = UIImage(named: "group-classes-bg")
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: GroupClassesCarouselView.sectionHorizontalInset,
                                                   bottom: 0,
                                                   right: GroupClassesCarouselView.sectionHorizontalInset)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GroupClassCardCollectionViewCell.self,
                                forCellWithReuseIdentifier: GroupClassCardCollectionViewCell.reuseIdentifier)

        // border-radius: var(--Radius-full, 999px). No cornerRadius is set here —
        // dotsPill is a CapsuleView, which rounds itself in its own layoutSubviews
        // (see that type for why every other placement failed).
        // background: var(--Colors-Surface-Low, #131416) - exact match for
        // GroupClassColor.bg2.
        dotsPill.translatesAutoresizingMaskIntoConstraints = false
        dotsPill.backgroundColor = GroupClassColor.bg2.color
        dotsPill.layer.masksToBounds = true
        dotsView.translatesAutoresizingMaskIntoConstraints = false
        dotsPill.addSubview(dotsView)

        let dotsRow = UIView()
        dotsRow.translatesAutoresizingMaskIntoConstraints = false
        dotsRow.backgroundColor = .clear
        dotsRow.addSubview(dotsPill)

        // "SEE ALL GROUP TRAININGS" -> `SeeAllGroupClassesViewController`, the
        // ported equivalent of Android's `SeeAllGroupClassesActivity`.
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.bandThickness = 2
        seeAllButton.configure(title: "SEE ALL GROUP TRAININGS",
                               font: AppFont.semibold.size(14.0, familyName: familyFunnelSans),
                               titleColor: UIColor(hex: "#141514"))
        // Android's `btnSeeAllGroupTrainings`: `paddingHorizontal="12dp"`, with the
        // label and a 20dp chevron centred together 8dp apart.
        seeAllButton.horizontalContentInset = 12
        seeAllButton.trailingIconSize = 20
        seeAllButton.setTrailingIcon(UIImage(named: "chevron-right") ?? UIImage(systemName: "chevron.right"),
                                     tint: UIColor(hex: "#141514"))
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)

        // Android's `btnSeeAllGroupTrainings` carries `layout_marginHorizontal="20dp"`
        // inside the full-width column — a wrapper reproduces that inset without
        // fighting the `.fill` alignment the rest of `contentStack` relies on.
        let seeAllWrapper = UIView()
        seeAllWrapper.translatesAutoresizingMaskIntoConstraints = false
        seeAllWrapper.addSubview(seeAllButton)
        NSLayoutConstraint.activate([
            seeAllButton.topAnchor.constraint(equalTo: seeAllWrapper.topAnchor),
            seeAllButton.bottomAnchor.constraint(equalTo: seeAllWrapper.bottomAnchor),
            seeAllButton.leadingAnchor.constraint(equalTo: seeAllWrapper.leadingAnchor, constant: 20),
            seeAllButton.trailingAnchor.constraint(equalTo: seeAllWrapper.trailingAnchor, constant: -20)
        ])

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 12
        contentStack.addArrangedSubview(collectionView)
        contentStack.addArrangedSubview(dotsRow)
        contentStack.addArrangedSubview(seeAllWrapper)
        contentStack.setCustomSpacing(16, after: dotsRow)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: GroupClassesCarouselView.sectionHeight),

            // Top-anchored, full width, height derived from the artwork's own
            // aspect ratio (no bottom pin) - matches Android's `wrap_content`
            // height / `fitStart` / `gravity="top"` image scaled to the section's
            // full width. Whatever the fixed 780pt section doesn't cover shows
            // the `#32615C` fill instead of a distorted stretch.
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor,
                                                   multiplier: GroupClassesCarouselView.bannerAspectRatio),

            // Bottom-aligned only (no top pin): the content floats near the
            // fixed section's bottom edge, on top of the banner/fill behind it.
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                 constant: -GroupClassesCarouselView.sectionBottomInset),

            collectionView.heightAnchor.constraint(equalToConstant: GroupClassesCarouselView.carouselHeight),

            dotsPill.topAnchor.constraint(equalTo: dotsRow.topAnchor),
            dotsPill.bottomAnchor.constraint(equalTo: dotsRow.bottomAnchor),
            dotsPill.centerXAnchor.constraint(equalTo: dotsRow.centerXAnchor),

            dotsView.topAnchor.constraint(equalTo: dotsPill.topAnchor, constant: 4),
            dotsView.bottomAnchor.constraint(equalTo: dotsPill.bottomAnchor, constant: -4),
            dotsView.leadingAnchor.constraint(equalTo: dotsPill.leadingAnchor, constant: 12),
            dotsView.trailingAnchor.constraint(equalTo: dotsPill.trailingAnchor, constant: -12),
            dotsView.heightAnchor.constraint(equalToConstant: 5),

            seeAllButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    @objc private func seeAllTapped() {
        onSeeAllTapped?()
    }

    // MARK: Data

    /// Fetches `GET viewall-classes` and renders the carousel.
    ///
    /// Free classes are dropped unless the user is an active member — the same
    /// rule Android applies while parsing the response.
    func loadClasses(lat: Double?, long: Double?) {

        let requestLat = (lat ?? 0) == 0 ? GroupClassCardFormatter.fallbackLatitude : (lat ?? 0)
        let requestLng = (long ?? 0) == 0 ? GroupClassCardFormatter.fallbackLongitude : (long ?? 0)

        let params: [String: String] = [
            "lat": "\(requestLat)",
            "long": "\(requestLng)",
            "is_filter": "0",
            "category_id": ""
        ]

        // No loader: this is a passive home-screen section, not a user-initiated action.
        UpcomingClassVM.viewAllClassesApi(inputParams: params, isShowLoader: false) { [weak self] result in
            guard let self = self else { return }

            let allClasses = result?.data?.allClasses ?? []
            let visibleClasses = allClasses.filter {
                GroupClassCardFormatter.isVisibleOnHome(access: $0.access,
                                                        isMember: $0.isMember ?? false)
            }
            // Home shows only the top 10 closest-date upcoming classes, not the
            // full catalog - see all lives on its own screen.
            let topTenClasses = GroupClassCardFormatter.closestUpcoming(visibleClasses, limit: 10)

            DispatchQueue.main.async {
                self.userLat = requestLat
                self.userLng = requestLng
                self.apply(classes: topTenClasses)
            }
        }
    }

    private func apply(classes: [UpcomingClassModel]) {
        self.classes = classes
        // Android hides the section entirely when nothing survives the filter.
        isHidden = classes.isEmpty

        // The home screen re-runs its whole fetch stack in `viewWillAppear`, so
        // this lands again every time the user navigates *back* here. Rebuilding
        // the carousel then would rewind the user's scroll position and flash
        // every cell; when the payload is identical there is nothing to redraw,
        // so the refresh stays silent.
        let signature = GroupClassesCarouselView.signature(for: classes)
        guard signature != renderedSignature else { return }
        renderedSignature = signature

        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: -collectionView.contentInset.left, y: 0), animated: false)
        dotsView.setPageCount(classes.count)
        dotsView.setSelectedPage(0)
    }

    /// Everything the cards actually render, so an unchanged fetch is detected as
    /// unchanged even though the decoded models are fresh instances.
    private static func signature(for classes: [UpcomingClassModel]) -> String {
        return classes.map { item in
            [
                item.scheduleID.map(String.init) ?? "",
                GroupClassCardFormatter.title(for: item),
                GroupClassCardFormatter.locationText(for: item),
                item.time ?? "",
                item.start_end ?? "",
                item.image ?? "",
                GroupClassCardFormatter.resolvedAccess(item.access),
                (item.isMember ?? false) ? "1" : "0",
                String(GroupClassCardFormatter.intValue(item.bookedCount, defaultValue: 0)),
                String(GroupClassCardFormatter.intValue(item.totalCapacity, defaultValue: 20)),
                String(GroupClassCardFormatter.intValue(item.remainingSeats, defaultValue: 20))
            ].joined(separator: "|")
        }.joined(separator: ";")
    }
}

// MARK: - Storyboard insertion

extension GroupClassesCarouselView {

    /// Inserts a carousel into the storyboard-defined content stack view that owns
    /// `anchorView`, directly *after* the section `anchorView` lives in.
    ///
    /// Both home screens are storyboard scenes built around a single vertical
    /// `UIStackView`, so anchoring off an existing outlet keeps the whole feature
    /// out of the storyboard XML. Returns `nil` (and inserts nothing) if the
    /// expected stack-view structure is not found.
    @discardableResult
    static func insert(after anchorView: UIView?,
                       onSelect: @escaping (GroupClassTapThroughData) -> Void) -> GroupClassesCarouselView? {

        guard let section = stackSection(containing: anchorView),
              let contentStack = section.superview as? UIStackView,
              let anchorIndex = contentStack.arrangedSubviews.firstIndex(of: section) else {
            return nil
        }

        let carousel = GroupClassesCarouselView(frame: .zero)
        carousel.translatesAutoresizingMaskIntoConstraints = false
        // Stays collapsed until the fetch returns at least one visible class.
        carousel.isHidden = true
        carousel.onSelectClass = onSelect

        contentStack.insertArrangedSubview(carousel, at: anchorIndex + 1)
        return carousel
    }

    /// Walks up from `view` to the first ancestor that is itself an arranged
    /// subview of a `UIStackView`.
    private static func stackSection(containing view: UIView?) -> UIView? {
        var current = view
        while let candidate = current {
            if candidate.superview is UIStackView { return candidate }
            current = candidate.superview
        }
        return nil
    }
}

// MARK: - UICollectionView data source / delegate

extension GroupClassesCarouselView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GroupClassCardCollectionViewCell.reuseIdentifier,
            for: indexPath) as? GroupClassCardCollectionViewCell,
              indexPath.item < classes.count else {
            return UICollectionViewCell()
        }
        cell.configure(with: classes[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return GroupClassCardCollectionViewCell.cardSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < classes.count else { return }
        TapticEngine.selection.feedback()
        let data = GroupClassCardFormatter.tapThroughData(for: classes[indexPath.item],
                                                          userLat: userLat,
                                                          userLng: userLng)
        onSelectClass?(data)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView, !classes.isEmpty else { return }
        let pageWidth = GroupClassCardCollectionViewCell.cardSize.width + GroupClassesCarouselView.cardSpacing
        guard pageWidth > 0 else { return }
        // At maximum scroll the last card comes to rest against the trailing
        // content inset, so contentOffset.x never reaches (count - 1) * pageWidth
        // — rawPage rounds down to count - 2 and the second-to-last dot stays lit.
        // Snap the final page explicitly rather than trusting the offset maths at
        // the very end. (setSelectedPage already clamps, which is why clamping
        // alone doesn't fix this: the computed page is legitimately count - 2.)
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        if maxOffsetX > 0, scrollView.contentOffset.x >= maxOffsetX - 0.5 {
            dotsView.setSelectedPage(classes.count - 1)
            return
        }

        let rawPage = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        dotsView.setSelectedPage(Int(rawPage.rounded()))
    }
}

// MARK: - GroupClassNavigator

/// Single owner of the Home → Group Training Detail transition, so both the
/// active-user and guest home screens push the detail screen identically.
enum GroupClassNavigator {

    static func pushDetail(from viewController: UIViewController,
                           data: GroupClassTapThroughData) {
        // Programmatic screen (no storyboard scene), per the module's architecture
        // decision — `instantiate(appStoryboard:)` must not be used here because
        // `instantiateViewController(withIdentifier:)` raises when the identifier
        // is missing from the storyboard rather than returning nil.
        let detailVC = GroupTrainingDetailViewController()
        detailVC.tapThrough = data
        detailVC.hidesBottomBarWhenPushed = true
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}
