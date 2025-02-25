//
//  LoadingViewController.swift
//  MyPT
//
//  Created by techsaga corp on 07/11/24.
//

import UIKit

class LoadingViewController: CommonViewController {

    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var showGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpFont()
        self.hideNavigationBar()
        self.setUpGif()
        self.setUpPush()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.descLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }
    
    func setUpGif(){
        DispatchQueue.main.async {
            self.showGif.backgroundColor = .clear
            self.showGif.loadGif(name: "loadingGif")
        }
    }
    
    //------------------************Auto push to viewController
    func setUpPush(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let vc:WeightViewController = WeightViewController.instantiate(appStoryboard: .main)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
