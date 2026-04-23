//
//  GreatNewsVC.swift
//  MyPT
//
//  Created by Manik Goel on 26/01/26.
//

import UIKit

class GreatNewsVC: CommonViewController {
    
    private var hasNavigated = false
    var getAddressData: AddressDataModel? = AddressDataModel()

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFont()
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !hasNavigated else { return }
           hasNavigated = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let vc: GymWorkoutViewController =
            GymWorkoutViewController.instantiate(appStoryboard: .booking)
            vc.flowGymwork = .bookTrainerGymWorkout
            vc.inputParam = DetailsParam(type: "gym", long: self.getAddressData?.long?.value ?? "0.0", lat: self.getAddressData?.lat?.value ?? "0.0", addressId: self.getAddressData?.id?.value, addressData: self.getAddressData)
            vc.inputType = "gym"
            vc.inputLat = Double(self.getAddressData?.lat?.value ?? "") ?? 0.0
            vc.inputLong = Double(self.getAddressData?.long?.value ?? "") ?? 0.0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setUpFont() {
        self.lblTitle.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.lblSubtitle.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblAddress.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        let building = getAddressData?.building_name?.value ?? ""
        let street = getAddressData?.street?.value ?? ""
        let landmark = getAddressData?.landmark ?? ""
        lblAddress.text = building + street + landmark

    }

    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
    }
    
}
