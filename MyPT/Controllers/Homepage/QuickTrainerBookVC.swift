//
//  QuickTrainerBookVC.swift
//  MyPT
//
//  Created by Manik Goel on 16/04/26.
//

import UIKit

class QuickTrainerBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var inputParam: DetailsParam?
    var trainerData: SubscriptionSlotTrainer?
    var studiosData: [StudioModel]?
    var selectedSlot: SelectedSlot?
    var callBack: ((StudioModel) -> Void)?
    var onTapBackCallBack: (() -> Void)?
    var slotData: SubscriptionSlotsData?
    var selectedDate: String?
    var reviewAssessmentData: ReviewAssessmentModel?
    
    @IBOutlet weak var viewPresent: UIView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTrainingAt: UILabel!
    @IBOutlet weak var tableGym: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewMid: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDeductedSession: UILabel!
    @IBOutlet weak var lblRemainingSession: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        if inputParam?.type == "gym" {
            getTrainerStudiosList()
            viewAddress.isHidden = true
            tableGym.isHidden = false
        } else {
            reviewAssessmentApi()
            viewAddress.isHidden = false
            tableGym.isHidden = true
        }
    }
    
    private func uiSetup() {
        self.tableGym.delegate = self
        self.tableGym.dataSource = self
        self.tableGym.register(UINib(nibName: "TraiinerGymAddressTVCell", bundle: nil),
                               forCellReuseIdentifier: "TraiinerGymAddressTVCell")
        DispatchQueue.main.async {
            self.viewMid.makeCircular()
            self.lblTrainerName.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
            self.lblDate.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblTime.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblTrainingAt.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblAmount.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblDeductedSession.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblRemainingSession.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.btnContinue.setTitle("CONFIRM BOOKING  ", for: .normal)
            self.btnContinue.setImage(UIImage(named: "blackRightArrow"), for: .normal)
            self.btnContinue.semanticContentAttribute = .forceRightToLeft
            self.btnContinue.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnContinue.tintColor = .mainBg   // arrow color
            self.btnContinue.backgroundColor = .appWhite
            self.btnContinue.setTitleColor(.mainBg, for: .normal)
            self.btnContinue.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }
    
    func setData() {
        let remainingSessions = (slotData?.remainingSessions ?? 0) - 1
        lblDeductedSession.text = "\(slotData?.remainingSessions ?? 0)" + " PT session will be deducted"
        lblRemainingSession.text = "\(slotData?.remainingSessions ?? 0)" + " sessions remaining → " + "\(remainingSessions)" + " after this booking"
        lblTrainerName.text = trainerData?.name ?? ""
        lblDate.text = formatDateToDayMonth(selectedDate ?? "")
        lblTime.text = "\(selectedSlot?.startTime ?? "")" + " - " + "\(selectedSlot?.endTime ?? "")"
        lblAddress.text = reviewAssessmentData?.location_name
    }
    
    func formatDateToDayMonth(_ dateString: String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    @IBAction func onTapAddress(_ sender: UIButton) {
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
            var data = self.inputParam
            data?.addressId = currectAddress.id?.value
            data?.addressData = currectAddress
            self.inputParam = data
            self.reviewAssessmentApi()
        }
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData.data as Any)
            vc.addressData?.append(contentsOf: getResultData.data ?? [])
            present(vc, animated: true)
        })
    }
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.onTapBackCallBack?()
        }
    }
    
    @IBAction func onTapContinue(_ sender: UIButton) {
        bookAssessmentApi()
    }
    
    private func navigateToSessionConfirm() {
        let vc: SessionConformVC = SessionConformVC.instantiate(appStoryboard: .homepage)
        vc.fromQuickTrainerBook = true
        vc.trainerData   = trainerData
        vc.selectedSlot  = selectedSlot
        vc.selectedDate  = selectedDate

        // Presenting chain mein upar jaate jao
        // jab tak NavigationController mile
        var nav: UINavigationController?
        var dismissTarget: UIViewController?

        var current: UIViewController? = self
        while let presenter = current?.presentingViewController {
            if let n = presenter.navigationController {
                nav           = n
                dismissTarget = presenter
                break
            }
            if let n = presenter as? UINavigationController {
                nav           = n
                dismissTarget = presenter
                break
            }
            current = presenter
        }

        guard let nav = nav, let dismissTarget = dismissTarget else {
            print("❌ Nav not found — fallback")
            self.present(vc, animated: true)
            return
        }

        // dismissTarget pe dismiss karo —
        // uske upar ke saare modals automatically band honge
        dismissTarget.dismiss(animated: false) {
            nav.pushViewController(vc, animated: true)
        }
    }
//    private func navigateToSessionConfirm() {
//        let vc: SessionConformVC = SessionConformVC.instantiate(appStoryboard: .homepage)
//        vc.fromQuickTrainerBook = true
//        vc.trainerData = trainerData
//        vc.selectedSlot = selectedSlot
//        vc.selectedDate = selectedDate
//        
//        // Use the navigation stack underneath this modal
//        if let nav = self.navigationController
//            ?? (presentingViewController as? UINavigationController)
//            ?? presentingViewController?.navigationController {
//            
//            // Dismiss this modal, then push
//            dismiss(animated: false) {
//                nav.pushViewController(vc, animated: true)
//            }
//        } else {
//            // Fallback (should rarely be hit)
//            self.present(vc, animated: true)
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studiosData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TraiinerGymAddressTVCell", for: indexPath) as? TraiinerGymAddressTVCell else { return UITableViewCell() }
        if let data = studiosData?[indexPath.row] {
            cell.setStudioData(data: data)
            cell.btnRadio.setImage(UIImage(named: data.isSelected ?? false ? "Radio" : "Unradio"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        for i in 0..<studiosData!.count {
            studiosData?[i].isSelected = false
        }
        studiosData?[indexPath.row].isSelected = true
        tableView.reloadData()
    }
    
    private func getTrainerStudiosList() {
        let params: [String: String] = [
            "long": inputParam?.long ?? "0.0",
            "lat": inputParam?.lat ?? "0.0",
            "trainer_id": inputParam?.trainer_id ?? ""
        ]
        
        HomepageViewModel.getTrainerStudiosList(params: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print(getResultData)
//            trainerData = getResultData.data?.trainer
            studiosData = getResultData.data?.studios?.enumerated().map { index, item in
                return StudioModel(
                    id: item.id,
                    address: item.address,
                    distance: item.distance,
                    image: item.image,
                    name: item.name,
                    isSelected: index == 0
                )
            }
            setData()
            self.tableGym.reloadData()
        })
    }
    
    private func reviewAssessmentApi() {
        var baseParams: [String: String] {
            [
                "type": inputParam?.type ?? "",
                "slot_id": selectedSlot?.id?.value ?? "1",
            ]
        }
        
        var params = baseParams
        
        if inputParam?.type == "home" {
            params["address_id"] = inputParam?.addressData?.id?.value
        } else {
            let selectedStudioId = studiosData?
                .first(where: { $0.isSelected ?? false })?
                .id
            params["studio_id"] = "\(selectedStudioId ?? 0)"
        }
        
        if let trainer_id = inputParam?.trainer_id {
            params["trainer_id"] = trainer_id
        }
        
        TrainerVM.reviewAssessmentApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
                reviewAssessmentData = getData
                setData()
            }
        })
    }
    
    private func bookAssessmentApi() {
        var baseParams: [String: String] {
            [
                "type": inputParam?.type ?? "",
                "slot_id": selectedSlot?.id?.value ?? "1",
                "booking_type": "pt",
            ]
        }
        
        var params = baseParams
        
        if inputParam?.type == "home" {
            params["address_id"] = inputParam?.addressData?.id?.value
        } else {
            let selectedStudioId = studiosData?
                .first(where: { $0.isSelected ?? false })?
                .id
            params["studio_id"] = "\(selectedStudioId ?? 0)"
        }
        
        if let trainer_id = inputParam?.trainer_id {
            params["trainer_id"] = trainer_id
        }
        
        TrainerVM.bookAssessmentApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
//                reviewAssessmentData = getData
//                setData()
//                let vc: SessionConformVC = SessionConformVC.instantiate(appStoryboard: .homepage)
//                vc.reviewAssessmentData = reviewAssessmentData
//                self.navigationController?.pushViewController(vc, animated: false)
                navigateToSessionConfirm()
            }
        })
    }
}
