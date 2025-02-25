//
//  PaymentSuccessViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/11/24.
//

import UIKit
import AVKit
import AVFoundation

class PaymentSuccessViewController: UIViewController {
    
    //MARK: ------------- VARIABLE
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var bckViewHeightContsntrnt: NSLayoutConstraint!
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var mainStckView: UIStackView!
    @IBOutlet weak var confirmationMBV: UIView!
    @IBOutlet weak var shoBillMBV: UIView!
//    @IBOutlet weak var billTopShadowV: UIView!
    @IBOutlet weak var successImgView: UIImageView!
    @IBOutlet weak var confirmationTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var backToHomeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        confirmationMBV.isHidden = true
        self.shoBillMBV.isHidden = false
        self.billView()
//        self.billingTestView()
        setUpUI()
        
        self.navigationItem.hidesBackButton = true
        self.backToHomeBtn.isHidden = true
    }
    
    func setUpUI(){
    
        DispatchQueue.main.async {
        
            self.backToHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                       
//            self.confirmationMBV.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.white.withAlphaComponent(0.2), shadowRadius: 5, opacity: 0.7, offset: CGSize(width: 0, height: 20), cornerRadius: 12)
        }
    }
    
    func billingTestView(){
              
        DispatchQueue.main.async {
            let shapeView = BillingView()
            shapeView.frame = CGRect(x: 0, y: 0, width: self.shoBillMBV.bounds.width, height: 550)//self.shoBillMBV.bounds.height //550
//            shapeView.circleYPosition = (shapeView.bounds.height) / 2.0 + 30.0  // Adjust as needed
            shapeView.layer.shadowColor = UIColor.black.cgColor
            shapeView.layer.shadowOpacity = 0.3
            shapeView.layer.shadowOffset = CGSize(width: 0, height: 2)
            shapeView.layer.shadowRadius = 4
            shapeView.backgroundColor = .clear
//            shapeView.billBackgroundColor = UIColor.appWhite
//            shapeView.lineBgColor = UIColor.appDarkGray
            self.shoBillMBV.addSubview(shapeView)
//            shapeView.cornerSize = CGSize(width: 24, height: 24)
//            shapeView.cornerSide = [.bottomLeft, .bottomRight]
//            shapeView.packageLabel.text = "test"
//            shapeView.trainerTags = ["Cardio", "Pilates", "+3",]
//            shapeView.startDate = (title: "Start Date", value: "06/24")
//            shapeView.validUptoDate = (title: "Valid Upto", value: "06/25")
//            shapeView.timingTxt = (title: "Timing", value: "10:00 to 11:00")
//            shapeView.locationTxt = (title: "Location", value: "MyPT Dubai")
//            
            
//            shapeView.startAnimation()
//            shapeView.startAnimation(){
////                shapeView.animTopBottom(duration: 0.8, delay: 0.1) {
////                    print("animted done..")
////                }
//               print("animation done. ")
//                self.loadVideo()
//                self.backToHomeBtn.isHidden = false
//                
////                shapeView.frame = CGRect(x: 0, y: 0, width: self.shoBillMBV.bounds.width, height: 750)
//            }
            
//            shapeView.configure(title: "Booking Confirmed", description: "You have received a confirmation email.", imageName: "ic_success")
        }
    }
    
    
    func billView(){
        
        
        // Create and configure ShapeView
//        self.shoBillMBV.isHidden = false
        
//        // Optionally rearrange or shift existing views (if necessary)
//           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//               UIView.animate(withDuration: 0.5) {
//                   self.shoBillMBV.isHidden = false
//                   self.shoBillMBV.frame.size.height = 450
//                   
////                   self.stackView.arrangedSubviews.forEach { view in
////                       view.transform = CGAffineTransform(translationX: 0, y: -50)
////                   }
//               }
//           }
        
      
        DispatchQueue.main.async {
            let shapeView = BillShape()
            shapeView.frame = CGRect(x: 0, y: 0, width: self.shoBillMBV.bounds.width, height: 550)//self.shoBillMBV.bounds.height //550
            shapeView.circleYPosition = (shapeView.bounds.height) / 2.0 + 30.0  // Adjust as needed
            shapeView.layer.shadowColor = UIColor.black.cgColor
            shapeView.layer.shadowOpacity = 0.3
            shapeView.layer.shadowOffset = CGSize(width: 0, height: 2)
            shapeView.layer.shadowRadius = 4
            shapeView.backgroundColor = .clear
            shapeView.billBackgroundColor = UIColor.appWhite
            shapeView.lineBgColor = UIColor.appDarkGray
            self.shoBillMBV.addSubview(shapeView)
            shapeView.cornerSize = CGSize(width: 24, height: 24)
            shapeView.cornerSide = [.bottomLeft, .bottomRight]
            shapeView.packageLabel.text = "test"
            shapeView.trainerTags = ["Cardio", "Pilates", "+3",]
            shapeView.startDate = (title: "Start Date", value: "06/24")
            shapeView.validUptoDate = (title: "Valid Upto", value: "06/25")
            shapeView.timingTxt = (title: "Timing", value: "10:00 to 11:00")
            shapeView.locationTxt = (title: "Location", value: "MyPT Dubai")
            
            
//            shapeView.startAnimation()
            shapeView.startAnimation(){
//                shapeView.animTopBottom(duration: 0.8, delay: 0.1) {
//                    print("animted done..")
//                }
               print("animation done. ")
                self.loadVideo()
                self.backToHomeBtn.isHidden = false
                
//                shapeView.frame = CGRect(x: 0, y: 0, width: self.shoBillMBV.bounds.width, height: 750)
            }
            
            shapeView.configure(title: "Booking Confirmed", description: "You have received a confirmation email.", imageName: "ic_success")
            
            

            
//            let topView = UIView(frame: CGRect(x: 0, y: 0, width: self.shoBillMBV.bounds.width, height: 40))
//            topView.backgroundColor = UIColor.mainBg
//            shapeView.addSubview(topView)
           
//            shapeView.topView.roundSideCorners(radius: 12.0, cornerSide: [.bottomLeft, .bottomRight])
//            shapeView.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.red, shadowRadius: 5, opacity: 1.0, offset: CGSize(width: 0, height: 10), cornerRadius: 10)
          
        }
    }
    
    @IBAction func backToHomeBtnActn(_ sender: Any) {
        print("clicked at back to home btn")
        
        self.navigationController?.popToViewController(ofClass: DashboardGuestViewController.self, animated: true)
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

    
    
//    func applyMaskAndShadow(to myView: UIView) {
//           let mask = CAShapeLayer()
//           
//           // Create rounded corner path
//           let shadowpath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: myView.frame.width, height: myView.frame.height),
//                                         byRoundingCorners: [.topRight, .bottomRight],
//                                         cornerRadii: CGSize(width: 58.0, height: 58.0))
//           
//           // Apply mask
//           mask.path = shadowpath.cgPath
//           myView.layer.mask = mask
//           
//           // Create shadow layer
//           let shadowLayer = CAShapeLayer()
//           shadowLayer.frame = myView.bounds
//           shadowLayer.path = shadowpath.cgPath
//           shadowLayer.shadowOpacity = 0.5
//           shadowLayer.shadowRadius = 5
//           shadowLayer.shadowColor = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0).cgColor
//           shadowLayer.masksToBounds = false
//           shadowLayer.shadowOffset = CGSize(width: 5.0, height: 1.0)
//           
//           // Add shadow layer to myView
//           myView.layer.addSublayer(shadowLayer)
//       }
    
}
