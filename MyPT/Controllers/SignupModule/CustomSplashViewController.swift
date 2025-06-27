//
//  CustomSplashViewController.swift
//  MyPT
//
//  Created by techsaga corp on 28/05/25.
//

import UIKit

class CustomSplashViewController: UIViewController {

    @IBOutlet weak var splashImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpGif()
    }
    
    private func setUpGif(){
        DispatchQueue.main.async {
            self.splashImgView.backgroundColor = .clear
            self.splashImgView.loadGif(name: "SplashMain")
            self.setuiFlow()
        }
    }
    
    //------------------************Auto push to viewController
    private func setuiFlow(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            appSceneDelegate?.checkIsUserLogin()
        }
    }
    
}
