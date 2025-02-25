//
//  DeletePopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/01/25.
//

import UIKit

class DeletePopupViewController: UIViewController {

    //MARK: --------------IBOUTLET
    @IBOutlet weak var popiupMBV: UIView!
    @IBOutlet weak var alterImgView: UIImageView!
    @IBOutlet weak var alterTitleLbl: UILabel!
    @IBOutlet weak var alterMsgLbl: UILabel!
    @IBOutlet weak var keepBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton){
        print("common btn: ", sender.tag)
        if sender.tag == 801 {
            print("keep btn clicked.", sender.tag)
            self.dismiss(animated: true, completion: {
                print("dismiss view")
            })
        }else{
            print("Delete btn clicked.", sender.tag)
            self.dismiss(animated: true, completion: {
                print("dismiss view")
            })
        }
    }

    func setupUI(){
        DispatchQueue.main.async {
            self.popiupMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.keepBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.deleteBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.alterTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.alterMsgLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.keepBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.deleteBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
}
