//
//  SeeAllSgptViewController.swift
//  MyPT
//

import UIKit

final class SeeAllSgptViewController: CommonViewController {

    enum FilterTab: Int, CaseIterable {
        case all
        case thisWeek
        case thisMonth

        var title: String {
            switch self {
            case .all: return "ALL CLASSES"
            case .thisWeek: return "THIS WEEK"
            case .thisMonth: return "THIS MONTH"
            }
        }
    }

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentStack: UIStackView!
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var trendingTitleLabel: UILabel!
    @IBOutlet private weak var trendingCollectionView: UICollectionView!
    @IBOutlet private weak var pagerView: SgptCarouselPagerView!
    @IBOutlet private weak var upcomingTitleLabel: UILabel!
    @IBOutlet private weak var filterChipView: UIView!
    @IBOutlet private weak var tabsStack: UIStackView!
    @IBOutlet private weak var trainerCollectionView: UICollectionView!
    @IBOutlet private weak var trainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var gridCollectionView: UICollectionView!
    @IBOutlet private weak var gridHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var quoteLabel: UILabel!
    @IBOutlet private weak var quoteAuthorLabel: UILabel!
    /// Back button's top offset inside the hero. The storyboard ships a static
    /// 52pt guess; this screen is the one SGPT/Group Classes screen that never
    /// adjusted it for the safe area, so the button sat at a different height
    /// from every other screen in both modules (and from itself across devices).
    @IBOutlet private weak var backTopConstraint: NSLayoutConstraint!

    var initialLat: Double = GroupClassCardFormatter.fallbackLatitude
    var initialLng: Double = GroupClassCardFormatter.fallbackLongitude

    private var lat: Double = GroupClassCardFormatter.fallbackLatitude
    private var lng: Double = GroupClassCardFormatter.fallbackLongitude

    private var masterList: [SgptSessionModel] = []
    private var filteredList: [SgptSessionModel] = []
    private var trendingList: [SgptSessionModel] = []
    private var trainers: [SgptTrainerItem] = []
    private var studioLabels: [String] = []
    private var activeTabIndex = 0
    private var tabButtons: [UIButton] = []
    private var lastLayoutWidth: CGFloat = 0
    fileprivate var spotlightIndexPath: IndexPath?

    private let backgroundGradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = SgptListingColor.backgroundTop
        backgroundGradient.colors = [
            SgptListingColor.backgroundTop.cgColor,
            SgptListingColor.backgroundBottom.cgColor
        ]
        backgroundGradient.locations = [0.174, 0.482]
        view.layer.insertSublayer(backgroundGradient, at: 0)

        lat = initialLat == 0 ? GroupClassCardFormatter.fallbackLatitude : initialLat
        lng = initialLng == 0 ? GroupClassCardFormatter.fallbackLongitude : initialLng

        applyFonts()
        configureCollectionViews()
        rebuildTabs()
        loadSessions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        // Set before the width guard below - that guard returns early on every
        // pass except a width change, which would leave the back button at the
        // storyboard's static constant on a normal layout pass.
        backTopConstraint?.constant = view.safeAreaInsets.top + 12
        guard view.bounds.width != lastLayoutWidth, view.bounds.width > 0 else { return }
        lastLayoutWidth = view.bounds.width
        updateGridHeight()
    }

    private func applyFonts() {
        trendingTitleLabel.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        upcomingTitleLabel.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        quoteLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        quoteAuthorLabel.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        filterChipView.layer.cornerRadius = 8
        filterChipView.layer.borderWidth = 1
        filterChipView.layer.borderColor = SgptListingColor.stroke10.cgColor
    }

    private func configureCollectionViews() {
        scrollView.contentInsetAdjustmentBehavior = .never

        trendingCollectionView.backgroundColor = .clear
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.decelerationRate = .fast
        trendingCollectionView.clipsToBounds = false
        trendingCollectionView.setCollectionViewLayout(SgptSpotlightFlowLayout(), animated: false)
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        trendingCollectionView.register(UINib(nibName: "SgptCardCollectionViewCell", bundle: nil),
                                        forCellWithReuseIdentifier: SgptCardCollectionViewCell.reuseIdentifier)

        trainerCollectionView.backgroundColor = .clear
        trainerCollectionView.showsHorizontalScrollIndicator = false
        trainerCollectionView.delegate = self
        trainerCollectionView.dataSource = self
        trainerCollectionView.register(SgptTrainerCollectionViewCell.self,
                                       forCellWithReuseIdentifier: SgptTrainerCollectionViewCell.reuseIdentifier)

        gridCollectionView.backgroundColor = .clear
        gridCollectionView.isScrollEnabled = false
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        gridCollectionView.register(SgptGridCardCollectionViewCell.self,
                                    forCellWithReuseIdentifier: SgptGridCardCollectionViewCell.reuseIdentifier)

        trainerHeightConstraint.constant = 0
    }

    private func rebuildTabs() {
        tabsStack.arrangedSubviews.forEach {
            tabsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        tabButtons.removeAll()

        let titles = FilterTab.allCases.map { $0.title } + studioLabels
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            button.setTitleColor(SgptListingColor.neutral200, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            tabsStack.addArrangedSubview(button)
            tabButtons.append(button)
        }
        applyTabStyles()
    }

    private func applyTabStyles() {
        for (index, button) in tabButtons.enumerated() {
            let isActive = index == activeTabIndex
            button.backgroundColor = isActive
                ? SgptListingColor.limeGreen.withAlphaComponent(0.05)
                : .clear
            button.layer.borderWidth = isActive ? 1 : 0
            button.layer.borderColor = isActive
                ? SgptListingColor.limeGreen.withAlphaComponent(0.4).cgColor
                : UIColor.clear.cgColor
        }
    }

    @IBAction private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func tabTapped(_ sender: UIButton) {
        guard sender.tag != activeTabIndex else { return }
        activeTabIndex = sender.tag
        applyTabStyles()
        applyFilter()
    }

    private func loadSessions(showLoader: Bool = true) {
        let requestLat = lat == 0 ? GroupClassCardFormatter.fallbackLatitude : lat
        let requestLng = lng == 0 ? GroupClassCardFormatter.fallbackLongitude : lng
        let params: [String: String] = [
            "lat": "\(requestLat)",
            "long": "\(requestLng)"
        ]

        SgptVM.sgptUpcomingApi(inputParams: params, isShowLoader: showLoader) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.masterList = result ?? []
                self.trendingList = Array(self.masterList.prefix(5))
                self.buildTrainers()
                self.rebuildStudioTabs()
                self.applyFilter()
                self.trendingCollectionView.reloadData()
                self.trainerCollectionView.reloadData()
                self.trendingCollectionView.layoutIfNeeded()
                self.updateTrendingSpotlight(centeredIndex: 0)
            }
        }
    }

    private func buildTrainers() {
        var seen = Set<String>()
        var items: [SgptTrainerItem] = []
        for session in masterList {
            guard let name = session.trainerName, !name.isEmpty, !seen.contains(name) else { continue }
            seen.insert(name)
            items.append(SgptTrainerItem(name: name, imageURL: session.image, tier: .none))
        }
        trainers = items
        trainerHeightConstraint.constant = items.isEmpty ? 0 : SgptTrainerCollectionViewCell.cardSize.height
    }

    private func rebuildStudioTabs() {
        var seen = Set<String>()
        var labels: [String] = []
        for session in masterList {
            guard let studio = session.studioName, !studio.isEmpty, !seen.contains(studio) else { continue }
            seen.insert(studio)
            labels.append(studio.uppercased())
        }
        studioLabels = labels
        if activeTabIndex >= FilterTab.allCases.count + studioLabels.count {
            activeTabIndex = 0
        }
        rebuildTabs()
    }

    private func applyFilter() {
        let calendar = Calendar.current
        let now = Date()

        if activeTabIndex >= FilterTab.allCases.count {
            let studioIndex = activeTabIndex - FilterTab.allCases.count
            let label = studioIndex < studioLabels.count ? studioLabels[studioIndex] : ""
            filteredList = masterList.filter { ($0.studioName ?? "").uppercased() == label }
        } else if let tab = FilterTab(rawValue: activeTabIndex) {
            switch tab {
            case .all:
                filteredList = masterList
            case .thisWeek:
                filteredList = masterList.filter {
                    guard let date = Self.parseDate($0.date) else { return false }
                    return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
                }
            case .thisMonth:
                filteredList = masterList.filter {
                    guard let date = Self.parseDate($0.date) else { return false }
                    return calendar.isDate(date, equalTo: now, toGranularity: .month)
                }
            }
        } else {
            filteredList = masterList
        }

        gridCollectionView.reloadData()
        updateGridHeight()
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw = raw, !raw.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", "dd-MM-yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) { return date }
        }
        return nil
    }

    private func updateGridHeight() {
        gridCollectionView.collectionViewLayout.invalidateLayout()
        gridCollectionView.layoutIfNeeded()
        let contentHeight = gridCollectionView.collectionViewLayout.collectionViewContentSize.height
        guard gridHeightConstraint.constant != contentHeight else { return }
        gridHeightConstraint.constant = contentHeight
    }

    private func numberOfColumns() -> Int {
        let width = view.bounds.width
        if width < 340 { return 1 }
        if width < 600 { return 2 }
        if width < 900 { return 3 }
        return 4
    }
}

extension SeeAllSgptViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === trendingCollectionView { return trendingList.count }
        if collectionView === trainerCollectionView { return trainers.count }
        return filteredList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === trendingCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SgptCardCollectionViewCell.reuseIdentifier,
                for: indexPath) as? SgptCardCollectionViewCell,
                  indexPath.item < trendingList.count else {
                return UICollectionViewCell()
            }
            cell.configure(with: trendingList[indexPath.item])
            return cell
        }

        if collectionView === trainerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SgptTrainerCollectionViewCell.reuseIdentifier,
                for: indexPath) as? SgptTrainerCollectionViewCell,
                  indexPath.item < trainers.count else {
                return UICollectionViewCell()
            }
            cell.configure(with: trainers[indexPath.item])
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SgptGridCardCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SgptGridCardCollectionViewCell,
              indexPath.item < filteredList.count else {
            return UICollectionViewCell()
        }
        cell.configure(with: filteredList[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === trendingCollectionView {
            return SgptCardCollectionViewCell.cardSize
        }
        if collectionView === trainerCollectionView {
            return SgptTrainerCollectionViewCell.cardSize
        }

        let columns = numberOfColumns()
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let sectionInset = flowLayout?.sectionInset ?? .zero
        let spacing = flowLayout?.minimumInteritemSpacing ?? 13
        let available = collectionView.bounds.width - sectionInset.left - sectionInset.right
                       - spacing * CGFloat(columns - 1)
        let width = max(available / CGFloat(columns), 0)
        let scale = width / SgptGridCardCollectionViewCell.cardSize.width
        return CGSize(width: width, height: SgptGridCardCollectionViewCell.cardSize.height * scale)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let source: [SgptSessionModel]
        if collectionView === trendingCollectionView {
            source = trendingList
        } else if collectionView === trainerCollectionView {
            return
        } else {
            source = filteredList
        }
        guard source.indices.contains(indexPath.item) else { return }

        let vc: SgptSessionDetailViewController = .instantiate(appStoryboard: .sgpt)
        vc.session = source[indexPath.item]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func centeredTrendingIndexPath() -> IndexPath? {
        let center = CGPoint(x: trendingCollectionView.contentOffset.x + trendingCollectionView.bounds.width / 2,
                             y: trendingCollectionView.bounds.height / 2)
        return trendingCollectionView.indexPathForItem(at: center)
    }

    func updateTrendingSpotlight(centeredIndex: Int) {
        guard trendingList.indices.contains(centeredIndex) else { return }
        pagerView.update(page: centeredIndex, pageCount: trendingList.count)

        let newIndexPath = IndexPath(item: centeredIndex, section: 0)
        if let previous = spotlightIndexPath, previous != newIndexPath {
            (trendingCollectionView.cellForItem(at: previous) as? SgptCardCollectionViewCell)?.setGlowing(false)
        }
        spotlightIndexPath = newIndexPath
        (trendingCollectionView.cellForItem(at: newIndexPath) as? SgptCardCollectionViewCell)?.setGlowing(true)
    }

    private func settleTrendingSpotlight(_ scrollView: UIScrollView) {
        guard scrollView === trendingCollectionView, !trendingList.isEmpty,
              let centered = centeredTrendingIndexPath() else { return }
        updateTrendingSpotlight(centeredIndex: centered.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === trendingCollectionView, !trendingList.isEmpty,
              let centered = centeredTrendingIndexPath() else { return }
        pagerView.update(page: centered.item, pageCount: trendingList.count)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settleTrendingSpotlight(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { settleTrendingSpotlight(scrollView) }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        settleTrendingSpotlight(scrollView)
    }
}
