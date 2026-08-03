//
//  PickTimeForBooking.swift
//  MyPT
//
//  Created by Manik Goel on 21/05/26.
//

import UIKit

class PickTimeForBooking: CommonViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Public Input (set by the presenting screen before push)
    var params: NewBookingParmsModel?
    // Legacy properties kept for compatibility with other screens that still reference them.
    var selectedSlot: SelectedSlot?
    var restOfTheslots: [SelectedSlot]?
    var otherTrainersList: [OtherTrainer]?
    var inputParam: DetailsParam?
    var selectedSlotID: String?
    var selectedSlotTime: String?
    var selectedTrainerID: String?

    // MARK: - ViewModel
    private let viewModel = PickTimeForBookingVM()

    private var contentSizeObservation: NSKeyValueObservation?

    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lblPickTime: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var viewAvailable: UIView!
    @IBOutlet weak var tableviewDayDate: UITableView!
    @IBOutlet weak var lblSessionRemaining: UILabel!
    @IBOutlet weak var viewStartTime: UIView!
    @IBOutlet weak var heightOfTableview: NSLayoutConstraint!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        configureTimePicker()
        updateContinueButton(isEnabled: false)

        // Kick off the initial data load
        if let params = params {
            viewModel.configure(with: params)
//            viewModel.fetchSlots(viewController: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationColor(setColor: .clear)
        statusBarColor(setColor: .clear)
        setupNavUI()
    }
    
    deinit {
        contentSizeObservation?.invalidate()
        contentSizeObservation = nil
    }

    // MARK: - Setup
    private func setupNavUI() {
        setupNavigationBarProgress(progressBarWidth: view.frame.size.width * 0.37)
        setProgress(0.3)
        setLeftMenu(
            leftImgs: [AppImages.backArrowWithBg],
            setTitle: [""],
            setTintColor: .black,
            setTitleColor: .clear
        )
    }

    private func setupUI() {
        // TableView
        tableviewDayDate.delegate = self
        tableviewDayDate.dataSource = self
        tableviewDayDate.separatorStyle = .none
        tableviewDayDate.register(
            UINib(nibName: "PreferedTimeTVCell", bundle: nil),
            forCellReuseIdentifier: "PreferedTimeTVCell"
        )
        
        contentSizeObservation = tableviewDayDate.observe(\.contentSize, options: [.new]) { [weak self] (tv, change) in
            guard let self = self else { return }
            self.heightOfTableview.constant = tv.contentSize.height
        }

        DispatchQueue.main.async {
            self.lblPickTime.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.btnProceed.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnProceed.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }

    private func configureTimePicker() {
        let timePicker = CustomTimePickerView(frame: containerView.bounds)
        timePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(timePicker)

        // Set default time to 00:00
        let defaultTime = "00:00"
        timePicker.setTime(defaultTime)
        updateTimeLabel(start: defaultTime)
        params?.preferred_time = defaultTime

        // Hide viewAvailable and viewStartTime initially
        viewAvailable.isHidden = true
        viewStartTime.isHidden = true

        // Re-fetch slots whenever the user changes the time
        timePicker.onTimeChange = { [weak self] time in
            guard let self = self else { return }
            self.params?.preferred_time = time
            self.updateTimeLabel(start: time)

            if time != "00:00" {
                // Reveal the bottom cards
                self.viewAvailable.isHidden = false
                self.viewStartTime.isHidden = false

                // Rebuild params and re-fetch; ViewModel will reset dateStates automatically.
                if var updatedParams = self.viewModel.requestParams {
                    updatedParams.preferred_time = time
                    self.viewModel.configure(with: updatedParams)
                    self.viewModel.fetchSlots(viewController: self)
                }
            } else {
                // If it goes back to 00:00, hide them again
                self.viewAvailable.isHidden = true
                self.viewStartTime.isHidden = true
            }
        }
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        lblSessionRemaining.text = "SESSION REMAINING: 0 of 0"
        
        // Full reload after initial API response
        viewModel.onDatesLoaded = { [weak self] in
            guard let self = self else { return }
            self.tableviewDayDate.reloadData()
            
            let totalAvailable = self.viewModel.getSlotesModelData?.totalAvailableSlots ?? 0
            let totalSession = self.viewModel.getSlotesModelData?.total_session ?? 0
            self.lblSessionRemaining.text = "SESSION REMAINING: \(totalAvailable) of \(totalSession)"
        }

        // Surgical reload — only the affected row
        viewModel.onDateUpdated = { [weak self] indexPath in
            self?.tableviewDayDate.reloadRows(at: [indexPath], with: .automatic)
        }

        // Proceed button state
        viewModel.onProceedStateChanged = { [weak self] canProceed in
            self?.updateContinueButton(isEnabled: canProceed)
        }

        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            AlertHelper.shared.alertMesssage(view: self, title: "", message: message)
        }
    }

    // MARK: - Time Label
    private func updateTimeLabel(start: String) {
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "HH:mm"

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "hh:mm a"

        guard
            let startDate = input.date(from: start),
            let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)
        else {
            timeLabel.text = "START: \(start) • END: \(start)"
            return
        }
        timeLabel.text = "START: \(output.string(from: startDate)) • END: \(output.string(from: endDate))"
    }

    // MARK: - Actions
    @IBAction func onTapProceed(_ sender: UIButton) {
        let vc: ReviewBookingViewController = ReviewBookingViewController.instantiate(appStoryboard: .newBookingModule)
        
        // Retrieve final params updated with the latest slot IDs and filtered dates
        self.params = viewModel.buildFinalParams()
        
        // Pass final params to the next screen
        vc.newBookingParmsModel = self.params
        // vc.inputParam = self.inputParam
        
        navigationController?.pushViewController(vc, animated: false)
    }

    @IBAction func onTapFullSchedule(_ sender: UIButton) {
        let vc: TrainerScheduleVC = TrainerScheduleVC.instantiate(appStoryboard: .homepage)
        vc.modalPresentationStyle = .automatic
        vc.restOfTheslots = restOfTheslots
        vc.callBack = { [weak self] selectedSlotData in
            guard let self = self else { return }
            self.selectedSlotID = selectedSlotData.id?.value ?? ""
            for i in 0..<(self.restOfTheslots?.count ?? 0) {
                self.restOfTheslots?[i].isSelected = false
            }
            if let index = self.restOfTheslots?.firstIndex(where: { $0.id?.value == self.selectedSlotID }) {
                self.restOfTheslots?[index].isSelected = true
                self.selectedSlotTime = self.restOfTheslots?[index].startTime
            }
            self.updateContinueButton(isEnabled: true)
        }
        present(vc, animated: true)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PreferedTimeTVCell",
                for: indexPath
            ) as? PreferedTimeTVCell,
            let state = viewModel.dateState(at: indexPath)
        else {
            return UITableViewCell()
        }

        cell.configure(with: state)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let state = viewModel.dateState(at: indexPath) else { return }

        let vc: AvailableTrainerPresentVC = AvailableTrainerPresentVC.instantiate(appStoryboard: .newBookingModule)

        // Pass a copy of params with the specific date set for this row
        var rowParams = params
        rowParams?.date = state.date
        vc.params = rowParams
        vc.dates = nil          // AvailableTrainerPresentVC fetches its own data
        vc.targetDate = state.date
        vc.preSelectedSlotId = state.confirmedSlotId

        vc.isModalInPresentation = false
        vc.modalPresentationStyle = .pageSheet

        // Typed callback — receives full AlternativeSelection, not just a String
        vc.onAlternativeSelected = { [weak self] selection in
            guard let self = self else { return }
            // ViewModel mutates only the matching row and fires onDateUpdated(indexPath)
            self.viewModel.updateDateState(with: selection)
        }

        // Callback to remove the date locally
        vc.onRemoveDateCallback = { [weak self] dateToRemove in
            guard let self = self else { return }
            if let index = self.viewModel.dateStates.firstIndex(where: { $0.date == dateToRemove }) {
                self.viewModel.deleteDateState(at: index)
                self.tableviewDayDate.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                self.params = self.viewModel.buildFinalParams()
            }
        }

        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            // Delete locally in the ViewModel
            self.viewModel.deleteDateState(at: indexPath.row)
            
            // Delete row in UITableView with animation
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Keep local params in sync
            self.params = self.viewModel.buildFinalParams()
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(named: "deleteIcon")
        deleteAction.backgroundColor = UIColor(red: 59/255.0, green: 34/255.0, blue: 35/255.0, alpha: 1.0) // Dark wine/brownish color matching the design (#3B2223)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    // MARK: - Continue Button

    func updateContinueButton(isEnabled: Bool) {
        btnProceed.isEnabled = isEnabled
        btnProceed.isUserInteractionEnabled = isEnabled

        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.btnProceed.tintColor = .mainBg
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
            let image = UIImage(named: "ConfirmSlot")?.withRenderingMode(.alwaysOriginal)
            btnProceed.setImage(image, for: .normal)
            btnProceed.setTitle("", for: .normal)
            btnProceed.backgroundColor = .clear
            btnProceed.tintColor = .clear
            btnProceed.imageEdgeInsets = .zero
            btnProceed.titleEdgeInsets = .zero
            btnProceed.contentEdgeInsets = .zero
            btnProceed.semanticContentAttribute = .forceLeftToRight
            btnProceed.adjustsImageWhenHighlighted = false
            btnProceed.adjustsImageWhenDisabled = false
        } else {
            btnProceed.setTitle("CONFIRM TIME SLOTS", for: .normal)
            btnProceed.setTitleColor(.appWhite, for: .normal)
            let arrowImage = UIImage(named: "whiteRightArrow")?.withRenderingMode(.alwaysOriginal)
            btnProceed.setImage(arrowImage, for: .normal)
            btnProceed.semanticContentAttribute = .forceRightToLeft
            btnProceed.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnProceed.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnProceed.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
}
