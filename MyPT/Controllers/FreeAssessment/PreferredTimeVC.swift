//
//  PreferredTimeVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 14/03/26.
//

import UIKit
import Mixpanel

class PreferredTimeVC: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var params: SlotsParmsModel?
    var selectedSlot: SelectedSlot?
    var restOfTheslots: [SelectedSlot]?
    var otherTrainersList: [OtherTrainer]?
    var inputParam: DetailsParam?
    var selectedSlotID: String?
    var selectedSlotTime: String?
    var selectedTrainerID: String?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lblPickTime: UILabel!
    @IBOutlet weak var lblOtherTrainer: UILabel!
    @IBOutlet weak var collectionOtherTrainer: UICollectionView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var collectionUnavailableTime: UICollectionView!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var viewAvailable: UIView!
    @IBOutlet weak var lblAvailable: UILabel!
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewUnavailable: UIView!
    @IBOutlet weak var viewOtherTrainer: UIView!
    @IBOutlet weak var viewAvailableTag: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        
        let timePicker = CustomTimePickerView(frame: containerView.bounds)
        timePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(timePicker)
        
        // 3. Set initial time on picker from params (only first time)
        if let initialTime = params?.preferred_start_time {
            timePicker.setTime(initialTime) // e.g. "09:30" → picker scrolls to 09:30
            updateTimeLabel(start: initialTime) // show it on label immediately
        }
        
        // 1 & 2. Update label every time picker changes
        timePicker.onTimeChange = { [weak self] time in
            guard let self = self else { return }
            
            self.params?.preferred_start_time = time
            
            // Add 1 hour for end time
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            
            if let startDate = formatter.date(from: time),
               let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) {
                self.params?.preferred_end_time = formatter.string(from: endDate)
            } else {
                self.params?.preferred_end_time = time
            }
            
            // Update label with both times
            self.updateTimeLabel(start: time)
//            self.selectedSlotTime = time
            Mixpanel.mainInstance().track(
                event: "FA_Time_Selected",
                properties: [
                    "time": time
                ]
            )
            self.getSlotsByTime(inputParams: self.params?.getParams() ?? [:])
        }
        
        getSlotsByTime(inputParams: params?.getParams() ?? [:])
    }
    
    // ── MARK: Helper — converts "HH:mm" → "hh:mm a" and builds label string ──
    private func updateTimeLabel(start: String) {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "HH:mm"
        
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "hh:mm a"   // → "09:30 AM"
        
        guard let startDate = input.date(from: start),
              let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) else {
            timeLabel.text = "START: \(start) • END: \(start)"
            return
        }
        
        let startStr = output.string(from: startDate)   // "09:30 AM"
        let endStr   = output.string(from: endDate)     // "10:30 AM"
        timeLabel.text = "START: \(startStr) • END: \(endStr)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    private func uiSetup() {
        collectionUnavailableTime.delegate = self
        collectionUnavailableTime.dataSource = self
        collectionOtherTrainer.delegate = self
        collectionOtherTrainer.dataSource = self
        collectionUnavailableTime.register(
            UINib(nibName: "UnavailableTimeCVCell", bundle: nil),
            forCellWithReuseIdentifier: "UnavailableTimeCVCell"
        )
        collectionOtherTrainer.register(
            UINib(nibName: "OtherTrainerCVCell", bundle: nil),
            forCellWithReuseIdentifier: "OtherTrainerCVCell"
        )
        DispatchQueue.main.async {
            self.viewDot.makeCircular()
            self.lblPickTime.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.lblDate.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblOtherTrainer.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblDay.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblAvailable.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.lblName.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.viewAvailableTag.cornersWithBorder(radius: 8, corners: .allCorners)
//            self.btnProceed.setTitle("PROCEED   ", for: .normal)
//            self.btnProceed.setImage(UIImage(named: "blackArrowRight"), for: .normal)
//            self.btnProceed.semanticContentAttribute = .forceRightToLeft
            self.btnProceed.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//            self.btnProceed.tintColor = .mainBg   // arrow color
//            self.btnProceed.backgroundColor = .appWhite
//            self.btnProceed.setTitleColor(.mainBg, for: .normal)
            self.btnProceed.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }
    
    private func setData() {
        lblDay.text = params?.date?.toFormattedDate()
        lblDate.text = params?.date?.toFormattedDate()
        lblName.text = selectedSlot?.name
        selectedSlotID = selectedSlot?.id?.value ?? ""
        selectedSlotTime = selectedSlot?.startTime ?? ""
        updateContinueButton(isEnabled: selectedSlotID != "")
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
        let vc: AssesmentReiviewBookingVC = AssesmentReiviewBookingVC.instantiate(appStoryboard: .homepage)
        vc.inputParam = inputParam
        vc.slotId = selectedSlotID
        //        vc.isHomeOrGymSelected = true
        //        vc.isHomePreSelected = true
        //        vc.isFreeAssessmentSelected = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapFullSchedule(_ sender: UIButton) {
        let vc: TrainerScheduleVC = TrainerScheduleVC.instantiate(appStoryboard: .homepage)
        vc.modalPresentationStyle = .automatic
        vc.restOfTheslots = restOfTheslots
        vc.selectedDate = params?.date
        vc.callBack = { [weak self] selectedSlotData in
            guard let self = self else { return }
            
            self.selectedSlotID = selectedSlotData.id?.value ?? ""
            
            // ✅ Step 1: sabko false karo
            for i in 0..<(self.restOfTheslots?.count ?? 0) {
                self.restOfTheslots?[i].isSelected = false
            }
            
            // ✅ Step 2: sirf selected ko true karo
            if let index = self.restOfTheslots?.firstIndex(where: {
                $0.id?.value == self.selectedSlotID
            }) {
                self.restOfTheslots?[index].isSelected = true
                self.selectedSlotTime = self.restOfTheslots?[index].startTime
            }
            
            // ✅ reload
            self.collectionUnavailableTime.reloadData()
            self.updateContinueButton(isEnabled: true)
        }
        self.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionUnavailableTime {
            return restOfTheslots?.count ?? 0 > 8 ? 8 : restOfTheslots?.count ?? 0
        } else if collectionView == collectionOtherTrainer {
            if otherTrainersList?.count == 0 {
                collectionView.showEmptyView(
                    title: "No Result Found",
                    image: AppImages.search_NoResult,
                    centerOffset: -30   // adjust if needed
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return otherTrainersList?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if collectionView == collectionUnavailableTime {
               guard let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "UnavailableTimeCVCell", for: indexPath
               ) as? UnavailableTimeCVCell else { return UICollectionViewCell() }
               cell.lblTime.text = restOfTheslots?[indexPath.row].startTime
               // Apply selected/unselected UI
               cell.setSelected(restOfTheslots?[indexPath.row].isSelected ?? false)
               return cell
    
           } else if collectionView == collectionOtherTrainer {
               guard let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "OtherTrainerCVCell", for: indexPath
               ) as? OtherTrainerCVCell else { return UICollectionViewCell() }
               cell.setupCellData(trainerData: otherTrainersList?[indexPath.row])
               cell.trainerTagsData = otherTrainersList?[indexPath.row].tags
               if selectedTrainerID == otherTrainersList?[indexPath.row].id?.value {
                   cell.setSelected(true)
               } else {
                   cell.setSelected(false)
               }
               return cell
           }
           return UICollectionViewCell()
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionUnavailableTime {
            
            let isAlreadySelected = restOfTheslots?[indexPath.row].isSelected ?? false
            
            // Deselect ALL cells first
            for i in 0..<(restOfTheslots?.count ?? 0) {
                restOfTheslots?[i].isSelected = false
            }
            
            // If it was NOT selected before → select it
            // If it WAS selected before → leave it deselected (toggle off)
            if !isAlreadySelected {
                restOfTheslots?[indexPath.row].isSelected = true
                selectedSlotID = restOfTheslots?[indexPath.row].id?.value
                selectedSlotTime = restOfTheslots?[indexPath.row].startTime
                updateContinueButton(isEnabled: true)
            } else {
                updateContinueButton(isEnabled: false)
            }
            collectionUnavailableTime.reloadData()
        } else if collectionView == collectionOtherTrainer {
//            let isAlreadySelected = otherTrainersList?[indexPath.row].isSelected ?? false
//            
//            // Deselect ALL cells first
//            for i in 0..<(otherTrainersList?.count ?? 0) {
//                otherTrainersList?[i].isSelected = false
//            }
//            
//            // If it was NOT selected before → select it
//            // If it WAS selected before → leave it deselected (toggle off)
//            if !isAlreadySelected {
//                otherTrainersList?[indexPath.row].isSelected = true
                selectedTrainerID = otherTrainersList?[indexPath.row].id?.value
                self.params?.other_trainer_id = otherTrainersList?[indexPath.row].id?.value
                self.getSlotsByTime(inputParams: self.params?.getParams() ?? [:])
////                updateContinueButton(isEnabled: true)
//            } else {
////                updateContinueButton(isEnabled: false)
//            }
            collectionOtherTrainer.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionOtherTrainer {
//            let cellWidth = collectionView.frame.size.width / 2
            return CGSize(width: 200, height: collectionView.frame.size.height)
        } else if collectionView == collectionUnavailableTime {
            // 4 items per row with 8pt spacing between them
            let spacing: CGFloat = 8
            let totalSpacing = spacing * 3  // 3 gaps for 4 columns
            let cellWidth = (collectionView.frame.size.width - totalSpacing) / 4
            return CGSize(width: cellWidth, height: 32)
        }
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == collectionUnavailableTime ? 8 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == collectionUnavailableTime ? 8 : 0
    }
    
    func updateContinueButton(isEnabled: Bool) {
        btnProceed.isEnabled = isEnabled
        btnProceed.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.btnProceed.tintColor = .mainBg   // arrow color
                self.btnProceed.backgroundColor = .appWhite
                self.btnProceed.setTitleColor(.mainBg, for: .normal)
            } else {
                self.btnProceed.tintColor = .appWhite
                self.btnProceed.backgroundColor = .appDarkGray
                self.btnProceed.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
//            let image = UIImage(named: "ic_Proceed")?
//                .withRenderingMode(.alwaysOriginal)
//
//            btnProceed.setImage(image, for: .normal)
//            btnProceed.setTitle("", for: .normal)
//
//            btnProceed.backgroundColor = .clear
//            btnProceed.tintColor = .clear
//
//            btnProceed.imageEdgeInsets = .zero
//            btnProceed.titleEdgeInsets = .zero
//            btnProceed.contentEdgeInsets = .zero
//            btnProceed.semanticContentAttribute = .forceLeftToRight
//            btnProceed.adjustsImageWhenHighlighted = false
//            btnProceed.adjustsImageWhenDisabled = false
            
            btnProceed.setTitle("PROCEED WITH \(selectedSlotTime ?? "")", for: .normal)
            btnProceed.setTitleColor(.black, for: .normal)

            let arrowImage = UIImage(named: "blackRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            btnProceed.setImage(arrowImage, for: .normal)

            btnProceed.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            btnProceed.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnProceed.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnProceed.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        } else {
            // 🔴 DISABLED → TEXT + ARROW
            btnProceed.setTitle("PROCEED", for: .normal)
            btnProceed.setTitleColor(.appWhite, for: .normal)

            let arrowImage = UIImage(named: "whiteRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            btnProceed.setImage(arrowImage, for: .normal)

            btnProceed.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            btnProceed.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnProceed.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnProceed.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
}

extension PreferredTimeVC {

    private func getSlotsByTime(inputParams: [String: String]) {
        print(inputParams)
        TrainerVM.getSlotsByTimeApi(viewController: self, inputParms: inputParams, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if let getData = getResultData.data {
                self.selectedSlot = getData.selectedSlot
                self.restOfTheslots = getData.slots
                self.otherTrainersList = getData.otherTrainers
                self.setData()
                DispatchQueue.main.async {
                    self.viewAvailable.isHidden = ((self.selectedSlot?.id?.value) == "") || ((self.selectedSlot?.id) == nil) ? true : false
                    self.viewUnavailable.isHidden = ((self.selectedSlot?.id?.value) == "") || ((self.selectedSlot?.id) == nil) ? false : true
                    self.viewOtherTrainer.isHidden = ((self.selectedSlot?.id?.value) == "") || ((self.selectedSlot?.id) == nil) ? false : true
                    self.collectionOtherTrainer.reloadData()
                    self.collectionUnavailableTime.reloadData()
                }
            }
        })
    }
}

extension String {
    func toFormattedDate() -> String? {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        
        let output = DateFormatter()
        output.dateFormat = "EEE, MMM d"
        
        if let date = input.date(from: self) {
            return output.string(from: date)
        }
        return nil
    }
}
