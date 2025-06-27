//
//  BookingDetailsQRViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/06/25.
//

import UIKit

class BookingDetailsQRViewController: UIViewController {

    var qrUrlStr: String?
    
    
    @IBOutlet weak var qrPopupMBV: UIView!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var qrImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qrImgView.loadImage(urlString: qrUrlStr, placeholder: nil)
    }
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
   

}
