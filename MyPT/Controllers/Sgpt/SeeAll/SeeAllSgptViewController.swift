//
//  SeeAllSgptViewController.swift
//  MyPT
//
//  Minimal "See All Small Group PT" screen: a back header + a single
//  responsive grid of upcoming SGPT sessions, bound to `GET api/sgpt-upcoming`.
//
//  Stripped-down clone of SeeAllGroupClassesViewController.swift - no
//  trending carousel, no filter tabs, no category filtering. The Group
//  Classes screen's equivalents of those exist because that module already
//  has categories/studios/trending data to filter by; SGPT has none of that
//  yet, so this intentionally stays a plain list/grid.
//

import UIKit

final class SeeAllSgptViewController: CommonViewController {

    // MARK: - Input

    /// Device location the caller already resolved (Home carousel's own fetch).
    /// Falls back to Dubai, matching the Group Classes screen's same fallback.
    var initialLat: Double = GroupClassCardFormatter.fallbackLatitude
    var initialLng: Double = GroupClassCardFormatter.fallbackLongitude

    // MARK: - State

    private var lat: Double = GroupClassCardFormatter.fallbackLatitude
    private var lng: Double = GroupClassCardFormatter.fallbackLongitude
    private var sessions: [SgptSessionModel] = []
    private var lastLayoutWidth: CGFloat = 0

    // MARK: - Views

    private let titleLabel = UILabel()
    private let backButton = GlassCircularIconButton()
    private let gridCollectionView: UICollectionView

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.scrollDirection = .vertical
        gridLayout.minimumLineSpacing = 12
        gridLayout.minimumInteritemSpacing = 12
        gridLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.scrollDirection = .vertical
        gridLayout.minimumLineSpacing = 12
        gridLayout.minimumInteritemSpacing = 12
        gridLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
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
        loadSessions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard view.bounds.width != lastLayoutWidth, view.bounds.width > 0 else { return }
        lastLayoutWidth = view.bounds.width
        gridCollectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.configure(icon: UIImage(systemName: "chevron.left"), tintColor: .white)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Small Group PT"
        titleLabel.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        titleLabel.textColor = .white
        view.addSubview(titleLabel)

        gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        gridCollectionView.backgroundColor = .clear
        gridCollectionView.showsVerticalScrollIndicator = false
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        gridCollectionView.register(SgptGridCardCollectionViewCell.self,
                                    forCellWithReuseIdentifier: SgptGridCardCollectionViewCell.reuseIdentifier)
        view.addSubview(gridCollectionView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            gridCollectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            gridCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Data

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
                self.sessions = result ?? []
                self.gridCollectionView.reloadData()
            }
        }
    }

    // MARK: - Responsive grid

    /// Same dp/pt thresholds SeeAllGroupClassesViewController.numberOfColumns() uses.
    private func numberOfColumns() -> Int {
        let width = view.bounds.width
        if width < 340 { return 1 }
        if width < 600 { return 2 }
        if width < 900 { return 3 }
        return 4
    }
}

// MARK: - UICollectionView data source / delegate

extension SeeAllSgptViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SgptGridCardCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SgptGridCardCollectionViewCell,
              indexPath.item < sessions.count else {
            return UICollectionViewCell()
        }
        cell.configure(with: sessions[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = numberOfColumns()
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let sectionInset = flowLayout?.sectionInset ?? .zero
        let spacing = flowLayout?.minimumInteritemSpacing ?? 12
        let available = collectionView.bounds.width - sectionInset.left - sectionInset.right
                       - spacing * CGFloat(columns - 1)
        let width = max(available / CGFloat(columns), 0)
        let scale = width / SgptGridCardCollectionViewCell.cardSize.width
        return CGSize(width: width, height: SgptGridCardCollectionViewCell.cardSize.height * scale)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard sessions.indices.contains(indexPath.item) else { return }
        // Must load from Homepage.storyboard, not a plain init - this
        // screen's every IBOutlet (scrollView, titleLabel, all the section
        // containers) is wired in Interface Builder, so a plain init leaves
        // them all nil and crashes on the first line of buildSections().
        let vc: SgptSessionDetailViewController = .instantiate(appStoryboard: .homepage)
        vc.session = sessions[indexPath.item]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
