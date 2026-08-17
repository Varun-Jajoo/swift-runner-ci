//
//  ReviewBookingViewController.swift
//  MyPT
//
//  Created by Manik Goel on 22/05/26.
//

import UIKit

class ReviewBookingViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    var inputParam: DetailsParam?
    var slotId: String?
    var newBookingParmsModel: NewBookingParmsModel?
    var reviewNewBookingData: ReviewNewBookingData?
    var addressID = String()

//    @IBOutlet weak var lblReviewBooking: UILabel!
    @IBOutlet weak var lblSelectDate: UILabel!
//    @IBOutlet weak var lblTrainerName: UILabel!
//    @IBOutlet weak var lblFs1Trainer: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
//    @IBOutlet weak var lblComplete: UILabel!
    @IBOutlet weak var btnBookTrainer: UIButton!
    @IBOutlet weak var btnForwardArrow: UIButton!
//    @IBOutlet weak var primaryCollection: UICollectionView!
//    @IBOutlet weak var secondaryCollection: UICollectionView!
    @IBOutlet weak var lblsessionRemaining: UILabel!
    @IBOutlet weak var viewTrainingLocation: UIView!
    @IBOutlet weak var lblTrainingLocation: UILabel!
//    @IBOutlet weak var viewPrimaryTrainer: UIView!
//    @IBOutlet weak var viewSecondaryTrainer: UIView!
//    @IBOutlet weak var lblPrimaryTrainerTag: UILabel!
    @IBOutlet weak var tableViewDates: UITableView!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setNavUI()
        reviewBookingApi()
    }
    
    private func uiSetup() {
        tableViewDates.delegate = self
        tableViewDates.dataSource = self
        tableViewDates.separatorStyle = .none
        tableViewDates.rowHeight = UITableView.automaticDimension
        tableViewDates.estimatedRowHeight = 160
        tableViewDates.register(UINib(nibName: "ReviewBookingTVCell", bundle: nil), forCellReuseIdentifier: "ReviewBookingTVCell")
//        primaryCollection.delegate = self
//        primaryCollection.dataSource = self
//        secondaryCollection.delegate = self
//        secondaryCollection.dataSource = self
//        primaryCollection.register(
//            UINib(nibName: "PrimaryDateTimeCVCell", bundle: nil),
//            forCellWithReuseIdentifier: "PrimaryDateTimeCVCell"
//        )
//        secondaryCollection.register(
//            UINib(nibName: "PrimaryDateTimeCVCell", bundle: nil),
//            forCellWithReuseIdentifier: "PrimaryDateTimeCVCell"
//        )
        DispatchQueue.main.async {
//            self.lblReviewBooking.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
//            self.viewCircle.makeCircular()
            self.lblSelectDate.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
//            self.lblTrainerName.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
//            self.lblFs1Trainer.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
//            self.lblDay.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//            self.lblTime.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//            self.lblTrainingLocation.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblHome.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
    
            self.lblAddress.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
//            self.lblComplete.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.lblsessionRemaining.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.btnBookTrainer.setTitle("BOOK THE TRAINER   ", for: .normal)
            self.btnBookTrainer.setImage(UIImage(named: "blackArrowRight"), for: .normal)
            self.btnBookTrainer.semanticContentAttribute = .forceRightToLeft
            self.btnBookTrainer.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnBookTrainer.tintColor = .mainBg   // arrow color
            self.btnBookTrainer.backgroundColor = .appWhite
            self.btnBookTrainer.setTitleColor(.mainBg, for: .normal)
            self.btnBookTrainer.setTitleColor(.mainBg, for: .normal)
            self.btnBookTrainer.cornersWithBorder(radius: 8, corners: .allCorners)
        }
        
//        let layout1 = LeftAlignedCollectionViewFlowLayout()
//        layout1.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout1.minimumInteritemSpacing = 8
//        layout1.minimumLineSpacing = 8
//        primaryCollection.collectionViewLayout = layout1
//        
//        let layout2 = LeftAlignedCollectionViewFlowLayout()
//        layout2.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout2.minimumInteritemSpacing = 8
//        layout2.minimumLineSpacing = 8
//        secondaryCollection.collectionViewLayout = layout2
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [AppStrings.reviewYourBooking], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setData() {
//        lblTrainerName.text = reviewNewBookingData?.trainers?.first?.trainer_name ?? ""
        lblsessionRemaining.text = reviewNewBookingData?.sessions_display ?? ""
//        lblPrimaryTrainerTag.text = reviewNewBookingData?.trainers?.first?.badge ?? ""
//        lblDay.text = reviewAssessmentData?.date ?? ""
//        lblTime.text = reviewAssessmentData?.timing ?? ""
        lblAddress.text = reviewNewBookingData?.training_location?.address ?? ""
        lblHome.text = newBookingParmsModel?.type == "gym" ? "Gym" : "Home"
//        viewSecondaryTrainer.isHidden = true
        btnForwardArrow.isHidden = newBookingParmsModel?.type == "gym"
//        lblTrainingLocation.isHidden = newBookingParmsModel?.type == "gym"
//        viewTrainingLocation.isHidden = newBookingParmsModel?.type == "gym"
        DispatchQueue.main.async {
            self.tableViewDates.reloadData()
            // After reload, give the table one layout pass then update the height constraint
            self.tableViewDates.layoutIfNeeded()
            self.heightOfTableView.constant = self.tableViewDates.contentSize.height
        }
    }
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS WITH OPTIONAL TITLE
    override func setLeftMenu(leftImgs:[UIImage?] = [nil], setTitle:[String?] = [nil], setTintColor:UIColor? = .appWhite, setTitleColor:UIColor? = .appWhite){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        var backButton:[UIButton] = []
        backButton.removeAll()
        
        // 2. Clear previous buttons and store new ones
        leftNavButtons.removeAll()
        var leftBarButtonsArray:[UIBarButtonItem] = []
        leftBarButtonsArray.removeAll()
        
        for imgs in leftImgs.enumerated() {
            let backBtn = UIButton(type: .custom)
            backBtn.setImage(imgs.element, for: .normal)
//                backBtn.setTitle("back", for: .normal)
            backBtn.tintColor = setTintColor
            backBtn.setTitleColor(setTitleColor, for: .normal)
                        
            backBtn.sizeToFit()
            backBtn.tag = imgs.offset
            backBtn.addTarget(self, action: #selector(leftBtnActn(sender: )), for: .touchUpInside)
            
            backButton.append(backBtn)
            leftNavButtons.append(backBtn)
            leftBarButtonsArray.append(UIBarButtonItem(customView: backButton[imgs.offset]))
        }
        
        for titleStr in setTitle.enumerated() {
            if titleStr.offset < leftImgs.count {
                backButton[titleStr.offset].setTitle("  " + (titleStr.element ?? ""), for: .normal)
            }
        }
        navigationItem.leftBarButtonItems = leftBarButtonsArray
    }
    
    // MARK: ---------------- SET IMAGE LEFT MENU BUTTONS ACTION
    @objc override func leftBtnActn(sender: UIButton) {
        print("Back Nav Tag",sender.tag)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onTapBookTrainer(_ sender: UIButton) {
        confirmBookingApi()
//        let vc: BookingConfirmViewController = BookingConfirmViewController.instantiate(appStoryboard: .newBookingModule)
////        vc.reviewAssessmentData = reviewAssessmentData
//        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapAddress(_ sender: UIButton) {
        if newBookingParmsModel?.type != "gym" {
            let vc: ChooseAddressPopUpVC = ChooseAddressPopUpVC.instantiate(appStoryboard: .purchase)
            vc.isModalInPresentation = true
            vc.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .medium
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 20
                }
            } else {
                // Fallback on earlier versions
            }
            vc.selectedAddressCallBack = { currectAddress in
//                var data = self.inputParam
//                data?.addressId = currectAddress.id?.value
//                data?.addressData = currectAddress
//                self.inputParam = data
                self.addressID = currectAddress.id?.value ?? ""
                self.lblAddress.text = currectAddress.area_name
//                self.reviewBookingApi()
            }
            TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                print("getResultData", getResultData.data as Any)
                let addresses = getResultData.data ?? []
                vc.addressData?.append(contentsOf: addresses)
                // Pre-select the address that was previously chosen (match by id)
                if let matchedIndex = addresses.firstIndex(where: { $0.id?.value == self.addressID }) {
                    vc.currentSelectedAddress = matchedIndex
                }
                present(vc, animated: true)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewNewBookingData?.trainers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewBookingTVCell", for: indexPath) as? ReviewBookingTVCell else {
            return UITableViewCell() }

        if let trainer = reviewNewBookingData?.trainers?[indexPath.row] {
            cell.configure(with: trainer)
        }

        // When the collection inside the cell resolves its natural height,
        // ask the table to recalculate this row's height without a full reload.
        cell.onHeightResolved = { [weak tableView] _ in
            tableView?.beginUpdates()
            tableView?.endUpdates()
            tableView?.layoutIfNeeded()
            self.heightOfTableView.constant = tableView?.contentSize.height ?? self.heightOfTableView.constant
        }

        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == primaryCollection {
//        } else {
//            return 6
//        }
//      
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == primaryCollection {
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "PrimaryDateTimeCVCell", for: indexPath
//            ) as? PrimaryDateTimeCVCell else { return UICollectionViewCell() }
//            cell.lblDateTime.text = reviewNewBookingData?.trainers?.first?.grouped_slots?[indexPath.row].date_display
//            cell.lblTime.text = reviewNewBookingData?.trainers?.first?.grouped_slots?[indexPath.row].time
//            return cell
//        } else {
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "PrimaryDateTimeCVCell", for: indexPath
//            ) as? PrimaryDateTimeCVCell else { return UICollectionViewCell() }
//            return cell
//        }
//    }
    
    private func reviewBookingApi() {
        var baseParams: [String: Any] {
            [
                "type": newBookingParmsModel?.type ?? "",
                "slot_ids": newBookingParmsModel?.slot_ids ?? "1",
            ]
        }
        var params = baseParams
        
//        if newBookingParmsModel?.type == "home" {
//            params["address_id"] = self.addressID
//        }
//        else {
//            params["studio_id"] = inputParam?.studio_id ?? ""
//        }
        
//        if let trainer_id = inputParam?.trainer_id {
//            params["trainer_id"] = trainer_id
//        }
        
        if let group_id = newBookingParmsModel?.group_id {
            params["group_id"] = group_id
        }
        
        NewBookingVM.reviewBookingApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
                reviewNewBookingData = getData
                self.addressID = String(reviewNewBookingData?.training_location?.id ?? 0)
                setData()
            }
        })
    }
    
    private func confirmBookingApi() {
        var baseParams: [String: Any] {
            [
                "type": newBookingParmsModel?.type ?? "",
                "slot_ids": newBookingParmsModel?.slot_ids ?? "1",
            ]
        }
        
        var params = baseParams
        
        if reviewNewBookingData?.training_location?.type == "Home" {
            params["address_id"] = self.addressID
        }
//        else {
//            params["studio_id"] = inputParam?.studio_id ?? ""
//        }
        
        if let group_id = newBookingParmsModel?.group_id {
            params["group_id"] = group_id
        }
        
        NewBookingVM.confirmBookingApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
//                reviewAssessmentData = getData
//                setData()
                let vc: BookingConfirmViewController = BookingConfirmViewController.instantiate(appStoryboard: .newBookingModule)
                vc.reviewNewBookingData = reviewNewBookingData
                self.navigationController?.pushViewController(vc, animated: false)
            }
        })
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                
                layoutAttribute.frame.origin.x = leftMargin
                
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}
