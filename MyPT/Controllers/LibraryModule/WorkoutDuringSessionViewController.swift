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
    let restTimePicker = RestTimePickerView()
    var flowSetWorkout:WorkoutSessionFlow = .defaultWorkout
    private var WorkoutExerciseDetails: [WorkoutExerciseModel]? = []
    var workoutData: WorkoutDetailDataModel?
    private var lastWorkoutExerciseID: String?
    //    var player: LoopingPlayer?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var setsCount:Int = 1 {
        didSet{
            self.setsCountBtn.setTitle("\(setsCount)", for: .normal)
        }
    }
    
    var isBackbend:Bool = false
    private var totalRestCount: Double = 0.0
    var sessionId: Int?
    //    var vidoPlayProgressBar: CustomProgressBar?
    lazy var percentCompleteWorkout: Double = 0.0 {
        didSet{
            self.videoTimingLbl.text = "\(Int(percentCompleteWorkout)) percent complete"
            self.vidoPlayProgressBar.progress = percentCompleteWorkout / 100.0
        }
    }
    
    lazy var timer: Timer? = nil
    lazy var timeCouter : Double? = nil {
        didSet{
            if let timeCouter = timeCouter {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    rgba(246, 170, 84, 1)
                    self.swipeoutMBV2.drawLineProgress(progressfill: timeCouter/self.totalRestCount, fillLineColor: UIColor(red: 246.0/255.0, green: 170.0/255.0, blue: 84.0/255.0, alpha: 1.0), cornerRadius: 12.0)
                    self.restLbl.text = "REST \(timeCouter)S"
                    self.swipeoutMBV2.addSubview(self.restLbl)
                }
            }
            
            if timeCouter == totalRestCount {
                if let _ = self.WorkoutExerciseDetails {
                    self.checkCompletedExercise()
                }else{
                    self.stopTimer()
                    self.swipeoutMBV.isHidden = true
                    self.swipeoutMBV2.isHidden = true
                    self.swipeoutMBV3.isHidden = false
                    self.isBackbend = true
                    self.setupSlideBtn(swipeView: self.swipeoutMBV3)
                    //                    self.player?.pausePlayback()
                    self.player?.pause()
                    self.backWorkoutImgView.isHidden = false
                }
                
                /*
                 self.stopTimer()
                 self.swipeoutMBV.isHidden = true
                 self.swipeoutMBV2.isHidden = true
                 self.swipeoutMBV3.isHidden = false
                 self.isBackbend = true
                 self.setupSlideBtn(swipeView: self.swipeoutMBV3)
                 
                 self.player?.pausePlayback()
                 self.backWorkoutImgView.isHidden = false
                 //                self.workoutNameLbl.text = "Bent-over Row"
                 */
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
    @IBOutlet weak var vidoPlayProgressBar: CustomProgressBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        //        self.setUpVideo()
        self.setupScale()
        
        self.minusBtn.isUserInteractionEnabled = false
        self.addBtn.isUserInteractionEnabled = false
        self.backWorkoutImgView.isHidden = true
        self.swipeoutMBV.isHidden = false
        self.swipeoutMBV2.isHidden = true
        self.swipeoutMBV3.isHidden = true
        self.setupSlideBtn(swipeView: self.swipeoutMBV)
        self.setupInputData(workoutExercise: nil)
        self.getWorkoutDetailsApi(id: self.workoutData?.id?.value, type: "pending", workoutType: workoutData?.type?.value)
        
//        self.playerProgresssBck.tintColor = UIColor.appCard.withAlphaComponent(0.3)
        
        self.vidoPlayProgressBar.progersColor = [UIColor(red: 0.0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 1.0).cgColor, UIColor(red: 240.0/255.0, green: 151.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor]
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
        //        self.player?.pausePlayback()
        self.player?.pause()
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
    
    private func reStartExercise(){
        isBackbend = false
        self.swipeoutMBV.isHidden = false
        self.swipeoutMBV2.isHidden = true
        self.swipeoutMBV3.isHidden = true
        self.setupSlideBtn(swipeView: self.swipeoutMBV)
        self.backWorkoutImgView.isHidden = true
    }
    
    private func checkCompletedExercise(){
        if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.isComplete == false }) {
            let getDetailsExercise = WorkoutExerciseDetails?[indx]
            self.setupInputData(workoutExercise: getDetailsExercise)
            
            if let sessionId = self.sessionId {
                WorkoutLibraryVM.exerciseCompleteApi(inputSessionId: "\(sessionId)", workoutExerciseId: self.lastWorkoutExerciseID, inputsetRound: getDetailsExercise?.setRound?.value, completion: {[weak self] getRsesultData in
                    guard let _ = self else { return }
                    print("Exercise completed")
                    
                    if let getData = getRsesultData?["data"] as? [String:Any], let percentageVal = getData["percentage"] {
                        if let val = Double("\(percentageVal)") {  // convert Any to String then to Double
                            self?.percentCompleteWorkout = val
                        } else {
                            self?.percentCompleteWorkout = 0.0
                        }
                    }
                    
                    /*
                     {
                     "status": true,
                     "data": {
                     "exercise_log_id": 508,
                     "exercise_completed": true,
                     "superset_completed": false,
                     "status": "completed",
                     "percentage": 100
                     },
                     "msg": "This set already marked completed"
                     }
                     */
                })
            }
            
            isBackbend = false
            self.swipeoutMBV.isHidden = false
            self.swipeoutMBV2.isHidden = true
            self.swipeoutMBV3.isHidden = true
            self.setupSlideBtn(swipeView: self.swipeoutMBV)
            //            self.setUpVideo()
            //            self.setUpVideo(videoUrl: getDetailsExercise?.video ?? "")
            self.backWorkoutImgView.isHidden = true
            
        }else{
            self.stopTimer()
            self.isBackbend = true
            //            self.player?.pausePlayback()
            player?.pause()
            self.videoPlayBtn.isSelected = true
            
            if let typeExercise = workoutData?.type?.value, typeExercise.lowercased() == "superset".lowercased() || typeExercise.lowercased() == "circuit".lowercased(){
                if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.workoutExerciseID?.value == self.lastWorkoutExerciseID }) {
                    let getDetailsExercise = WorkoutExerciseDetails?[indx]
                    
                    if let sessionId = self.sessionId {
                        WorkoutLibraryVM.exerciseCompleteApi(inputSessionId: "\(sessionId)", workoutExerciseId: self.lastWorkoutExerciseID, inputsetRound: getDetailsExercise?.setRound?.value, completion: {[weak self] getRsesultData in
                            guard let self = self else { return }
                            self.getWorkoutDetailsApi(id: self.workoutData?.id?.value, type: "pending", workoutType: typeExercise)
                            
                            if let getData = getRsesultData?["data"] as? [String:Any], let percentageVal = getData["percentage"] {
                                if let val = Double("\(percentageVal)") {  // convert Any to String then to Double
                                    self.percentCompleteWorkout = val
                                } else {
                                    self.percentCompleteWorkout = 0.0  // fallback if conversion fails
                                }
                            }
                        })
                    }
                }
                
            }else{
                if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.workoutExerciseID?.value == self.lastWorkoutExerciseID }) {
                    let getDetailsExercise = WorkoutExerciseDetails?[indx]
                    
                    if let sessionId = self.sessionId {
                        WorkoutLibraryVM.exerciseCompleteApi(inputSessionId: "\(sessionId)", workoutExerciseId: self.lastWorkoutExerciseID, inputsetRound: getDetailsExercise?.setRound?.value, completion: {[weak self] getRsesultData in
                            guard let self = self else { return }
                            let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
                            vc.workoutData = self.workoutData
                            vc.workoutId = self.workoutData?.id?.value
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                            if let getData = getRsesultData?["data"] as? [String:Any], let percentageVal = getData["percentage"] {
                                if let val = Double("\(percentageVal)") {
                                    self.percentCompleteWorkout = val
                                } else {
                                    self.percentCompleteWorkout = 0.0
                                }
                            }
                        })
                    }
                }
                else{
                    print("Not getting session id")
                }
            }
            
            
            
            /*
             if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.workoutExerciseID?.value == self.lastWorkoutExerciseID }) {
             let getDetailsExercise = WorkoutExerciseDetails?[indx]
             
             if let sessionId = self.sessionId {
             WorkoutLibraryVM.exerciseCompleteApi(inputSessionId: "\(sessionId)", workoutExerciseId: self.lastWorkoutExerciseID, inputsetRound: getDetailsExercise?.setRound?.value, completion: {[weak self] getRsesultData in
             guard let self = self else { return }
             let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
             vc.workoutData = self.workoutData
             vc.workoutId = self.workoutData?.id?.value
             self.navigationController?.pushViewController(vc, animated: true)
             })
             }
             }
             else{
             print("Not getting session id")
             }
             */
            
            print("Stop exercise...")
        }
    }
    
    func setupInputData(workoutExercise: WorkoutExerciseModel?){
        self.likeBtn.isHidden = true
        self.likeCountLbl.isHidden = true
        self.videoTimingLbl.text = ""
                
        self.workoutNameLbl.text = workoutExercise?.name?.value
        if let totalRest = workoutExercise?.totalREST?.value, let restExercise = Double(totalRest) , restExercise > 0 {
            self.totalRestCount = restExercise
        }else{
            self.totalRestCount = 1.0
        }
        
        self.videoPlayBtn.isSelected = true
        player?.pause()
        if let exerciseVideoUrl = workoutExercise?.video {
            self.setUpVideo(videoUrl: exerciseVideoUrl)
        }
        
        //-------------------******************** SETS
        if let setsCount = workoutExercise?.sets?.value {
            self.setsCountBtn.setTitle(setsCount, for: .normal)
        }else{
            self.setsCountBtn.setTitle("3", for: .normal)
        }
        
        //-----------------------********************SETUP REPS
        if let repsCount = workoutExercise?.reps?.value,
           var getRepsCountVal = Int(repsCount),
           let collectionView = self.restTimePicker.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            
            getRepsCountVal -= 1 //bcz of start form 0
            
            DispatchQueue.main.async {
                let itemCount = collectionView.numberOfItems(inSection: 0)
                if getRepsCountVal >= 0 && getRepsCountVal < itemCount {
                    let indexPath = IndexPath(item: getRepsCountVal, section: 0)
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
        
    }
    
    func setupScale(){
        restTimePicker.translatesAutoresizingMaskIntoConstraints = false
        repsScale.addSubview(restTimePicker)
        restTimePicker.isShowScale = true
        restTimePicker.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            restTimePicker.topAnchor.constraint(equalTo: repsScale.topAnchor),
            restTimePicker.bottomAnchor.constraint(equalTo: repsScale.bottomAnchor),
            restTimePicker.leadingAnchor.constraint(equalTo: repsScale.leadingAnchor),
            restTimePicker.trailingAnchor.constraint(equalTo: repsScale.trailingAnchor),
        ])
        
        restTimePicker.selectedValue = { value in
            print("Selected Rest Time: \(value) seconds")
        }
        
        //-----------------------********************

        if let collectionView = self.restTimePicker.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            DispatchQueue.main.async {
                let indexPath = IndexPath(item: 19, section: 0)
                if collectionView.numberOfItems(inSection: 0) > indexPath.item {
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
        
                
        /*
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
         
         */
    }
    
    func setupSlideBtn(swipeView: UIView){
        
        for subview in swipeView.subviews {
            if subview is SlideToActionButton {
                subview.removeFromSuperview()
            }
        }
        
        // Create and configure SlideToActionButton
        let slideToActionButton = SlideToActionButton()
        let btnTitle = "SWIPE TO FINISH ACTIVITY"
        let leftPaddeding = String(repeating: " ", count: 15) + btnTitle
//        slideToActionButton.titleLabel.text = "SWIPE TO FINISH ACTIVITY"
        slideToActionButton.titleLabel.text = "\(leftPaddeding)"
        slideToActionButton.titleLabel.textColor = UIColor.appWhite
        slideToActionButton.titleLabel.font = AppFont.bold.size(16.0, familyName: familyManrope)
        slideToActionButton.translatesAutoresizingMaskIntoConstraints = false
        slideToActionButton.delegate = self
        slideToActionButton.handleViewImage.image = UIImage(named: "ic_swipeActivity")
        slideToActionButton.handleView.backgroundColor = UIColor.appWhite
        slideToActionButton.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255, alpha: 1.0)
        //rgba(246, 170, 84, 1)
        //rgba(246, 170, 84, 1)
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
    
    func setUpVideo(videoUrl: String){
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        // Make sure the URL is valid
        guard let videoURL = URL(string: videoUrl) else {
            print("Invalid video URL")
            return
        }
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Disable all audio tracks
        for itemTrack in playerItem.tracks {
            if itemTrack.assetTrack?.mediaType == .audio {
                itemTrack.isEnabled = false
            }
        }
        
        self.videoPlayBtn.isSelected = false
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        DispatchQueue.main.async {
            self.playerLayer?.frame = self.videoMBV.bounds
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.playerLayer?.zPosition = -1
            
            if let playerLayer = self.playerLayer{
                self.videoMBV.layer.addSublayer(playerLayer)
            }
        }
        player?.seek(to: .zero)
        player?.play()
        
        /*
         // Observe when duration becomes available
         // Observe when duration changes
         playerItem.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
         
         
         // Track playback time every second
         player?.addPeriodicTimeObserver(
         forInterval: CMTime(seconds: 1, preferredTimescale: 600),
         queue: .main
         ) { [weak self] (time: CMTime) in
         
         let current = CMTimeGetSeconds(time)
         let total   = CMTimeGetSeconds(playerItem.duration)
         
         let remaining = max(0, total - current)
         let remainingText = self?.formatTime(seconds: remaining)
         //            let currentText   = self?.formatTime(seconds: current)
         //            let totalText     = self?.formatTime(seconds: total)
         //            print("\(currentText ?? "") / \(totalText ?? "")  → Remaining: \(remainingText ?? "")")
         
         self?.videoTimingLbl.text = "\(remainingText ?? "") remaining"
         //            print("Progerss  ", current / total)
         self?.vidoPlayProgressBar.progress = current / total
         
         if (current / total) == 1.0{
         self?.videoPlayBtn.isSelected = true
         }
         }
         */
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let item = object as? AVPlayerItem {
            let total = CMTimeGetSeconds(item.duration)
            print("Total duration available: \(formatTime(seconds: total))")
        }
    }
    
    func formatTime(seconds: Float64) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else {
            return "00:00"
        }
        
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        
        if mins > 0 && secs > 0 {
            return String(format: "%d min %d sec", mins, secs)
        } else if mins > 0 {
            return String(format: "%d min", mins)
        } else {
            return String(format: "%d sec", secs)
        }
    }
    
    /*
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
     */
    
    private func setupUI(){
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
    
    private func setupFont(){
        
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
        if let _ = self.timeCouter {
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

//MARK: --------------- SlideToActionButtonDelegate
extension WorkoutDuringSessionViewController: SlideToActionButtonDelegate{
    
    // MARK: - SlideToActionButtonDelegate
    func didFinish() {
        print("Action Completed")
        if !isBackbend {
            self.swipeoutMBV.isHidden = true
            self.swipeoutMBV2.isHidden = false
            self.swipeoutMBV3.isHidden = true
            
            if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.isComplete == false }) {
                let getDetailsExercise = WorkoutExerciseDetails?[indx]
                self.WorkoutExerciseDetails?[indx].isComplete = true
                self.lastWorkoutExerciseID = getDetailsExercise?.workoutExerciseID?.value
                self.startTimer()
            }
        }else{
            print(" back bend over.....")
            //-----------------Flow Setup
            switch flowSetWorkout {
                
            case .ActiveSession:
                globalWorkoutFlow = .ActiveSession
                self.navigationController?.popViewController(animated: true)
                
                //                  let vc:ActiveUpcomingSessionViewController = ActiveUpcomingSessionViewController.instantiate(appStoryboard: .library)
                //                  self.navigationController?.pushViewController(vc, animated: true)
                break
            case .defaultWorkout:
                print("None ........")
                //                  let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
                //                  self.navigationController?.pushViewController(vc, animated: true)
                break
            }
        }
    }
}

extension WorkoutDuringSessionViewController{
    private func getWorkoutDetailsApi(id: String?, type: String?, workoutType:String?){
        WorkoutLibraryVM.workoutDetailsApi(inputId: id, inputType: type, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            self.workoutData = nil
            self.workoutData = getResultData.data
            self.WorkoutExerciseDetails?.removeAll()
            self.WorkoutExerciseDetails?.append(contentsOf: getResultData.data?.exercises ?? [])
            
            if let indx = self.WorkoutExerciseDetails?.firstIndex(where: { $0.isComplete == false }) {
                let getDetailsExercise = WorkoutExerciseDetails?[indx]
                self.setupInputData(workoutExercise: getDetailsExercise)
                self.reStartExercise()
            }
            
            //------------ superset / circuit flow
            if let exercises = self.WorkoutExerciseDetails, (exercises.isEmpty || exercises.count == 0), let workoutType = workoutType, workoutType.lowercased() == "superset".lowercased() || workoutType.lowercased() == "circuit".lowercased() {
                if let _ = self.sessionId {
                    let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
                    vc.workoutData = self.workoutData
                    vc.workoutId = self.workoutData?.id?.value
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        })
    }
}
