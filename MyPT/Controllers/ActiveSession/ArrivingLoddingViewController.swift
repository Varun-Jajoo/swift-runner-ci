//
//  ArrivingLoddingViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/01/25.
//

import UIKit

class ArrivingLoddingViewController: UIViewController {

    //MARK: -------------- VARIABLE
    var progress: Float = 0.0
    var timer: Timer?
    
    //MARK: -------------- IBOUTLET
    @IBOutlet weak var progressMBV: UIView!
    @IBOutlet weak var progressPercentageLbl: UILabel!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var percentageMBV: CustomPickerView!
    @IBOutlet weak var percentageMBVWidthConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupFont()
        self.startProgressAnimation()
        self.setUpTotalCost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.progressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        self.progressPercentageLbl.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
    }
    
    func setUpTotalCost(){
        // Define items for the picker
        let items = (0...101).compactMap { String($0) }
        // Set the items for the picker
        percentageMBV.labelFont = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        percentageMBV.labelColor = UIColor.appWhite
        percentageMBV.items = items.reversed()
        
        // Initially center the picker at the first item
        percentageMBV.scrollToRow(99, animated: true)
    }
    
    func updateContainerWidth() {
        let widestLabelWidth = percentageMBV.labelWidth
        self.percentageMBVWidthConstrnt?.constant = widestLabelWidth
          view.layoutIfNeeded() // Apply the constraint changes
      }
    
    func startProgressAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.progress += 0.05
            self.progressMBV.drawLineProgress(progressfill: CGFloat(self.progress), fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
            
            let percentProgress = (self.progress*100)/1
//            self.setupProgress(progress: "\(Int(percentProgress))")
            self.percentageMBV.scrollToRow(100-Int(percentProgress), animated: true)
            self.updateContainerWidth()
            
            if self.progress >= 1.0 {
                self.timer?.invalidate()
                self.timer = nil
                
                //----------------------Push to next view
                let vc:ActiveUpcomingSessionViewController = ActiveUpcomingSessionViewController.instantiate(appStoryboard: .library)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setupProgress(progress:String){
        //-------------------- Attributed text
        let defaultAttributes = [
            .font: AppFont.medium.size(16.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(16.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appYellow
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [progress ,
            NSAttributedString(string: "%",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.progressPercentageLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
}
