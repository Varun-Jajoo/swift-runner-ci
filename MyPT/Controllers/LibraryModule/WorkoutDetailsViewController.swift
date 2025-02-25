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
    var workoutData:[Any]?
    var player: LoopingPlayer?
    var workoutNameStr: String?
  
 //MARK: -------------IBOUTLET
    @IBOutlet weak var workoutScrlView: UIScrollView!
    @IBOutlet weak var playVideoMBV: UIView!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var exercisesMBV: UIView!
    @IBOutlet weak var headerMBV: UIView!
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

        // Do any additional setup after loading the view.
        self.workoutTblViewHeightConstrnt.constant = 10.0
        self.headerMBV.isHidden = true

        self.setupFont()
        self.setUpVideo()
        self.setupInoutData()
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
        player?.pausePlayback()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Explore Library"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 801 {
            print("view details clicked..")
            self.detailsBtn.isHidden = true
            self.headerMBV.isHidden = false
            
            self.workoutData = [1,1,1,1,1,1,1]
            self.workoutTblView.reloadData()
            self.bottomTopConstrnt.constant = -40
            let targetViewTop = 150.0 //bottomMBV.frame.origin.y
            //If you have a complicated hierarchy it is better to
            // use someView superview (someView.superview?.frame.origin.y) and figure out your view origin
            let viewToTop = targetViewTop - workoutScrlView.contentInset.top
            self.workoutScrlView.setContentOffset(CGPoint(x: 0, y: viewToTop), animated: true)
        }else{
            print("start clicked..")
            
            let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func setupInoutData(){
        self.workoutNameLbl.text = workoutNameStr
    }
    
    func setupFont(){
        self.workoutTblView.register(UINib(nibName: "WorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutTableViewCell")
        
        //----------------************
        self.workoutNameLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.timeLbl.font = AppFont.medium.size(20.0, familyName: familyManrope)
        self.durationLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.caloriesCountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.calorieLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.exercisesCountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.duraexercisesLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.workoutLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.detailsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.startBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
    }
    
    func setupUI(){
        
        DispatchQueue.main.async {
            
            self.bottomMBV.addBlurView(viewShow: self.bottomMBV, alphBlur: 1.0, bgColor: UIColor.mainBg)
            
            self.detailsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.startBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            [self.durationMBV, self.caloriesMBV, self.exercisesMBV].forEach({
                $0.setCornerRadius(borderWidth: 0.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            })
            
            self.workoutLstMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 0.5, opacity: 0.4, offset: .zero, cornerRadius: 12.0)
            self.workoutLstMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.workoutLstMBV.backgroundColor = UIColor.clear
            
            //------------------Gradient
            
            [self.durationMBV,self.caloriesMBV,self.exercisesMBV].forEach({
                $0.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
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
        
    }
}

//MARK: ---------------EXTENSION FOR UITABLEVIEW
extension WorkoutDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WorkoutTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "WorkoutTableViewCell", for: indexPath) as! WorkoutTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
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


extension WorkoutDetailsViewController:LoopingPlayerProgressDelegate {
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}
