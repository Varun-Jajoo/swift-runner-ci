//
//  BillDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/05/25.
//

import UIKit

class BillDetailsViewController: UIViewController {
    
    var sessionCost: String?
    var taxesStr: String?
    var totalPayableStr: String?
    
    
    //MARK: ----IBOUTLET
    @IBOutlet weak var billDetailsPopupMBV: UIView!
    @IBOutlet weak var billDetailsTitleLbl: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var billViewMBV: UIStackView!
    @IBOutlet weak var sessionCostMBV: UIView!
    @IBOutlet weak var taxesMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var totalPayoutMBV: UIView!
    @IBOutlet weak var payoutBtn: UIButton!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionAmtLbl: UILabel!
    @IBOutlet weak var taxesTitleLbl: UILabel!
    @IBOutlet weak var taxesAmtLbl: UILabel!
    @IBOutlet weak var totalPayableTitleLbl: UILabel!
    @IBOutlet weak var totalPayableAmtLbl: UILabel!
    @IBOutlet weak var payoutDashLine: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.mainBg.withAlphaComponent(0.7)
        self.payoutBtn.isHidden = true
        self.setupUI()
        self.setupFont()
        self.setInputData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        print("deismiss btn")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payoutBtnActn(_ sender: Any) {
        print("payout btn")
    }
    
    private func setInputData(){
        let amtPart = self.totalPayableStr?.components(separatedBy: " ")
        let currencyStr:String = amtPart?.first ?? ""
        

        
        self.sessionAmtLbl.text = currencyStr + " " + (self.sessionCost ?? "")
        self.taxesAmtLbl.text = currencyStr + " " + (self.taxesStr ?? "")
        self.totalPayableAmtLbl.text = self.totalPayableStr
        
//        self.sessionAmtLbl.text = currencyStr + " " + (self.sessionCost ?? "")
//        self.taxesAmtLbl.text = currencyStr + " " + (self.taxesStr ?? "")
//        self.totalPayableAmtLbl.text = self.totalPayableStr
        
        self.payoutBtn.setTitle(self.totalPayableStr, for: .normal)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.billDetailsPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.billDetailsPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.billViewMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10)
            self.payoutBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
          
            self.payoutDashLine.backgroundColor = UIColor.clear
            self.payoutDashLine.addDashedLine(strokeColor: UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0), lineWidth: 1.0, dashPattern: [6,3])
            //rgba(85, 85, 85, 1)
        }
    }
    
    private func setupFont(){
        billDetailsTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        payoutBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
       
        [
            sessionTitleLbl,
            sessionAmtLbl,
            taxesTitleLbl,
            taxesAmtLbl,
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        })
        
        totalPayableTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        totalPayableAmtLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.billDetailsPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
}
