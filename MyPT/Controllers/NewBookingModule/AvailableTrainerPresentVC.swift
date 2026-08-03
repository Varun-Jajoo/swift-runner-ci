//
//  AvailableTrainerPresentVC.swift
//  MyPT
//
//  Created by Manik Goel on 21/06/26.
//

import UIKit

class AvailableTrainerPresentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Input
    /// The date this sheet is resolving (e.g. "2026-07-22").
    /// Set by `PickTimeForBooking` before presenting.
    var targetDate: String = ""
    
    /// Booking params — AvailableTrainerPresentVC fetches its own slot data.
    var params: NewBookingParmsModel?
    
    /// Legacy input — kept for backward compatibility.
    var dates: DateElement?
    
    /// The slot ID to pre-select if the user is editing an already-selected date.
    var preSelectedSlotId: String?
    
    // MARK: - Typed Callback
    /// Replaces the old `callback: ((String) -> Void)?`.
    /// Fires when the user taps Continue with a valid selection.
    var onAlternativeSelected: ((AlternativeSelection) -> Void)?
    
    /// Fires when the user taps Remove Date.
    var onRemoveDateCallback: ((String) -> Void)?
    
    // MARK: - Private State
    private var getSlotesModelData: GetSlotesModelData?
    private var selectedSlotId = String()
    private var selectedSlotTimeDisplay = String()
    private var selectedSlotStartTime = String()
    private var selectedSlotEndTime = String()
    private var selectedTrainerId = String()
    private var selectedTrainerName = String()
    
    // MARK: - IBOutlets
    @IBOutlet var mainBackgroundView: UIView!
    @IBOutlet weak var viewPresent: UIView!
    @IBOutlet weak var lblDayDate: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var viewAvailable: UIView!
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var lblSecondaryTrainer: UILabel!
    @IBOutlet weak var tbaleSecondaryTrainer: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewUnavilable: UIView!
    @IBOutlet weak var lblUnavailableTrainer: UILabel!
    @IBOutlet weak var viewUnavailableText: UIView!
    @IBOutlet weak var lblUnavailableText: UILabel!
    @IBOutlet weak var btnRemoveDate: UIButton!
    @IBOutlet weak var viewFirstRound: UIView!
    @IBOutlet weak var viewSecondRound: UIView!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Clear dates so the API returns all slots for the trainer — not filtered by date.
        params?.dates?.removeAll()
        
        getNewBookingSlotsApi(inputParams: params?.getParams() ?? [:])
        updateContinueButton(isEnabled: false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        tbaleSecondaryTrainer.delegate = self
        tbaleSecondaryTrainer.dataSource = self
        tbaleSecondaryTrainer.register(
            UINib(nibName: "TrainerAvailabilityTVCell", bundle: nil),
            forCellReuseIdentifier: "TrainerAvailabilityTVCell"
        )
        
        tbaleSecondaryTrainer.isScrollEnabled = false
        
        contentSizeObservation = tbaleSecondaryTrainer.observe(\.contentSize, options: [.new]) { [weak self] (tv, change) in
            guard let self = self else { return }
            self.heightOfTableView.constant = tv.contentSize.height
        }
        
        collectionDate.delegate = self
        collectionDate.dataSource = self
        collectionDate.register(
            UINib(nibName: "UnavailableTimeCVCell", bundle: nil),
            forCellWithReuseIdentifier: "UnavailableTimeCVCell"
        )
        
        DispatchQueue.main.async {
            self.lblDayDate.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.lblHeading.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblTrainerName.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblSecondaryTrainer.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.btnContinue.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnRemoveDate.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.btnRemoveDate.tintColor = .appRed
//            self.btnRemoveDate.backgroundColor = .appWhite
            self.btnRemoveDate.setTitleColor(.appRed, for: .normal)
            self.btnContinue.cornersWithBorder(radius: 8, corners: .allCorners)
            self.lblUnavailableTrainer.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblUnavailableText.font = AppFont.regular.size(8.0, familyName: familyFunnelSans)
            self.viewUnavilable.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 61.0/255.0, green: 62/255.0, blue: 63/255.0, alpha: 1.0), cornerRadious: 12.0)
            self.viewFirstRound.makeCircular()
            self.viewSecondRound.makeCircular()
        }
    }
    
    // MARK: - Data Binding
    private func setData() {
        lblTrainerName.text = getSlotesModelData?.primaryTrainer?.name
        lblUnavailableTrainer.text = getSlotesModelData?.primaryTrainer?.name
        // Use the formatted date from the API if available; fall back to targetDate
        lblDayDate.text = getSlotesModelData?.date_formatted ?? targetDate
        viewAvailable.isHidden = getSlotesModelData?.primaryTrainer?.slots?.count == 0
        viewUnavilable.isHidden = !(getSlotesModelData?.primaryTrainer?.slots?.count == 0)
        DispatchQueue.main.async {
            self.tbaleSecondaryTrainer.reloadData()
            self.collectionDate.reloadData()
        }
    }
    
    // MARK: - Dismiss Handler
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.mainBackgroundView.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("tap at popup view.")
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func onTapContinue(_ sender: UIButton) {
        // Build the typed AlternativeSelection payload and fire the callback.
        let selection = AlternativeSelection(
            date: targetDate,
            slotId: selectedSlotId,
            trainerId: selectedTrainerId,
            trainerName: selectedTrainerName,
            timeDisplay: selectedSlotTimeDisplay,
            startTime: selectedSlotStartTime,
            endTime: selectedSlotEndTime
        )
        
        dismiss(animated: true) { [weak self] in
            self?.onAlternativeSelected?(selection)
        }
    }
    
    // MARK: - UITableViewDataSource / Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSlotesModelData?.secondaryTrainers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerAvailabilityTVCell", for: indexPath) as? TrainerAvailabilityTVCell else { return UITableViewCell() }
        cell.imgBG.image = UIImage(named: "BlackBG")
        cell.secondaryTrainerData = getSlotesModelData?.secondaryTrainers?[indexPath.row]
        cell.trainerIndex = indexPath.row
        cell.viewRound.backgroundColor = indexPath.row == 0 ? UIColor(red: 138.0/255.0, green: 43/255.0, blue: 255/255.0, alpha: 1.0) : UIColor(red: 255.0/255.0, green: 224/255.0, blue: 100/255.0, alpha: 1.0)
        let isPrimaryTrainerEmpty = (getSlotesModelData?.primaryTrainer?.slots?.count ?? 0) == 0
        let firstAvailableSecondaryIndex = getSlotesModelData?.secondaryTrainers?.firstIndex(where: { ($0.slots?.count ?? 0) > 0 })
        let showTag = isPrimaryTrainerEmpty && (firstAvailableSecondaryIndex == indexPath.row)
        
        cell.setData(showAvailableTag: showTag)
        cell.collectiondate.reloadData()
        cell.onSlotSelected = { [weak self] trainerIndex, slotIndex, isSelected in
            guard let self = self else { return }
            self.handleSecondarySlotSelected(trainerIndex: trainerIndex, slotIndex: slotIndex, isSelected: isSelected)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDataSource / Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getSlotesModelData?.primaryTrainer?.slots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UnavailableTimeCVCell", for: indexPath
        ) as? UnavailableTimeCVCell else { return UICollectionViewCell() }
        
        let slot = getSlotesModelData?.primaryTrainer?.slots?[indexPath.row]
        cell.lblTime.text = slot?.time_display?.components(separatedBy: "-").first
        cell.setSelectedSlot(slot?.isSelected ?? false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        
        let isAlreadySelected = getSlotesModelData?.primaryTrainer?.slots?[indexPath.row].isSelected ?? false
        
        // Deselect all primary slots
        for i in 0..<(getSlotesModelData?.primaryTrainer?.slots?.count ?? 0) {
            getSlotesModelData?.primaryTrainer?.slots?[i].isSelected = false
        }
        
        // Deselect all secondary trainer slots
        deselectAllSecondarySlots()
        
        if !isAlreadySelected {
            getSlotesModelData?.primaryTrainer?.slots?[indexPath.row].isSelected = true
            
            // Capture the full slot data for the typed callback payload
            if let slot = getSlotesModelData?.primaryTrainer?.slots?[indexPath.row] {
                selectedSlotId = slot.id?.value ?? ""
                selectedSlotTimeDisplay = slot.time_display ?? ""
                selectedSlotStartTime = slot.startTime ?? ""
                selectedSlotEndTime = slot.endTime ?? ""
            }
            // Capture trainer data
            selectedTrainerId = getSlotesModelData?.primaryTrainer?.id.map { String($0) } ?? ""
            selectedTrainerName = getSlotesModelData?.primaryTrainer?.name ?? ""
            
            updateContinueButton(isEnabled: true)
        } else {
            // User deselected — clear captured values and disable button
            clearSelectedSlotData()
            updateContinueButton(isEnabled: false)
        }
        collectionDate.reloadData()
        tbaleSecondaryTrainer.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3   // 3 gaps for 4 columns
        let cellWidth = (collectionView.frame.size.width - totalSpacing) / 4
        return CGSize(width: cellWidth, height: 32)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat { 8 }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat { 8 }
    
    // MARK: - Continue Button
    
    func updateContinueButton(isEnabled: Bool) {
        btnContinue.isEnabled = isEnabled
        btnContinue.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.btnContinue.tintColor = .mainBg
                self.btnContinue.backgroundColor = .appWhite
                self.btnContinue.setTitleColor(.mainBg, for: .normal)
            } else {
                self.btnContinue.tintColor = .appWhite
                self.btnContinue.backgroundColor = .appDarkGray
                self.btnContinue.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            let image = UIImage(named: "ButtonContinue")?.withRenderingMode(.alwaysOriginal)
            btnContinue.setImage(image, for: .normal)
            btnContinue.setTitle("", for: .normal)
            btnContinue.backgroundColor = .clear
            btnContinue.tintColor = .clear
            btnContinue.imageEdgeInsets = .zero
            btnContinue.titleEdgeInsets = .zero
            btnContinue.contentEdgeInsets = .zero
            btnContinue.semanticContentAttribute = .forceLeftToRight
            btnContinue.adjustsImageWhenHighlighted = false
            btnContinue.adjustsImageWhenDisabled = false
        } else {
            btnContinue.setTitle("CONTINUE", for: .normal)
            btnContinue.setTitleColor(.appWhite, for: .normal)
            let arrowImage = UIImage(named: "whiteRightArrow")?.withRenderingMode(.alwaysOriginal)
            btnContinue.setImage(arrowImage, for: .normal)
            btnContinue.semanticContentAttribute = .forceRightToLeft
            btnContinue.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnContinue.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnContinue.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    // MARK: - API
    
    private func getNewBookingSlotsApi(inputParams: [String: Any]) {
        print("[AvailableTrainerPresentVC] Fetching slots with params:", inputParams)
        Utility.showLoader(title: AppAlertStrings.almostDone, subtitle: AppAlertStrings.loaderMsg)
        NewBookingVM.getNewBookingGroupSlotsApi(
            viewController: self,
            inputParms: inputParams,
            completion: { [weak self] result in
                Utility.hideLoader()
                guard let self = self, let data = result?.data else { return }
                self.getSlotesModelData = data
                self.tbaleSecondaryTrainer.isHidden = self.getSlotesModelData?.secondaryTrainers?.count ?? 0 == 0
                self.lblSecondaryTrainer.isHidden = self.getSlotesModelData?.secondaryTrainers?.count ?? 0 == 0
                
                // Pre-select the slot if we have a preSelectedSlotId
                if let preSelectedId = self.preSelectedSlotId {
                    var found = false
                    
                    // Check primary trainer slots first
                    if let slots = self.getSlotesModelData?.primaryTrainer?.slots {
                        for i in 0..<slots.count {
                            if slots[i].id?.value == preSelectedId {
                                self.getSlotesModelData?.primaryTrainer?.slots?[i].isSelected = true
                                self.selectedSlotId = preSelectedId
                                self.selectedSlotTimeDisplay = slots[i].time_display ?? ""
                                self.selectedSlotStartTime = slots[i].startTime ?? ""
                                self.selectedSlotEndTime = slots[i].endTime ?? ""
                                self.selectedTrainerId = self.getSlotesModelData?.primaryTrainer?.id.map { String($0) } ?? ""
                                self.selectedTrainerName = self.getSlotesModelData?.primaryTrainer?.name ?? ""
                                self.updateContinueButton(isEnabled: true)
                                found = true
                                break
                            }
                        }
                    }
                    
                    // If not found in primary, check secondary trainers
                    if !found, let secondaryTrainers = self.getSlotesModelData?.secondaryTrainers {
                        for t in 0..<secondaryTrainers.count {
                            if let slots = secondaryTrainers[t].slots {
                                for s in 0..<slots.count {
                                    if slots[s].id?.value == preSelectedId {
                                        self.getSlotesModelData?.secondaryTrainers?[t].slots?[s].isSelected = true
                                        self.selectedSlotId = preSelectedId
                                        self.selectedSlotTimeDisplay = slots[s].time_display ?? ""
                                        self.selectedSlotStartTime = slots[s].startTime ?? ""
                                        self.selectedSlotEndTime = slots[s].endTime ?? ""
                                        self.selectedTrainerId = String(secondaryTrainers[t].id ?? 0)
                                        self.selectedTrainerName = secondaryTrainers[t].name ?? ""
                                        self.updateContinueButton(isEnabled: true)
                                        found = true
                                        break
                                    }
                                }
                            }
                            if found { break }
                        }
                    }
                }
                
                self.setData()
            }
        )
    }
    
    // MARK: - Cross-Selection Helpers
    
    /// Deselects every slot across all secondary trainers.
    private func deselectAllSecondarySlots() {
        guard let count = getSlotesModelData?.secondaryTrainers?.count else { return }
        for t in 0..<count {
            let slotCount = getSlotesModelData?.secondaryTrainers?[t].slots?.count ?? 0
            for s in 0..<slotCount {
                getSlotesModelData?.secondaryTrainers?[t].slots?[s].isSelected = false
            }
        }
    }
    
    /// Deselects every slot in the primary trainer.
    private func deselectAllPrimarySlots() {
        let count = getSlotesModelData?.primaryTrainer?.slots?.count ?? 0
        for i in 0..<count {
            getSlotesModelData?.primaryTrainer?.slots?[i].isSelected = false
        }
    }
    
    /// Clears all captured selection state.
    private func clearSelectedSlotData() {
        selectedSlotId = ""
        selectedSlotTimeDisplay = ""
        selectedSlotStartTime = ""
        selectedSlotEndTime = ""
        selectedTrainerId = ""
        selectedTrainerName = ""
    }
    
    /// Called by `TrainerAvailabilityTVCell.onSlotSelected` when a secondary slot is tapped.
    private func handleSecondarySlotSelected(trainerIndex: Int, slotIndex: Int, isSelected: Bool) {
        // Deselect all primary slots
        deselectAllPrimarySlots()
        
        // Deselect ALL secondary trainers (including the tapped one) in the model —
        // the cell mutated only its local copy (struct value type), so we must write back here.
        guard let count = getSlotesModelData?.secondaryTrainers?.count else { return }
        for t in 0..<count {
            let slotCount = getSlotesModelData?.secondaryTrainers?[t].slots?.count ?? 0
            for s in 0..<slotCount {
                getSlotesModelData?.secondaryTrainers?[t].slots?[s].isSelected = false
            }
        }
        
        // Now mark only the tapped slot as selected in the model
        if isSelected {
            getSlotesModelData?.secondaryTrainers?[trainerIndex].slots?[slotIndex].isSelected = true
            
            // Capture the selected secondary slot data
            if let slot = getSlotesModelData?.secondaryTrainers?[trainerIndex].slots?[slotIndex] {
                selectedSlotId = slot.id?.value ?? ""
                selectedSlotTimeDisplay = slot.time_display ?? ""
                selectedSlotStartTime = slot.startTime ?? ""
                selectedSlotEndTime = slot.endTime ?? ""
            }
            selectedTrainerId = String(getSlotesModelData?.secondaryTrainers?[trainerIndex].id ?? 0)
            selectedTrainerName = getSlotesModelData?.secondaryTrainers?[trainerIndex].name ?? ""
            updateContinueButton(isEnabled: true)
        } else {
            clearSelectedSlotData()
            updateContinueButton(isEnabled: false)
        }
        
        // Reload both views — cells now read from the updated model
        collectionDate.reloadData()
        tbaleSecondaryTrainer.reloadData()
    }
    
    @IBAction func onTapRemoveDate(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.onRemoveDateCallback?(self.targetDate)
        }
    }
    
    deinit {
        contentSizeObservation?.invalidate()
        contentSizeObservation = nil
    }
}
