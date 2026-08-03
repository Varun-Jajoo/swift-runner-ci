//
//  GetStartViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import AVFoundation
import Mixpanel

class GetStartViewController: CommonViewController , LoopingPlayerProgressDelegate {
    
    //MARK: ----------VARIABLE
    var player: LoopingPlayer?
    private var backgroundGradient: CAGradientLayer?
    
    //MARK: ---------IBOUTLET
    @IBOutlet weak var bottomTitleLbl: UILabel!
    @IBOutlet weak var bottomSubTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideNavigationBar()
        setupUI()
        setUpFont()
        self.enableContinueBtn(isSelected: true)
        setupBackgroundGradient()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
        setUpVideo()
    }
    
    //MARK: ---------- SET UI
    func setupUI() {
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    //------------------************Font
    func setUpFont() {
        self.bottomSubTitleLbl.textColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1)
        self.bottomTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.bottomSubTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    func setUpVideo() {
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
    
    private func setupBackgroundGradient() {
        backgroundGradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.frame = viewBackground.bounds

        gradient.colors = [
            UIColor.black.cgColor,
            UIColor(hex: "#0A1A10").cgColor,
            UIColor.black.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)

        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
            .withRenderingMode(.alwaysTemplate)
        
        continueBtn.setImage(arrowImage, for: .normal)
        
        // Force image on right side
        continueBtn.semanticContentAttribute = .forceRightToLeft
        
        // Space between text and image
        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
        
        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn clicked.")
        Mixpanel.mainInstance().track(
            event: "Homepage_Reached",
            properties: [:]
        )
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
