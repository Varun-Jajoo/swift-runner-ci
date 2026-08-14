//
//  RenewPlanVC.swift
//  MyPT
//
//  Created by Manik Goel on 14/08/26.
//

import UIKit

class RenewPlanVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPlanId: String?
    var onPlanSelected: ((BestPlanData) -> Void)?
    var isGymMembership: Bool = false
    private var selectedIndex: Int?
    var userPlans: [PlanDetailsModel] = [] {
        didSet {
            tableChoosePlan?.reloadData()
            view.setNeedsLayout()
        }
    }
    
    @IBOutlet weak var lblChoosePlan: UILabel!
    @IBOutlet weak var tableChoosePlan: UITableView!
    @IBOutlet weak var viewAgreement: UIView!
    @IBOutlet weak var heightOfTV: NSLayoutConstraint!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSheetHeightFromContent()
    }
    
    private func uiSetup() {
        tableChoosePlan.delegate = self
        tableChoosePlan.dataSource = self
        tableChoosePlan.register(
            UINib(nibName: "RenewPlanTVCell", bundle: nil),
            forCellReuseIdentifier: "RenewPlanTVCell"
        )
        self.lblChoosePlan.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
        self.lblSubtitle.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.tableChoosePlan.reloadData()
    }
    
    private func updateSheetHeightFromContent() {
        tableChoosePlan.layoutIfNeeded()
        let tableContentHeight = tableChoosePlan.contentSize.height
        guard tableContentHeight > 0 else { return }
        let headerAndPaddingHeight: CGFloat = 135
        let totalNeededHeight = tableContentHeight + headerAndPaddingHeight
        let maxHeight = UIScreen.main.bounds.height * 0.85
        let isContentExceedingMax = totalNeededHeight > maxHeight
        let targetHeight = isContentExceedingMax ? maxHeight : max(totalNeededHeight, 250)
        
        tableChoosePlan.isScrollEnabled = isContentExceedingMax
        
        if heightOfTV?.constant != targetHeight {
            heightOfTV?.constant = targetHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPlans.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < userPlans.count else { return 237 }
        let model = userPlans[indexPath.row]
        return (model.is_expired ?? false) ? 106 : 237
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RenewPlanTVCell", for: indexPath) as? RenewPlanTVCell else {
            return UITableViewCell()
        }
        let model = userPlans[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        guard indexPath.row < self.userPlans.count else { return }
        let selectedPlan = self.userPlans[indexPath.row]
        
        let bookingReviewPurchaseVC: BookingReviewPurchaseVC = BookingReviewPurchaseVC.instantiate(appStoryboard: .newBookingModule)
        bookingReviewPurchaseVC.inputParam = DetailsParam(
            type: selectedPlan.type?.value
        )
        bookingReviewPurchaseVC.sessions = selectedPlan.sessions?.value
        bookingReviewPurchaseVC.hidesBottomBarWhenPushed = true
        bookingReviewPurchaseVC.previousSubscriptionID = selectedPlan.id?.value
        bookingReviewPurchaseVC.isGymMembership = selectedPlan.is_membership ?? false

        if let nav = self.navigationController {
            nav.pushViewController(bookingReviewPurchaseVC, animated: false)
        } else if let presentingNav = self.presentingViewController as? UINavigationController {
            self.dismiss(animated: true) {
                presentingNav.pushViewController(bookingReviewPurchaseVC, animated: false)
            }
        } else if let presentingVC = self.presentingViewController, let nav = presentingVC.navigationController {
            self.dismiss(animated: true) {
                nav.pushViewController(bookingReviewPurchaseVC, animated: false)
            }
        }
    }
}
