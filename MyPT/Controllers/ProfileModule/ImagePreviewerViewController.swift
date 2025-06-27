//
//  ImagePreviewerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/06/25.
//

import UIKit

class ImagePreviewerViewController: UIViewController {

    ///-----------VARIABLE
    var previewImg: UIImage? = nil
    var navCtrnl: UINavigationController? 
    
    ///----------------IBOUTLET
    @IBOutlet weak var previewPopupMBV: UIView!
    @IBOutlet weak var dismisssBtn: UIButton!
    @IBOutlet weak var previewImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let img = previewImg {
            self.previewImgView.image = img
        }
    }
  
    @IBAction func dismissBtnActn(_ sender: Any) {
        self.navCtrnl?.dismiss(animated: true, completion: nil)
    }
    
}
