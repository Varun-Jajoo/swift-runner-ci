//
//  SeeAllGroupClassesViewController.swift
//  MyPT
//
//  "See All Group Classes" — hero header, a "Trending On MyPT" horizontal
//  carousel (ranked by fill percentage), a five-way filter tab bar, and a
//  responsive "Upcoming Classes" grid.
//
//  Android reference (ground truth for every rule in here):
//    app/src/main/java/co/com/mypt/UpComingClasses/SeeAllGroupClassesActivity.kt
//    app/src/main/java/co/com/mypt/adapter/SeeAllGridAdapter.kt
//    app/src/main/java/co/com/mypt/adapter/TrendingGroupClassesAdapter.kt
//    app/src/main/res/layout/activity_see_all_group_classes.xml
//

import UIKit

final class SeeAllGroupClassesViewController: CommonViewController {

    // MARK: - Input

    /// Device location the caller already resolved (Home carousel's own fetch).
    /// Falls back to Dubai, matching Android's `SeeAllGroupClassesActivity`.
    var initialLat: Double = GroupClassCardFormatter.fallbackLatitude
    var initialLng: Double = GroupClassCardFormatter.fallbackLongitude

    // MARK: - State

    private enum FilterTab: CaseIterable {
        case all, mixed, ladies, week, month

        var title: String {
            switch self {
            case .all:    return "ALL CLASSES"
            case .mixed:  return "MIXED GYM"
            case .ladies: return "LADIES GYM"
            case .week:   return "THIS WEEK"
            case .month:  return "THIS MONTH"
            }
        }
    }

    private var lat: Double = GroupClassCardFormatter.fallbackLatitude
    private var lng: Double = GroupClassCardFormatter.fallbackLongitude
    /// Unfiltered API result — the grid's "ALL CLASSES" tab and filter source.
    private var masterClassList: [UpcomingClassModel] = []
    /// Currently displayed grid rows (post-tab-filter).
    private var filteredGridList: [UpcomingClassModel] = []
    /// Top 5 by fill percentage — independent of the active grid filter tab,
    /// exactly like Android (the trending carousel never re-filters).
    private var trendingList: [UpcomingClassModel] = []
    private var activeTab: FilterTab = .all
    private var lastLayoutWidth: CGFloat = 0

    // MARK: - Views

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let heroImageView = UIImageView()
    private let backButton = GlassCircularIconButton()
    private var heroBackTopConstraint: NSLayoutConstraint?

    private let trendingTitleLabel = UILabel()
    private let trendingCollectionView: UICollectionView
    private let dotsView = GroupClassCarouselDotsView()

    private let upcomingTitleLabel = UILabel()
    private let filterSettingsIcon = UIImageView()
    private var filterButtons: [(tab: FilterTab, button: UIButton)] = []

    private let gridCollectionView: UICollectionView
    private var gridHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let trendingLayout = UICollectionViewFlowLayout()
        trendingLayout.scrollDirection = .horizontal
        trendingLayout.minimumLineSpacing = 0
        trendingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: trendingLayout)

        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.scrollDirection = .vertical
        gridLayout.minimumLineSpacing = 12
        gridLayout.minimumInteritemSpacing = 12
        gridLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let trendingLayout = UICollectionViewFlowLayout()
        trendingLayout.scrollDirection = .horizontal
        trendingLayout.minimumLineSpacing = 0
        trendingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: trendingLayout)

        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.scrollDirection = .vertical
        gridLayout.minimumLineSpacing = 12
        gridLayout.minimumInteritemSpacing = 12
        gridLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)

        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GroupClassColor.bg.color

        lat = initialLat == 0 ? GroupClassCardFormatter.fallbackLatitude : initialLat
        lng = initialLng == 0 ? GroupClassCardFormatter.fallbackLongitude : initialLng

        buildLayout()
        loadClasses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        heroBackTopConstraint?.constant = view.safeAreaInsets.top + 12
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard view.bounds.width != lastLayoutWidth, view.bounds.width > 0 else { return }
        lastLayoutWidth = view.bounds.width
        gridCollectionView.collectionViewLayout.invalidateLayout()
        trendingCollectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async { [weak self] in
            self?.updateGridHeight()
        }
    }

    // MARK: - Layout

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(makeHeroSection())
        contentStack.addArrangedSubview(makeTitleRow(trendingTitleLabel, text: "Trending On MyPT", topInset: 26))
        contentStack.addArrangedSubview(makeTrendingRow())
        contentStack.addArrangedSubview(makeDotsRow())
        contentStack.addArrangedSubview(makeTitleRow(upcomingTitleLabel, text: "Upcoming Classes", topInset: 32))
        contentStack.addArrangedSubview(makeFilterRow())
        contentStack.addArrangedSubview(makeGridRow())

        let bottomSpacer = UIView()
        bottomSpacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStack.addArrangedSubview(bottomSpacer)
    }

    /// 314pt full-bleed hero image (`hero_see_all_group_classes.png`, which
    /// bakes the screen title into the artwork itself) plus a floating glass
    /// back button.
    private func makeHeroSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 314).isActive = true

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.image = UIImage(named: "hero-see-all-group-classes")
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        container.addSubview(heroImageView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: SeeAllGroupClassesViewController.icon(["ic_back_chevron_20"], systemFallback: "chevron.left"),
                             tintColor: .white)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        container.addSubview(backButton)

        let topConstraint = backButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 52)
        heroBackTopConstraint = topConstraint

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: container.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            topConstraint,
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        return container
    }

    private func makeTitleRow(_ label: UILabel, text: String, topInset: CGFloat) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        label.textColor = UIColor(hex: "#BFFAFAFA")
        wrapper.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: topInset),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    private func makeTrendingRow() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        trendingCollectionView.translatesAutoresizingMaskIntoConstraints = false
        trendingCollectionView.backgroundColor = .clear
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 4)
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        trendingCollectionView.register(TrendingGroupClassCollectionViewCell.self,
                                        forCellWithReuseIdentifier: TrendingGroupClassCollectionViewCell.reuseIdentifier)
        wrapper.addSubview(trendingCollectionView)

        NSLayoutConstraint.activate([
            trendingCollectionView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            trendingCollectionView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            trendingCollectionView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            trendingCollectionView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            trendingCollectionView.heightAnchor.constraint(equalToConstant: TrendingGroupClassCollectionViewCell.totalCellHeight)
        ])
        return wrapper
    }

    private func makeDotsRow() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        dotsView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(dotsView)

        NSLayoutConstraint.activate([
            dotsView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            dotsView.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            dotsView.heightAnchor.constraint(equalToConstant: 5),
            dotsView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    /// Filter-settings icon (decorative, no handler — Android's own
    /// `btnFilterSettings` carries no click listener either) + divider +
    /// the five horizontally-scrolling tab pills.
    private func makeFilterRow() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        let filterButtonBg = UIView()
        filterButtonBg.translatesAutoresizingMaskIntoConstraints = false
        filterButtonBg.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        filterButtonBg.layer.cornerRadius = 8
        filterButtonBg.layer.borderWidth = 1
        filterButtonBg.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        filterSettingsIcon.translatesAutoresizingMaskIntoConstraints = false
        filterSettingsIcon.image = SeeAllGroupClassesViewController.icon(["ic_filter_settings"], systemFallback: "slider.horizontal.3")?
            .withRenderingMode(.alwaysTemplate)
        filterSettingsIcon.tintColor = UIColor(hex: "#F0F0F0")
        filterSettingsIcon.contentMode = .scaleAspectFit
        filterButtonBg.addSubview(filterSettingsIcon)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(hex: "#FAFAFA").withAlphaComponent(0.1)

        let tabsScrollView = UIScrollView()
        tabsScrollView.translatesAutoresizingMaskIntoConstraints = false
        tabsScrollView.showsHorizontalScrollIndicator = false

        let tabsStack = UIStackView()
        tabsStack.translatesAutoresizingMaskIntoConstraints = false
        tabsStack.axis = .horizontal
        tabsStack.spacing = 8
        tabsStack.alignment = .center
        tabsScrollView.addSubview(tabsStack)

        filterButtons = FilterTab.allCases.enumerated().map { index, tab in
            let button = UIButton(type: .system)
            button.tag = index
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(tab.title, for: .normal)
            button.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            button.layer.cornerRadius = 16
            button.layer.masksToBounds = true
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            button.addTarget(self, action: #selector(filterTabTapped(_:)), for: .touchUpInside)
            tabsStack.addArrangedSubview(button)
            return (tab, button)
        }

        wrapper.addSubview(filterButtonBg)
        wrapper.addSubview(divider)
        wrapper.addSubview(tabsScrollView)

        NSLayoutConstraint.activate([
            filterButtonBg.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            filterButtonBg.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            filterButtonBg.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            filterButtonBg.heightAnchor.constraint(equalToConstant: 32),
            filterButtonBg.widthAnchor.constraint(equalToConstant: 34),

            filterSettingsIcon.centerXAnchor.constraint(equalTo: filterButtonBg.centerXAnchor),
            filterSettingsIcon.centerYAnchor.constraint(equalTo: filterButtonBg.centerYAnchor),
            filterSettingsIcon.widthAnchor.constraint(equalToConstant: 18),
            filterSettingsIcon.heightAnchor.constraint(equalToConstant: 18),

            divider.leadingAnchor.constraint(equalTo: filterButtonBg.trailingAnchor, constant: 8),
            divider.centerYAnchor.constraint(equalTo: filterButtonBg.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 19),

            tabsScrollView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 10),
            tabsScrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            tabsScrollView.centerYAnchor.constraint(equalTo: filterButtonBg.centerYAnchor),
            tabsScrollView.heightAnchor.constraint(equalToConstant: 32),

            tabsStack.topAnchor.constraint(equalTo: tabsScrollView.topAnchor),
            tabsStack.bottomAnchor.constraint(equalTo: tabsScrollView.bottomAnchor),
            tabsStack.leadingAnchor.constraint(equalTo: tabsScrollView.leadingAnchor),
            tabsStack.trailingAnchor.constraint(equalTo: tabsScrollView.trailingAnchor),
            tabsStack.heightAnchor.constraint(equalTo: tabsScrollView.heightAnchor)
        ])

        applyTabStyles()
        return wrapper
    }

    private func makeGridRow() -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        gridCollectionView.backgroundColor = .clear
        gridCollectionView.isScrollEnabled = false
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        gridCollectionView.register(SeeAllGridCollectionViewCell.self,
                                    forCellWithReuseIdentifier: SeeAllGridCollectionViewCell.reuseIdentifier)
        wrapper.addSubview(gridCollectionView)

        let heightConstraint = gridCollectionView.heightAnchor.constraint(equalToConstant: 0)
        gridHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            gridCollectionView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            gridCollectionView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            gridCollectionView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            gridCollectionView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            heightConstraint
        ])
        return wrapper
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func filterTabTapped(_ sender: UIButton) {
        guard FilterTab.allCases.indices.contains(sender.tag) else { return }
        selectTab(FilterTab.allCases[sender.tag])
    }

    private func selectTab(_ tab: FilterTab) {
        guard activeTab != tab else { return }
        activeTab = tab
        applyTabStyles()
        filterGridClasses()
    }

    private func applyTabStyles() {
        for (tab, button) in filterButtons {
            let isSelected = tab == activeTab
            button.backgroundColor = UIColor.white.withAlphaComponent(isSelected ? 0.2 : 0.1)
            button.layer.borderWidth = isSelected ? 1 : 0
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            button.setTitleColor(isSelected ? UIColor(hex: "#F0F0F0") : UIColor(hex: "#8CFAFAFA"), for: .normal)
            let horizontalPadding: CGFloat = isSelected ? 12 : 8
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: horizontalPadding, bottom: 4, right: horizontalPadding)
        }
    }

    // MARK: - Data

    private func loadClasses() {
        let requestLat = lat == 0 ? GroupClassCardFormatter.fallbackLatitude : lat
        let requestLng = lng == 0 ? GroupClassCardFormatter.fallbackLongitude : lng
        let params: [String: String] = [
            "lat": "\(requestLat)",
            "long": "\(requestLng)",
            "is_filter": "0",
            "category_id": ""
        ]

        UpcomingClassVM.viewAllClassesApi(inputParams: params, isShowLoader: true) { [weak self] result in
            guard let self = self else { return }
            let allClasses = result?.data?.allClasses ?? []

            DispatchQueue.main.async {
                self.masterClassList = allClasses
                self.filteredGridList = allClasses
                self.gridCollectionView.reloadData()
                self.updateGridHeight()

                // TRENDING RULE: highest booked/capacity ratio first, ties broken
                // by raw booked count — ported verbatim from
                // `SeeAllGroupClassesActivity.fetchGroupClassesFromApi`.
                let sortedByFullness = allClasses.sorted { lhs, rhs in
                    let lhsRatio = self.fullnessRatio(lhs)
                    let rhsRatio = self.fullnessRatio(rhs)
                    if lhsRatio != rhsRatio { return lhsRatio > rhsRatio }
                    return GroupClassCardFormatter.intValue(lhs.bookedCount, defaultValue: 0)
                         > GroupClassCardFormatter.intValue(rhs.bookedCount, defaultValue: 0)
                }
                self.trendingList = Array(sortedByFullness.prefix(5))
                self.trendingCollectionView.reloadData()
                self.dotsView.setPageCount(self.trendingList.count)
                self.dotsView.setSelectedPage(0)
            }
        }
    }

    private func fullnessRatio(_ item: UpcomingClassModel) -> Double {
        let capacity = GroupClassCardFormatter.intValue(item.totalCapacity, defaultValue: 20)
        let effectiveCapacity = capacity > 0 ? capacity : 20
        let booked = GroupClassCardFormatter.intValue(item.bookedCount, defaultValue: 0)
        return Double(booked) / Double(effectiveCapacity)
    }

    /// Port of `filterGridClasses()`. Note LADIES has no empty-result fallback
    /// while MIXED does — that asymmetry is in the Android source, not a typo.
    private func filterGridClasses() {
        guard !masterClassList.isEmpty else { return }

        let filtered: [UpcomingClassModel]
        switch activeTab {
        case .all:
            filtered = masterClassList
        case .mixed:
            let matched = masterClassList.filter(containsMixedSignal)
            filtered = matched.isEmpty ? masterClassList : matched
        case .ladies:
            filtered = masterClassList.filter(containsLadiesSignal)
        case .week:
            filtered = Array(masterClassList.prefix(6))
        case .month:
            filtered = Array(masterClassList.prefix(12))
        }

        filteredGridList = filtered
        // `reloadData()` tears down and rebuilds every visible cell, which reads
        // as a flash when only the *set* of rows changed. Reloading the single
        // section instead keeps cell reuse (and therefore the already-decoded
        // cover images) intact, and `.none` suppresses the cross-dissolve.
        UIView.performWithoutAnimation {
            gridCollectionView.reloadSections(IndexSet(integer: 0))
        }
        updateGridHeight()
    }

    private func containsMixedSignal(_ item: UpcomingClassModel) -> Bool {
        (item.studioName ?? "").localizedCaseInsensitiveContains("mixed") ||
        (item.location ?? "").localizedCaseInsensitiveContains("mixed") ||
        (item.className ?? "").localizedCaseInsensitiveContains("mixed") ||
        (item.access ?? "").localizedCaseInsensitiveContains("mixed")
    }

    private func containsLadiesSignal(_ item: UpcomingClassModel) -> Bool {
        (item.studioName ?? "").localizedCaseInsensitiveContains("ladies") ||
        (item.location ?? "").localizedCaseInsensitiveContains("ladies") ||
        (item.className ?? "").localizedCaseInsensitiveContains("ladies")
    }

    private func openDetail(for item: UpcomingClassModel) {
        let data = GroupClassCardFormatter.tapThroughData(for: item, userLat: lat, userLng: lng)
        GroupClassNavigator.pushDetail(from: self, data: data)
    }

    // MARK: - Responsive grid

    /// Port of `getResponsiveSpanCount()` — same dp/pt thresholds.
    private func numberOfColumns() -> Int {
        let width = view.bounds.width
        if width < 340 { return 1 }
        if width < 600 { return 2 }
        if width < 900 { return 3 }
        return 4
    }

    private func updateGridHeight() {
        gridCollectionView.layoutIfNeeded()
        let height = gridCollectionView.collectionViewLayout.collectionViewContentSize.height
        gridHeightConstraint?.constant = height
    }
}

// MARK: - UICollectionView data source / delegate

extension SeeAllGroupClassesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === trendingCollectionView { return trendingList.count }
        return filteredGridList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === trendingCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrendingGroupClassCollectionViewCell.reuseIdentifier,
                for: indexPath) as? TrendingGroupClassCollectionViewCell,
                  indexPath.item < trendingList.count else {
                return UICollectionViewCell()
            }
            cell.configure(with: trendingList[indexPath.item], rankIndex: indexPath.item)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SeeAllGridCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SeeAllGridCollectionViewCell,
              indexPath.item < filteredGridList.count else {
            return UICollectionViewCell()
        }
        cell.configure(with: filteredGridList[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === trendingCollectionView {
            return CGSize(width: TrendingGroupClassCollectionViewCell.totalWidth(forRankIndex: indexPath.item),
                          height: TrendingGroupClassCollectionViewCell.totalCellHeight)
        }

        let columns = numberOfColumns()
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let sectionInset = flowLayout?.sectionInset ?? .zero
        let spacing = flowLayout?.minimumInteritemSpacing ?? 12
        let available = collectionView.bounds.width - sectionInset.left - sectionInset.right
                       - spacing * CGFloat(columns - 1)
        let width = max(available / CGFloat(columns), 0)
        return CGSize(width: width, height: SeeAllGridCollectionViewCell.cardHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        if collectionView === trendingCollectionView {
            guard indexPath.item < trendingList.count else { return }
            openDetail(for: trendingList[indexPath.item])
        } else {
            guard indexPath.item < filteredGridList.count else { return }
            openDetail(for: filteredGridList[indexPath.item])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === trendingCollectionView, !trendingList.isEmpty else { return }
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        var closestIndex = 0
        var closestDistance = CGFloat.greatestFiniteMagnitude
        for index in 0..<trendingList.count {
            guard let attributes = trendingCollectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else { continue }
            let distance = abs(attributes.center.x - centerX)
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        dotsView.setSelectedPage(closestIndex)
    }
}

// MARK: - Icon resolution

private extension SeeAllGroupClassesViewController {

    /// First bundled asset wins; a system symbol is the last resort — same
    /// convention as `GroupTrainingDetailViewController.icon(_:systemFallback:)`.
    static func icon(_ names: [String], systemFallback: String? = nil) -> UIImage? {
        for name in names {
            if let image = UIImage(named: name) { return image }
        }
        if let systemFallback = systemFallback {
            return UIImage(systemName: systemFallback)
        }
        return nil
    }
}
