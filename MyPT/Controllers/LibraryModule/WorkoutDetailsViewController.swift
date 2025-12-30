//
//  WorkoutDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 08/01/25.
//

import UIKit
import AVFoundation

class WorkoutDetailsViewController: CommonViewController {
    
    //MARK: ----------VARIABLE
    //    var workoutData:[Any]?
    var player: LoopingPlayer?
    var workoutNameStr: String?
    var workoutId: String?
    var assignmentId: String?
    
    var workoutData: WorkoutDetailDataModel?
    var exercisesData:[WorkoutExerciseModel]? = []
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var workoutScrlView: UIScrollView!
    @IBOutlet weak var playVideoMBV: UIView!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var exercisesMBV: UIView!
    @IBOutlet weak var workoutMBV: UIView!
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var gradientImgView: UIImageView!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var caloriesCountLbl: UILabel!
    @IBOutlet weak var calorieLbl: UILabel!
    @IBOutlet weak var exercisesCountLbl: UILabel!
    @IBOutlet weak var duraexercisesLbl: UILabel!
    @IBOutlet weak var workoutLbl: UILabel!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var workoutTblView: UITableView!
    @IBOutlet weak var workoutTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var bottomMBVTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var workoutLstMBV: UIStackView!
    @IBOutlet weak var bottomTopConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.workoutTblViewHeightConstrnt.constant = 10.0
        self.headerMBV.isHidden = true
        self.workoutMBV.isHidden = true
        
        self.setupFont()
        //        self.setUpVideo()
        self.setupInoutData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        self.setupLargeTitleBg(collapsedColor: UIColor.clear, expandedColor: .clear)
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
        self.setTranspertNavigation()
        
        self.getWorkoutDetailsApi(id: workoutId, type: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setupLargeTitleBg(collapsedColor: UIColor.mainBg, expandedColor: .clear)
        player?.pausePlayback()
    }
    
    func setNavUI(){
        //Workout Library "Explore Library"
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Workout Library"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 801 {
            print("view details clicked..")
            self.detailsBtn.isHidden = true
            self.headerMBV.isHidden = false
            self.workoutMBV.isHidden = false
            
            self.workoutTblView.reloadData()
            self.bottomTopConstrnt.constant = -40
            let targetViewTop = 150.0 //bottomMBV.frame.origin.y
            //If you have a complicated hierarchy it is better to
            // use someView superview (someView.superview?.frame.origin.y) and figure out your view origin
            let viewToTop = targetViewTop - workoutScrlView.contentInset.top
            self.workoutScrlView.setContentOffset(CGPoint(x: 0, y: viewToTop), animated: true)
        }else{
            print("start clicked..")
            if let isExercisesCompleted = workoutData?.isExercisesCompleted, !isExercisesCompleted {
                WorkoutLibraryVM.workoutStartApi(inputId: Int(self.workoutData?.id?.value ?? ""), assignmentId: self.assignmentId, completion: {[weak self] getResultData in
                    guard let self = self else { return  }
                    let getData = getResultData?["data"] as? [String:Any]
                    
                    let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
                    vc.sessionId = getData?["session_id"] as? Int
                    vc.workoutData = self.workoutData
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
            }else{
                let vc:SessionSummaryViewController = SessionSummaryViewController.instantiate(appStoryboard: .library)
                //                vc.workoutData = self.workoutData
                vc.workoutId = self.workoutData?.id?.value
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func setupInoutData(){
        startBtn.setImage(UIImage(named: "ic_timer_start"), for: .normal)
        startBtn.setTitle("START", for: .normal)
        
        self.workoutNameLbl.text = workoutData?.name?.value ?? workoutNameStr
        self.timeLbl.text = " "
        self.caloriesCountLbl.text = " "
        self.exercisesCountLbl.text = " "
        
        if let workoutVideoUrl = workoutData?.workoutVideo {
            self.setUpVideo(videoUrl: workoutVideoUrl)
        }
        
        //--------------Gradient label
        if let timeSec = workoutData?.timeInSeconds?.value {
            self.timeLbl.attributedText = gradientAttr(labl: self.timeLbl, txtStr: timeSec + "s")
        }
        if let caloriesCount = workoutData?.calories?.value {
            self.caloriesCountLbl.attributedText = gradientAttr(labl: self.caloriesCountLbl, txtStr: caloriesCount)
        }
        if let exercisesCount = workoutData?.exercisesCount?.value {
            self.exercisesCountLbl.attributedText = gradientAttr(labl: self.exercisesCountLbl, txtStr: exercisesCount)
        }
        
        if let isExercisesCompleted = workoutData?.isExercisesCompleted, isExercisesCompleted {
            startBtn.setImage(nil, for: .normal)
            startBtn.setTitle("COMPLETE", for: .normal)
        }
    }
    
    func setupFont(){
        self.workoutTblView.register(UINib(nibName: "WorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutTableViewCell")
        
        //----------------************
        self.workoutNameLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        //        self.timeLbl.font = AppFont.medium.size(20.0, familyName: familyManrope)
        self.durationLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        //        self.caloriesCountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.calorieLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        //        self.exercisesCountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.duraexercisesLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.workoutLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.detailsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.startBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        //--------------**********Make Gradient label
        //        self.timeLbl.attributedText = gradientAttr(labl: self.timeLbl, txtStr: "50s")
        //        self.caloriesCountLbl.attributedText = gradientAttr(labl: self.caloriesCountLbl, txtStr: "250")
        //        self.exercisesCountLbl.attributedText = gradientAttr(labl: self.exercisesCountLbl, txtStr: "20")
    }
    
    private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.medium.size(20.0, familyName: familyClashDisplay)) -> NSAttributedString {
        let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
    
    func setupUI(){
        
        DispatchQueue.main.async {
            self.gradientImgView.addGradientImgV(colors: [
                UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8),
                UIColor(red: 0/255.0, green: 3/255.0, blue: 1/255.0, alpha: 0),
                UIColor(red: 0/255.0, green: 5/255.0, blue: 2/255.0, alpha: 1)
            ], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            
            //            self.bottomMBV.addBlurView(viewShow: self.bottomMBV, alphBlur: 1.0, bgColor: UIColor.mainBg)
            
            self.detailsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.startBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            /*
             self.workoutLstMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 0.5, opacity: 0.4, offset: .zero, cornerRadius: 12.0)
             self.workoutLstMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
             self.workoutLstMBV.backgroundColor = UIColor.clear
             */
            
            self.headerMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 0.5, opacity: 0.4, offset: .zero, cornerRadius: 12.0)
            self.headerMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.headerMBV.backgroundColor = UIColor.clear
            
            //------------------Gradient
            [self.durationMBV,self.caloriesMBV,self.exercisesMBV].forEach({
                $0.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if workoutTblView.contentSize.height != 0 {
            self.workoutTblViewHeightConstrnt.constant = self.workoutTblView.contentSize.height
            self.workoutTblView.layoutIfNeeded()
        }
        self.view.layoutIfNeeded()
    }
    
    func setUpVideo(videoUrl: String){
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        // Suppose this comes from your API response
        //        let videoURLString = "https://mobileappuat.mypt-me.com/assets/staticVideo/gym_video.mp4"
        
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
        
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        
        DispatchQueue.main.async {
            playerLayer.frame = self.playVideoMBV.bounds
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.zPosition = -1
            self.playVideoMBV.layer.addSublayer(playerLayer)
        }
        
        player.seek(to: .zero)
        player.play()
        
        
        /*
         if let filePath = Bundle.main.path(forResource: "strenghtWorkoutVideo", ofType: "mp4") {
         let fileURL = URL(fileURLWithPath: filePath)
         // Initialize LoopingPlayer
         player = LoopingPlayer(url: fileURL)
         player?.progressDelegate = self
         
         // Add video layer
         if let player = player {
         let playerLayer = AVPlayerLayer(player: player)
         DispatchQueue.main.async {
         playerLayer.frame = self.playVideoMBV.bounds
         playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
         playerLayer.zPosition = -1
         self.playVideoMBV.layer.addSublayer(playerLayer)
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
         */
    }
}

//MARK: ---------------EXTENSION FOR UITABLEVIEW
extension WorkoutDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercisesData?.count ?? 0 //workoutData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WorkoutTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "WorkoutTableViewCell", for: indexPath) as! WorkoutTableViewCell
        
        DispatchQueue.main.async {
            //            cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 20.0)
            cell.workoutImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            cell.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 20.0)
            
            cell.cellMBV.setGradientCellBorder(cornerRadius: 20.0, width: 1, colors: [
                UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0),
                UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            ], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
        }
        cell.rightImgView.isHidden = true
        cell.repsImgView.isHidden = true
        
        if let typeExercise = workoutData?.type?.value, typeExercise.lowercased() == "superset".lowercased() || typeExercise.lowercased() == "circuit".lowercased(){
            exercisesData?[indexPath.row].type?.value = typeExercise.lowercased()
            cell.setCell(cellData: exercisesData?[indexPath.row])
        }else{
            cell.setCell(cellData: exercisesData?[indexPath.row])
        }
        
        //        cell.setCell(cellData: exercisesData?[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let typeExercise = workoutData?.type?.value, typeExercise.lowercased() != "superset".lowercased() && typeExercise.lowercased() != "circuit".lowercased()  else { return }
        
        if let isComplete = exercisesData?[indexPath.row].isComplete, !isComplete {
            WorkoutLibraryVM.workoutStartApi(inputId: Int(self.workoutData?.id?.value ?? ""), assignmentId: self.assignmentId, completion: {[weak self] getResultData in
                guard let self = self else { return  }
                let getData = getResultData?["data"] as? [String:Any]
                
                let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
                vc.sessionId = getData?["session_id"] as? Int
                vc.workoutData = self.workoutData
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }else{
            print("Not Start exercise.......")
        }
        
        //        let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    
    //-----------------_************
    
    // Called when dragging starts
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Started dragging")
        //        self.setupLargeTitleBg(collapsedColor: UIColor.red, expandedColor: .green)
    }
    
    // Called when dragging ends
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Ended dragging")
    }
    
    // Called when scrolling stops after deceleration
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("ScrollView stopped")
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        return headerMBV
    //    }
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //
    //        return UITableView.automaticDimension
    //
    ////        return 80.0
    //    }
}


extension WorkoutDetailsViewController{
    private func getWorkoutDetailsApi(id: String?, type: String?){
        WorkoutLibraryVM.workoutDetailsApi(inputId: id, inputType: type, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            self.workoutData = nil
            self.workoutData = getResultData.data
            self.exercisesData?.removeAll()
            self.exercisesData?.append(contentsOf: getResultData.data?.exercises ?? [])
            self.workoutTblView.reloadData()
            self.setupInoutData()
        })
    }
}

extension WorkoutDetailsViewController:LoopingPlayerProgressDelegate {
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}
