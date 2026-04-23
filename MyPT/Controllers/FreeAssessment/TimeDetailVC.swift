//
//  TimeDetailVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 15/03/26.
//

import UIKit

class TimeDetailVC: CommonViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lblSessionRemaining: UILabel!
    @IBOutlet weak var lblPickTime: UILabel!
    @IBOutlet weak var tableviewAvailableTime: UITableView!
    @IBOutlet weak var btnProceed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        let timePicker = CustomTimePickerView(frame: containerView.bounds)
        timePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        containerView.addSubview(timePicker)
        
        timePicker.onTimeChange = { [weak self] time in
            self?.timeLabel.text = time
        }
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
        tableviewAvailableTime.delegate = self
        tableviewAvailableTime.dataSource = self
        tableviewAvailableTime.register(UINib(nibName: "DayTimeTVCell", bundle: nil), forCellReuseIdentifier: "DayTimeTVCell")
     
        DispatchQueue.main.async {
            self.lblSessionRemaining.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.lblPickTime.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.btnProceed.setTitle("PROCEED   ", for: .normal)
            self.btnProceed.setImage(UIImage(named: "blackArrowRight"), for: .normal)
            self.btnProceed.semanticContentAttribute = .forceRightToLeft
            self.btnProceed.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnProceed.tintColor = .mainBg   // arrow color
            self.btnProceed.backgroundColor = .appWhite
            self.btnProceed.setTitleColor(.mainBg, for: .normal)
            self.btnProceed.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayTimeTVCell", for: indexPath) as? DayTimeTVCell else {
            return UITableViewCell()
        }
        return cell
    }
}
