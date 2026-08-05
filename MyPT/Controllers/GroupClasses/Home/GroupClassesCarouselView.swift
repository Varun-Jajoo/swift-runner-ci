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
        applySelection()
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
            // Selected pill keeps the same 2.5pt radius as the dots on Android
            // (8dp requested, but clamped by the 5dp height).
            dot.layer.cornerRadius = GroupClassCarouselDotsView.dotSize / 2
        }
    }
}

// MARK: - GroupClassesCarouselView

final class GroupClassesCarouselView: UIView {

    // Card 180×240 with a 10pt gutter, inside a 250pt-tall strip — Android's
    // `item_group_class_card.xml` dimensions and the 250dp RecyclerView.
    private static let cardSpacing: CGFloat = 10
    private static let carouselHeight: CGFloat = 250
    private static let sectionHorizontalInset: CGFloat = 16

    /// Fired when a card is tapped, with the fully-derived tap-through payload.
    var onSelectClass: ((GroupClassTapThroughData) -> Void)?

    private(set) var classes: [UpcomingClassModel] = []

    /// Device location used for the fetch and for per-card distance maths.
    private var userLat: Double = GroupClassCardFormatter.fallbackLatitude
    private var userLng: Double = GroupClassCardFormatter.fallbackLongitude

    private let contentStack = UIStackView()
    private let collectionView: UICollectionView
    private let dotsView = GroupClassCarouselDotsView()
    private let dotsPill = UIView()
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
        backgroundColor = .clear

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

        // Dots sit inside a dark pill container (#131416 with pill radius)
        dotsPill.translatesAutoresizingMaskIntoConstraints = false
        dotsPill.backgroundColor = UIColor(hex: "#131416")
        dotsPill.layer.masksToBounds = true
        dotsView.translatesAutoresizingMaskIntoConstraints = false
        dotsPill.addSubview(dotsView)

        let dotsRow = UIView()
        dotsRow.translatesAutoresizingMaskIntoConstraints = false
        dotsRow.backgroundColor = .clear
        dotsRow.addSubview(dotsPill)

        // "SEE ALL GROUP TRAININGS" — Android's own destination for this button is
        // still a placeholder (it opens BookingPausedActivity with dummy extras),
        // so it stays hidden here until a real destination is confirmed.
        // TODO: unhide + wire once the destination is specified.
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.configure(title: "SEE ALL GROUP TRAININGS",
                               font: AppFont.semibold.size(14.0, familyName: familyFunnelSans),
                               titleColor: UIColor(hex: "#141514"))
        seeAllButton.isHidden = true
        seeAllButton.isUserInteractionEnabled = false

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 12
        contentStack.addArrangedSubview(collectionView)
        contentStack.addArrangedSubview(dotsRow)
        contentStack.addArrangedSubview(seeAllButton)
        contentStack.setCustomSpacing(16, after: dotsRow)
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            collectionView.heightAnchor.constraint(equalToConstant: GroupClassesCarouselView.carouselHeight),

            dotsPill.topAnchor.constraint(equalTo: dotsRow.topAnchor),
            dotsPill.bottomAnchor.constraint(equalTo: dotsRow.bottomAnchor),
            dotsPill.centerXAnchor.constraint(equalTo: dotsRow.centerXAnchor),

            dotsView.topAnchor.constraint(equalTo: dotsPill.topAnchor, constant: 4),
            dotsView.bottomAnchor.constraint(equalTo: dotsPill.bottomAnchor, constant: -4),
            dotsView.leadingAnchor.constraint(equalTo: dotsPill.leadingAnchor, constant: 12),
            dotsView.trailingAnchor.constraint(equalTo: dotsPill.trailingAnchor, constant: -12),
            dotsView.heightAnchor.constraint(equalToConstant: 10),

            seeAllButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dotsPill.layer.cornerRadius = dotsPill.bounds.height / 2
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

            DispatchQueue.main.async {
                self.userLat = requestLat
                self.userLng = requestLng
                self.apply(classes: visibleClasses)
            }
        }
    }

    private func apply(classes: [UpcomingClassModel]) {
        self.classes = classes
        // Android hides the section entirely when nothing survives the filter.
        isHidden = classes.isEmpty
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: -collectionView.contentInset.left, y: 0), animated: false)
        dotsView.setPageCount(classes.count)
        dotsView.setSelectedPage(0)
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
