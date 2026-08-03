//
//  ChoosePrimaryTrainerVC.swift
//  MyPT
//
//  Created by Radha on 16/01/26.
//

import UIKit
import ImageIO
import AVFoundation


class ChoosePrimaryTrainerVC: CommonViewController {

    var player: LoopingPlayer?
    var playerLayer: AVPlayerLayer?
    var inputType: String?
    var inputLat: Double?
    var inputLong: Double?
    var packageType: String?
    var inputParam: DetailsParam?
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var viewPrimary: UIView!
    @IBOutlet weak var lblPrimaryTrainer: UILabel!
    @IBOutlet weak var lblPrimarySubHeading: UILabel!
    @IBOutlet weak var lblPrimaryDetail: UILabel!
    @IBOutlet weak var viewSecondary: UIView!
    @IBOutlet weak var lblBckupTeam: UILabel!
    @IBOutlet weak var lblBackupDetail: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var viewGif: UIView!
//    @IBOutlet weak var gifView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupUI()
        setupVideo()
//        gifView.playGif(named: "Trainer Animation")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if player == nil {
            setupVideo()
        }
        
        player?.play()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer?.frame = viewGif.bounds
    }

    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.5)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    private func uiSetup() {
        self.lblHeading.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.lblSubHeading.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblPrimaryTrainer.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.lblBckupTeam.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.lblPrimarySubHeading.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        self.lblBackupDetail.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        self.lblPrimaryDetail.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        self.btnContinue.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnContinue.setTitle("SELECT PRIMARY TRAINER   ", for: .normal)
        self.btnContinue.setImage(UIImage(named: "blackArrowRight"), for: .normal)
        self.btnContinue.semanticContentAttribute = .forceRightToLeft

        self.btnContinue.tintColor = .mainBg   // arrow color
        self.btnContinue.backgroundColor = .appWhite
        self.btnContinue.setTitleColor(.mainBg, for: .normal)
//        self.sessionSuccessfullyMBV.backgroundColor = .divideLineColor
    }
    
    private func setupUI() {
        self.btnContinue.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
    }
    
    private func setupVideo() {
        guard let filePath = Bundle.main.path(forResource: "trainingTeam", ofType: "mp4") else {
            print("❌ Video file not found")
            return
        }
        let fileURL = URL(fileURLWithPath: filePath)
        
        player = LoopingPlayer(url: fileURL)
        
        if let player = player {
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = viewGif.bounds
            
            viewGif.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            
            if let layer = playerLayer {
                viewGif.layer.addSublayer(layer)
            }
            
            player.play()
        }
    }

    @IBAction func onTapContinue(_ sender: UIButton) {
        if inputParam?.isFromHomeTrainers ?? false {
            if inputParam?.isGroup ?? false {
                let vc:TrainingTeamViewController = TrainingTeamViewController.instantiate(appStoryboard: .purchase)
                vc.trainerIdStr = self.inputParam?.trainer_id
                vc.studioIdStr = self.inputParam?.studio_id
                vc.inputType = self.inputParam?.type ?? ""
                vc.inputParam = inputParam
                vc.package_type = self.packageType
                //                            var newData = self.inputParam
                //                            newData?.trainer_id = "\(trainerDetails?.id ?? 0)"
                //                            vc.inputParam = newData
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc:PackagesVC = PackagesVC.instantiate(appStoryboard: .purchase)
                vc.trainerIdStr = self.inputParam?.trainer_id
                vc.studioIdStr = self.inputParam?.studio_id
                vc.inputType = self.inputParam?.type ?? ""
                vc.package_type = self.packageType
                vc.inputParam = inputParam
                //                            var newData = self.inputParam
                //                            newData?.trainer_id = "\(trainerDetails?.id ?? 0)"
                //                            vc.inputParam = newData
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        } else {
            let vc: TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.flowSlot = .bookTrainerHomeWorkout
            vc.isFromHome = inputType == "home" ? true : false
            vc.inputType = inputType
            vc.inputLat = inputLat
            vc.inputLong = inputLong
            vc.inputParam = inputParam
            vc.package_type = self.packageType
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
