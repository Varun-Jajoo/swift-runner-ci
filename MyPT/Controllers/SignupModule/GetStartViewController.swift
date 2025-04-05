//
//  GetStartViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import AVFoundation

class GetStartViewController: CommonViewController , LoopingPlayerProgressDelegate {
    
    //MARK: ----------VARIABLE
    var player: LoopingPlayer?
    
    //MARK: ---------IBOUTLET
    @IBOutlet weak var bottomTitleLbl: UILabel!
    @IBOutlet weak var bottomSubTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideNavigationBar()
        setupUI()
        setUpFont()
        self.enableContinueBtn(isSelected: true)
        
        setUpVideo()
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.bottomSubTitleLbl.textColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1)
        self.bottomTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.bottomSubTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    func setUpVideo(){
        //MyPTGems.mp4
        if let filePath = Bundle.main.path(forResource: "MyPTGems", ofType: "mp4") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Initialize LoopingPlayer
            player = LoopingPlayer(url: fileURL)
            player?.progressDelegate = self
            
            // Add video layer
            if let player = player {
                let playerLayer = AVPlayerLayer(player: player)
                DispatchQueue.main.async {
                    playerLayer.frame = self.videoView.bounds
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    playerLayer.zPosition = -1
                    self.videoView.layer.addSublayer(playerLayer)
                }
                
                // Start playback
                player.play()
            }
        } else {
            
            // from url
            //                if let videoURL = URL(string: "path") {
            //                    player = LoopingPlayer(url: videoURL)
            //                    player?.progressDelegate = self
            //                    player?.play()
            //                }
            print("Video file not found")
        }
        
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn clicked.")
        
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
        
//        appSceneDelegate?.setupTab(selectedTab: 0)
        
        
//        appSceneDelegate?.goToGuestDashboard()
        
//        appSceneDelegate?.goToDashboard()
        
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
    
    deinit {
        player?.progressDelegate = nil
    }
    
}
