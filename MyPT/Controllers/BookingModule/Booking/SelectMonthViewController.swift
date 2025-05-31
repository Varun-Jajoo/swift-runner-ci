//
//  SelectMonthViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/12/24.
//

import UIKit

class SelectMonthViewController: UIViewController {

    var filterMonth: ((_ monthData: String?) -> Void)?
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var barBtn: UIButton!
    @IBOutlet weak var monthTitleLbl: UILabel!
    @IBOutlet weak var selectDatePicker: UIDatePicker!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpUI()
        setupFont()
        
        self.view.backgroundColor = UIColor.mainBg.withAlphaComponent(0.7)
        selectDatePicker.date = Date()
        
        if #available(iOS 17.4, *) {
            selectDatePicker.datePickerMode = .yearAndMonth
        } else {
            // Fallback on earlier versions
            selectDatePicker.datePickerMode = .countDownTimer
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUpUI()
    }
    
    func setUpUI(){
        
        selectDatePicker.setValue(UIColor.appWhite, forKeyPath: "textColor")
        selectDatePicker.setValue(true, forKeyPath: "highlightsToday")
        
        DispatchQueue.main.async {
            self.clearBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.okBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        monthTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        clearBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        okBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
    }
    
    enum btnTag: Int {
        case barPop = 1101, clearPop, okPop
    }

    @IBAction func commonBtnActn(_ sender: UIButton) {
    
        switch sender.tag {
        case btnTag.barPop.rawValue:
            print("bar btn clicked.")
            self.dismiss(animated: true)
        case btnTag.clearPop.rawValue:
            print("clearPop btn clicked.")
            self.filterMonth?(nil)
            self.dismiss(animated: true)
        case btnTag.okPop.rawValue:
            let dateStr = DateFormatterHelper.shared.dateString(from: selectDatePicker.date, format: "yyyy-MM")
            self.filterMonth?(dateStr)
            self.dismiss(animated: true)
        default:
            print("none....")
           
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.bottomMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            }else{
                print("tap at popup view.")
            }
        }
    }
    
}
