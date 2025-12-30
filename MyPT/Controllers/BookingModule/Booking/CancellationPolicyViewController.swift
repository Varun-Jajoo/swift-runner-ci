//
//  CancellationPolicyViewController.swift
//  MyPT
//
//  Created by techsaga corp on 19/12/24.
//

import UIKit

class CancellationPolicyViewController: UIViewController {

    var cancellationDetails: CancellationPolicyModel?
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var cancellationPolicyMBV: UIView!
    @IBOutlet weak var camcellationPolicyTitleLbl: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var timeTitleLbl: UILabel!
    @IBOutlet weak var cancellationBeforeTimeLbl: UILabel!
    @IBOutlet weak var freeLbl: UILabel!
    @IBOutlet weak var lineV: UIView!
    @IBOutlet weak var timeCancellationWithinTimeLbl: UILabel!
    @IBOutlet weak var chargesLbl: UILabel!
    @IBOutlet weak var cancellationDescMBV: UIView!
    @IBOutlet weak var cancellationDescTitleLbl: UILabel!
    @IBOutlet weak var cancellationDescLbl: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.setupFont()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }

    @IBAction func okBtnActn(_ sendder: UIButton){
        print("ok btn clicked...")
        self.dismiss(animated: true)
    }
    
    @IBAction func dissmissBtnActn(_ sendder: UIButton){
        print("dissmiss btn clicked...")
        self.dismiss(animated: true)
    }
    
    private func inputData(){
        self.cancellationBeforeTimeLbl.text = cancellationDetails?.freeMsg?.value
        self.timeCancellationWithinTimeLbl.text = cancellationDetails?.cancelMsg?.value
        self.freeLbl.text = cancellationDetails?.freeMsgText?.value
        self.chargesLbl.text = cancellationDetails?.cancelMsgText?.value
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.lineV.backgroundColor = UIColor.clear
            self.lineV.addDashedLine(strokeColor: UIColor.txtDarkGray, lineWidth: 1.0, dashPattern: [6,3])
            
            self.cancellationPolicyMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.cancellationPolicyMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.cancellationDescMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.okBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        
        self.camcellationPolicyTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.okBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.cancellationDescTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        
        [
            self.timeTitleLbl,
            self.cancellationBeforeTimeLbl,
            self.freeLbl,
            self.timeCancellationWithinTimeLbl,
            self.chargesLbl,
            self.cancellationDescLbl
        ].forEach({ [weak self]  in
            guard let self = self else { return  }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.cancellationPolicyMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
}
