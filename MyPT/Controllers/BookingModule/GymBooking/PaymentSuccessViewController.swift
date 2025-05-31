//
//  PaymentSuccessViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/11/24.
//

import UIKit
import AVKit
import AVFoundation

enum BillingFlow {
    case upcomingClass
    case defaultBilling
}

class PaymentSuccessViewController: UIViewController {
    
    //MARK: ------------- VARIABLE
    var billingViewFlow: BillingFlow = .defaultBilling
    
    var bookedDataModel:BookedSlotData? = nil
    var bookedMembership: BookMembershipDataModel? = nil
    var bookClassModel: BookingClassDataModel? = nil
    

    var player: AVAudioPlayer?
    
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
    
    func setUpUI(){
        
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
    
    func billView(){
                
        DispatchQueue.main.async {
            let shapeView = BillShape()
            shapeView.layer.shadowColor = UIColor.black.cgColor
            shapeView.layer.shadowOpacity = 0.3
            shapeView.layer.shadowOffset = CGSize(width: 0, height: 2)
            shapeView.layer.shadowRadius = 4
            shapeView.backgroundColor = .clear
            //     only for testign       shapeView.billBackgroundColor = UIColor.appWhite
            //     only for testign        shapeView.lineBgColor = UIColor.appDarkGray
            self.billMBV.addSubview(shapeView)
            
            self.billMBVHeightConstnt.constant = 700
            
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
            switch self.billingViewFlow {
            case .upcomingClass:
                print("Upcoming classes booking..")
                shapeView.packageTitleLabel.isHidden = true
                shapeView.packageLabel.isHidden = true
                shapeView.topTitleView.isHidden = true
                shapeView.startDate = (title: "Date", value: self.bookClassModel?.date ?? "")
                shapeView.validUptoDate = (title: "", value: "")
                shapeView.timingTxt = (title: "Timing", value: self.bookClassModel?.timing ?? "")
                shapeView.locationTxt = (title: "Location", value: self.bookClassModel?.location ?? "")
                shapeView.trainerDetailTitleLabel.text = "Trainer Details"
                shapeView.trainerNameLabel.text = self.bookClassModel?.trainer?.name
                shapeView.qrCodeImageView.loadImage(urlString: self.bookClassModel?.qr ?? "", placeholder:  nil)
                shapeView.trainerImageView.loadImage(urlString: self.bookClassModel?.trainer?.image, placeholder: nil)
                shapeView.isDirection = true
                shapeView.locBtn.setTitle("Get Direction", for: .normal)
                shapeView.locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
                shapeView.footerLabel.text = "Scan the QR code to access the gym premises."
                
                if self.bookClassModel?.trainer?.isVerified == true {
                    shapeView.trainerBadgeImageView.isHidden = false
                }else{
                    shapeView.trainerBadgeImageView.isHidden = true
                }
                
                if (self.bookClassModel?.trainer?.tags?.count ?? 0) > 3 {
                    var tags:[String] = []
                    
                    for i in 0...1 {
                        tags.append(self.bookClassModel?.trainer?.tags?[i] ?? "")
                    }
                    tags.append("+3")
                    shapeView.trainerTags = tags
                }else{
                    shapeView.trainerTags = self.bookClassModel?.trainer?.tags ?? []
                }
                
                /*
                shapeView.trainerTags = ["Cardio", "t2", "+5",]
                shapeView.startDate = (title: "Date", value: "13th June 24 13th June 24 13th June 24 13th June 24")
//                shapeView.validUptoLabel.isHidden = true
                shapeView.validUptoDate = (title: "", value: "")
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
            
            case .defaultBilling:
                if let getBookedDataModel = self.bookedDataModel{
                    shapeView.packageTitleLabel.text = "Package"
                    shapeView.packageLabel.text = getBookedDataModel.package ?? ""
                    shapeView.startDate = (title: "Start Date", value: getBookedDataModel.date?.startDate ?? "")
                    shapeView.validUptoDate = (title: "Valid Upto", value: getBookedDataModel.date?.validTill ?? "")
                    shapeView.timingTxt = (title: "Timing", value: getBookedDataModel.timing ?? "")
                    shapeView.locationTxt = (title: "Location", value: getBookedDataModel.location ?? "")
                    shapeView.trainerDetailTitleLabel.text = "Trainer Details"
                    shapeView.trainerNameLabel.text = getBookedDataModel.trainer?.name ?? ""
                    shapeView.footerLabel.text = "Scan the QR code to access the gym premises."
                    
                    shapeView.trainerImageView.loadImage(urlString: getBookedDataModel.trainer?.image ?? "", placeholder: UIImage())
                    
                    shapeView.qrCodeImageView.loadImage(urlString: getBookedDataModel.qr ?? "", placeholder:  UIImage(named: ""))
                    
                    shapeView.isDirection = true
                    if appUserDefaults.getGymPackage() == "gym" {
                        shapeView.isDirection = false
                        shapeView.locBtn.setTitle("Get Direction", for: .normal)
                        shapeView.locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
                    }
                    
                    if getBookedDataModel.trainer?.isVerified == true {
                        shapeView.trainerBadgeImageView.isHidden = false
                    }else{
                        shapeView.trainerBadgeImageView.isHidden = true
                    }
                    
                    if (getBookedDataModel.trainer?.tags?.count ?? 0) > 3 {
                        var tags:[String] = []
                        
                        for i in 0...1 {
                            tags.append(getBookedDataModel.trainer?.tags?[i] ?? "")
                        }
                        tags.append("+3")
                        
                        shapeView.trainerTags = tags
                    }else{
                        shapeView.trainerTags = getBookedDataModel.trainer?.tags ?? []
                    }
                } else{
                    shapeView.packageTitleLabel.text = "Package"
                    shapeView.packageLabel.text = self.bookedMembership?.package ?? ""
                    shapeView.startDate = (title: "Start Date", value: self.bookedMembership?.startDate ?? "")
                    shapeView.validUptoDate = (title: "Valid Upto", value: self.bookedMembership?.endDate ?? "")
                    shapeView.timingTxt = (title: "", value: "")
                    shapeView.locationTxt = (title: "Location", value: self.bookedMembership?.location ?? "")
                    shapeView.trainerDetailTitleLabel.text = "Trainer Details"
                    shapeView.trainerNameLabel.text = self.bookedMembership?.studio?.name
                    shapeView.footerLabel.text = "Scan the QR code to access the gym premises."
                    
                    shapeView.trainerImageView.loadImage(urlString: self.bookedMembership?.studio?.profile, placeholder: UIImage())
                    shapeView.qrCodeImageView.loadImage(urlString: self.bookedMembership?.qr, placeholder:  UIImage(named: ""))
                    
                    shapeView.trainerBadgeImageView.isHidden = true
                    
                    shapeView.isDirection = true
                    if appUserDefaults.getGymPackage() == "gym" {
                        shapeView.isDirection = false
                        shapeView.locBtn.setTitle("Get Direction", for: .normal)
                        shapeView.locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
                    }
                           
                    if (self.bookedMembership?.studio?.tags?.count ?? 0) > 3 {
                        var tags:[String] = []
                        
                        for i in 0...1 {
                            tags.append(self.bookedMembership?.studio?.tags?[i] ?? "")
                        }
                        tags.append("+3")
                        
                        shapeView.trainerTags = tags
                    }else{
                        shapeView.trainerTags = self.bookedMembership?.studio?.tags ?? []
                    }
                }
            }
            
    
            
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
