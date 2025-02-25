//
//  WorkoutDuringSessionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 09/01/25.
//

import UIKit
import AVFoundation

enum WorkoutSessionFlow {
    case ActiveSession
    case defaultWorkout
    
}

var globalWorkoutFlow: WorkoutSessionFlow = .defaultWorkout

class WorkoutDuringSessionViewController: CommonViewController {

    //MARK: ----------VARIABLE
    var flowSetWorkout:WorkoutSessionFlow = .defaultWorkout
    
    var player: LoopingPlayer?
    var setsCount:Int = 1 {
        didSet{
            self.setsCountBtn.setTitle("\(setsCount)", for: .normal)
        }
    }
    
    var isBackbend:Bool = false
    
    
    lazy var timer: Timer? = nil
    lazy var timeCouter : Int? = nil {
        didSet{
            if let timeCouter = timeCouter {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.swipeoutMBV2.drawLineProgress(progressfill: Double(timeCouter)/30.0, fillLineColor: UIColor.appRatingYellow, cornerRadius: 12.0)
                    self.restLbl.text = "REST \(timeCouter)s"
                    self.swipeoutMBV2.addSubview(self.restLbl)
                }
            }
            if timeCouter == 30 {
                self.stopTimer()
                self.swipeoutMBV.isHidden = true
                self.swipeoutMBV2.isHidden = true
                self.swipeoutMBV3.isHidden = false
                self.isBackbend = true
                self.setupSlideBtn(swipeView: self.swipeoutMBV3)
                self.player?.pausePlayback()
                self.backWorkoutImgView.isHidden = false
                self.workoutNameLbl.text = "Bent-over Row"
            }
        }
    }
   
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var topVideoStatusMBV: UIView!
    @IBOutlet weak var videoMBV: UIView!
    @IBOutlet weak var videoPlayBtn: UIButton!
    @IBOutlet weak var videoTimingLbl: UILabel!
    @IBOutlet weak var currentlyDoingLbl: UILabel!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var addRepsMBV: UIView!
    @IBOutlet weak var repsScale: UIView!
    @IBOutlet weak var addSetsMBV: UIView!
    @IBOutlet weak var addRepsLbl: UILabel!
    @IBOutlet weak var addSetsLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var setsCountBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var swipeoutMBV: UIView!
    @IBOutlet weak var swipeoutMBV2: UIView!
    @IBOutlet weak var swipeoutMBV3: UIView!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var backWorkoutImgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        self.setupFont()
        self.setUpVideo()
        self.setupScale()
        
        self.backWorkoutImgView.isHidden = true
        self.swipeoutMBV.isHidden = false
        self.swipeoutMBV2.isHidden = true
        self.swipeoutMBV3.isHidden = true
        self.setupSlideBtn(swipeView: self.swipeoutMBV)
        self.setupInputData()
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.pausePlayback()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Active Session"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings,AppImages.sosActive], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 701 {
            print("like btn clicked")
            sender.isSelected = !sender.isSelected
                    
        }else if sender.tag == 702{
            print("minus btn")
            guard setsCount > 1 else {
                return
            }
            setsCount -= 1
        }else if sender.tag == 703{
            print("add btn")
            setsCount += 1
        }
    }
    
    func setupInputData(){
        self.likeBtn.isHidden = true
        self.likeCountLbl.isHidden = true
    }
    
    func setupScale(){
        DispatchQueue.main.async {
            // Add the ruler
            let heightScale = self.repsScale.frame.size.height
            
            let ruler = RulerView(frame: CGRect(x: 10, y: 10, width: self.repsScale.frame.size.width-20, height: heightScale-10))
            ruler.backgroundColor = .clear
            ruler.numberOfTicks = 40
            ruler.tickSpacing = 5
            ruler.majorTickColor = UIColor.txtDarkGray
            ruler.minorTickColor = UIColor.appDarkGray
            ruler.labelColor = UIColor.txtDarkGray
            ruler.selectedTickColor = UIColor.appWhite
            ruler.selectedIndex = 20  // Set the selected tick index
            ruler.labelFontNormal = AppFont.bold.size(10.0, familyName: familyManrope)
            ruler.labelFontSelected = AppFont.bold.size(20.0, familyName: familyManrope)
            self.repsScale.addSubview(ruler)
        }
 
    }
    
    func setupSlideBtn(swipeView: UIView){

        // Create and configure SlideToActionButton
        let slideToActionButton = SlideToActionButton()
        slideToActionButton.titleLabel.text = "Swipe to finish activity"
        slideToActionButton.titleLabel.textColor = UIColor.appWhite
        slideToActionButton.titleLabel.font = AppFont.bold.size(16.0, familyName: familyManrope)
        slideToActionButton.translatesAutoresizingMaskIntoConstraints = false
        slideToActionButton.delegate = self
        slideToActionButton.handleViewImage.image = UIImage(named: "ic_swipeActivity")
        slideToActionButton.handleView.backgroundColor = UIColor.appWhite
        slideToActionButton.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255, alpha: 1.0)
        
        // Add SlideToActionButton to the view
        swipeView.addSubview(slideToActionButton)
        
        // Set constraints for SlideToActionButton
        NSLayoutConstraint.activate([
            slideToActionButton.leadingAnchor.constraint(equalTo: swipeView.leadingAnchor, constant: 1),
            slideToActionButton.trailingAnchor.constraint(equalTo: swipeView.trailingAnchor, constant: -1),
            slideToActionButton.centerYAnchor.constraint(equalTo: swipeView.centerYAnchor),
            slideToActionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
//    func setupSlideBtn(){
//        self.swipeoutMBV.isHidden = false
//        self.swipeoutMBV2.isHidden = true
//        self.swipeoutMBV3.isHidden = true
//        
//        // Create and configure SlideToActionButton
//        let slideToActionButton = SlideToActionButton()
//        slideToActionButton.titleLabel.text = "Swipe to finish activity"
//        slideToActionButton.titleLabel.textColor = UIColor.appWhite
//        slideToActionButton.titleLabel.font = AppFont.bold.size(16.0, familyName: familyManrope)
//        slideToActionButton.translatesAutoresizingMaskIntoConstraints = false
//        slideToActionButton.delegate = self
//        slideToActionButton.handleViewImage.image = UIImage(named: "ic_swipeActivity")
//        slideToActionButton.handleView.backgroundColor = UIColor.appWhite
//        slideToActionButton.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255, alpha: 1.0)
//        
//        // Add SlideToActionButton to the view
//        swipeoutMBV.addSubview(slideToActionButton)
//        
//        // Set constraints for SlideToActionButton
//        NSLayoutConstraint.activate([
//            slideToActionButton.leadingAnchor.constraint(equalTo: swipeoutMBV.leadingAnchor, constant: 1),
//            slideToActionButton.trailingAnchor.constraint(equalTo: swipeoutMBV.trailingAnchor, constant: -1),
//            slideToActionButton.centerYAnchor.constraint(equalTo: swipeoutMBV.centerYAnchor),
//            slideToActionButton.heightAnchor.constraint(equalToConstant: 60)
//        ])
//    }
    
    
    func setUpVideo(){
        if let filePath = Bundle.main.path(forResource: "strenghtWorkoutVideo", ofType: "mp4") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Initialize LoopingPlayer
            player = LoopingPlayer(url: fileURL)
            player?.progressDelegate = self
            
            // Add video layer
            if let player = player {
                let playerLayer = AVPlayerLayer(player: player)
                DispatchQueue.main.async {
                    playerLayer.frame = self.videoMBV.bounds
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    playerLayer.zPosition = -1
                    self.videoMBV.layer.addSublayer(playerLayer)
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
    
    func setupUI(){
        DispatchQueue.main.async {
//            self.topVideoStatusMBV.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor.mainBg, offSet: CGSize(width: 10.0, height: 10.0), opacity: 0.8, shadowRadius: 0.5, cornerRadious: 0)
           
            self.videoMBV.addBlurView(viewShow: self.videoMBV, alphBlur: 0.7, bgColor: UIColor.mainBg)
            self.videoPlayBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.videoPlayBtn.frame.size.height/2.0)
            
            [self.swipeoutMBV, self.swipeoutMBV2, self.swipeoutMBV3].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
           
            self.addRepsMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.addSetsMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
       
            self.topVideoStatusMBV.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.mainBg.withAlphaComponent(0.7), shadowRadius: 3.0, opacity: 1.0, offset:  CGSize(width: 0, height: 20), cornerRadius: 1.0)
//            self.topVideoStatusMBV.addBlurView(viewShow: self.videoMBV, alphBlur: 0.7, bgColor: UIColor.mainBg)
        }
    }
    
    func setupFont(){
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.ExtraBold.size(24.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.ExtraBold.size(22.0, familyName: familyManrope),
            .foregroundColor: UIColor.txtDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "112",
            NSAttributedString(string: "bpm",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.likeCountLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
        
        //---------------------*****************
        self.videoTimingLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.currentlyDoingLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
//        self.likeCountLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.addRepsLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.addSetsLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.setsCountBtn.titleLabel?.font = AppFont.bold.size(30.0, familyName: familyManrope)
        self.restLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //=============**********
    //MARK: --------------------Timer
    func startTimer() {
        self.stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
    }
        
    @objc func getTime() {
        //            print("Timer",timer?.timeInterval as Any)
        if let timeCouter = self.timeCouter {
            self.timeCouter! += 1
        }else{
            print("Timer",timer?.timeInterval as Any)
            self.timeCouter = 1
        }
        
    }
    
    func stopTimer() {
        timeCouter = nil
        timer?.invalidate()
        timer = nil
    }
}


extension WorkoutDuringSessionViewController:LoopingPlayerProgressDelegate {
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}


extension WorkoutDuringSessionViewController: SlideToActionButtonDelegate{
    
    // MARK: - SlideToActionButtonDelegate
      func didFinish() {
          print("Action Completed")
          if !isBackbend {
              self.swipeoutMBV.isHidden = true
              self.swipeoutMBV2.isHidden = false
              self.swipeoutMBV3.isHidden = true
              self.startTimer()
          }else{
              print(" back bend over.....")
              
              //-----------------Flow Setup
              
              switch flowSetWorkout {
                  
              case .ActiveSession:
                  globalWorkoutFlow = .ActiveSession
                  self.navigationController?.popViewController(animated: true)
                  
//                  let vc:ActiveUpcomingSessionViewController = ActiveUpcomingSessionViewController.instantiate(appStoryboard: .library)
//                  self.navigationController?.pushViewController(vc, animated: true)
              case .defaultWorkout:
                  let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
                  self.navigationController?.pushViewController(vc, animated: true)
              }
          }
      }
}


