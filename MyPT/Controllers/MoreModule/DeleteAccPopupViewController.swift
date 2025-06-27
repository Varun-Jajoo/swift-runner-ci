//
//  DeleteAccPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/06/25.
//

import UIKit

class DeleteAccPopupViewController: UIViewController {

    @IBOutlet weak var delPopupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    enum delBtnTag: Int {
    case topBar = 601, dismiss, cancel, deleteAcc
    }
    
    @IBAction func delCommonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case delBtnTag.topBar.rawValue:
            self.dismiss(animated: true)
            break
        case delBtnTag.dismiss.rawValue:
            self.dismiss(animated: true)
        case delBtnTag.cancel.rawValue:
            print("cancel btn")
            self.dismiss(animated: true)
        case delBtnTag.deleteAcc.rawValue:
            print("delete acc..")
            RegistrationVM.deleteUserAccApi(viewController: self, completion: {[weak self] getResultData in
                guard self != nil else { return  }
                print("getResultData account delete", getResultData as Any)
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
            })
            
        default:
            print("None.....")
            break
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.delPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.delPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.cancelBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.delBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        descLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            cancelBtn.titleLabel,
            delBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.delPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}
