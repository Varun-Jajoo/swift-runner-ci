//
//  TopupUpgradeBillingViewController.swift
//  MyPT
//
//  Created by techsaga corp on 29/07/25.
//

import UIKit
import AVFoundation

class TopupUpgradeBillingViewController: UIViewController {
    //MARK: ------------- VARIABLE
    var planFlow: ChoosePlanFlow = .choosePlanDefault
    var player: AVAudioPlayer?
    var paymentDetails: UpgradePaymentDetailModel?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var mainStckView: UIStackView!
    @IBOutlet weak var confirmationMBV: UIView!
    @IBOutlet weak var shoBillMBV: UIView!
    @IBOutlet weak var successImgView: UIImageView!
    @IBOutlet weak var confirmationTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var backToHomeBtn: UIButton!
    @IBOutlet weak var shoBillMBVHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var billMBV: UIView!
    @IBOutlet weak var billMBVHeightConstnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationMBV.isHidden = false
        self.shoBillMBV.isHidden = true
        setUpUI()
        self.navigationItem.hidesBackButton = true
        self.backToHomeBtn.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.hidesBackButton = false
    }
    
    @IBAction func backToHomeBtnActn(_ sender: Any) {
        self.navigationController?.popToViewController(ofClass: DashboardGuestViewController.self, animated: true)
    }
    
    private func billView(){
        DispatchQueue.main.async {
            let shapeView = HalfBillShape()
            shapeView.layer.shadowColor = UIColor.black.cgColor
            shapeView.layer.shadowOpacity = 0.3
            shapeView.layer.shadowOffset = CGSize(width: 0, height: 2)
            shapeView.layer.shadowRadius = 4
            shapeView.backgroundColor = .clear
            //     only for testign       shapeView.billBackgroundColor = UIColor.appWhite
            //     only for testign        shapeView.lineBgColor = UIColor.appDarkGray
            self.billMBV.addSubview(shapeView)
            self.billMBVHeightConstnt.constant = 400
            //----------------------
            shapeView.translatesAutoresizingMaskIntoConstraints = false
            shapeView.scrollView.isScrollEnabled = true // Disable internal scrolling
            // Get a reference to the contentView within billShape
            let contentView = shapeView.contentView
            NSLayoutConstraint.activate([
                shapeView.topAnchor.constraint(equalTo: self.billMBV.topAnchor, constant: 30),
                shapeView.leadingAnchor.constraint(equalTo: self.billMBV.leadingAnchor, constant: 19),
                shapeView.trailingAnchor.constraint(equalTo: self.billMBV.trailingAnchor, constant: -19),
                shapeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20) // Tie billShape's bottom to its internal contentView's bottom
            ])
            //--------------------
            shapeView.cornerSize = CGSize(width: 24, height: 24)
            shapeView.cornerSide = [.bottomLeft, .bottomRight]
            //--------------------*********** Data Setup
            switch self.planFlow {
            case .topUp:
                shapeView.customerDatailsView.isHidden = false
                shapeView.packageTitleLabel.text = "Package"
                shapeView.packageLabel.text = self.paymentDetails?.package?.value
                shapeView.startDate = (title: "Valid Upto", value: self.paymentDetails?.new_end_date?.value ?? "")
                shapeView.validUptoDate = (title: "", value: "")
                shapeView.trainerBadgeImageView.isHidden = true
                shapeView.nextImageView.isHidden = true
                break
                
            case .upgrade, .renew:
                shapeView.customerDatailsView.isHidden = false
                shapeView.packageTitleLabel.text = "Package"
                shapeView.packageLabel.text = self.paymentDetails?.package?.value
                shapeView.startDate = (title: "Start Date", value: self.paymentDetails?.start_date?.value ?? "")
                shapeView.validUptoDate = (title: "Valid Upto", value: self.paymentDetails?.new_end_date?.value ?? "")
                shapeView.trainerBadgeImageView.isHidden = true
                shapeView.nextImageView.isHidden = true
                break
                
            case .choosePlanDefault, .gymWorkoutPlan, .homeWorkoutPlan:
                print("choosePlanDefault")
                break
            }
            
            //             shapeView.trainerTags = ["Cardio", "t2", "+5",]
            //            shapeView.timingTxt = (title: "Timing", value: "10:00 to 11:00")
            //            shapeView.locationTxt = (title: "Location", value: "Dubia Location")
            //            shapeView.trainerDetailTitleLabel.text = "Trainer Details"
            //            shapeView.trainerNameLabel.text = "Christene De Koning"
            //            shapeView.qrCodeImageView.image = UIImage(named: "ic_QR_Code")
            //            shapeView.footerLabel.text = "Scan the QR code to access the gym premises."
            //            shapeView.trainerImageView.image = UIImage(named: "ic_trainer")
            //            shapeView.isDirection = true
            //            shapeView.locBtn.setTitle("Get Direction", for: .normal)
            //            shapeView.locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
            //            shapeView.trainerImageView.image = UIImage(named: "ic_trainer")
            /*
             shapeView.packageTitleLabel.text = "Package"
             shapeView.packageLabel.text = "12 months, Elite Gym Membership"
             shapeView.trainerTags = ["Cardio", "t2", "+5",]
             shapeView.startDate = (title: "Start Date", value: "06/24")
             shapeView.validUptoDate = (title: "Valid Upto", value: "06/25")
             shapeView.timingTxt = (title: "Timing", value: "10:00 to 11:00")
             shapeView.locationTxt = (title: "Location", value: "Dubia Location")
             shapeView.trainerDetailTitleLabel.text = "Trainer Details"
             shapeView.trainerNameLabel.text = "Christene De Koning"
             shapeView.qrCodeImageView.image = UIImage(named: "ic_QR_Code")
             shapeView.footerLabel.text = "Scan the QR code to access the gym premises."
             shapeView.trainerImageView.image = UIImage(named: "ic_trainer")
             shapeView.isDirection = true
             shapeView.locBtn.setTitle("Get Direction", for: .normal)
             shapeView.locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
             */
            
            self.view.setNeedsLayout()
        }
        
        self.billMBV.applyTransition(type: .moveIn, subtype: .fromBottom, duration: 1.5, timingFunction: .easeInEaseOut, completion: {
            //----
            print("Bottom animation is done.....")
        })
    }
    
    private func setUpUI(){
        DispatchQueue.main.async {
            self.backToHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.confirmationMBV.roundSideCorners(radius: 12, cornerSide: [.bottomLeft, .bottomRight])
            self.mainStckView.roundSideCorners(radius: 12, cornerSide: [.bottomLeft, .bottomRight])
        }
        
        //------------------*************************
        self.confirmationMBV.applyTransition(type: .moveIn, subtype: .fromTop, duration: 1, timingFunction: .easeInEaseOut, completion: {
            //----
            self.shoBillMBVHeightConstrnt.constant = 0
            self.shoBillMBV.isHidden = false
            self.backToHomeBtn.isHidden = false
            self.confirmationMBV.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.white.withAlphaComponent(0.7), shadowRadius: 5, opacity: 0.7, offset: CGSize(width: 0, height: 30), cornerRadius: 12)
            self.confirmationMBV.roundSideCorners(radius: 20, cornerSide: [.bottomLeft, .bottomRight])
            self.mainStckView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.white.withAlphaComponent(0.7), shadowRadius: 5, opacity: 0.7, offset: CGSize(width: 0, height: 30), cornerRadius: 12)
            self.loadVideo()
            self.billView()
        })
    }
    
    private func loadVideo() {
        // Prevent background music from stopping
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        // Load the video file
        guard let path = Bundle.main.path(forResource: "billing-paper-ticket-machine", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        let asset = AVAsset(url: NSURL(fileURLWithPath: path) as URL)
        let playerItem = AVPlayerItem(asset: asset)
        // Disable all audio tracks in the player item
        for itemTrack in playerItem.tracks {
            if itemTrack.assetTrack?.mediaType == .audio {
                itemTrack.isEnabled = false
            }
        }
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.zPosition = -1
        self.view.layer.addSublayer(playerLayer)
        player.seek(to: .zero)
        player.play()
    }
}
