//
//  ViewStoryVC.swift
//  MyPT
//
//  Created by Radha Yadav on 17/02/26.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class ViewStoryVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var storyBars: StoryBarsNew!
    @IBOutlet weak var imgUserDP: UIImageView!
    @IBOutlet weak var lblYourStory: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imgMyStory: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    
    // Variables
    var currentStoryIndex = 0
    var numberOfStories = 0
    var storyOrOptionIsDisplayed = false
    var backgroundPlay = false
    var currStories : [Story]?
    var userImage: UIImage?
    var userName: String?
    var currentlyStoryIsVisible = false
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    let storyDefaultTimeDuration : Double = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyBarSetup()
        setupUi()
        if let image = userImage {
            self.imgUserDP.image = image
        }
        if let name = userName {
            self.lblYourStory.text = name
        }
        // 🔥 Yaha lagao
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc func handleInterruption(notification: Notification) {

        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            // 🔴 Call aayi, Siri aayi → Pause
            player?.pause()
            storyBars.stop()
        }

        if type == .ended {
            // 🟢 Interruption khatam
            if currentlyStoryIsVisible {
                player?.play()
                storyBars.start()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentlyStoryIsVisible = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        currentlyStoryIsVisible = false
        videoAndBars(state: false)

        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
    }
    
    
    
//    override func viewDidDisappear(_ animated: Bool) {
//        videoAndBars(state: false)
//        currentlyStoryIsVisible = false
//        storyBars.removeAllLayers()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        if backgroundPlay == true{
        //            self.backgroundPlay = false
        //            if storyOrOptionIsDisplayed == false{
        //                videoAndBars(state: true)
        //
        //            }
        //            storyBars.goingInBackGround = false
        //        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUi(){
        if let count = self.currStories?.count{
            self.numberOfStories = count
        } else {
            self.navigationController?.popViewController(animated: false)
        }
        imgUserDP.layer.cornerRadius = imgUserDP.bounds.height / 2
        lblYourStory.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.setImageOrVideo()
        //        playerViewController.videoGravity = .resizeAspectFill
        //        playerViewController.showsPlaybackControls = false
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognizer))
        self.view.addGestureRecognizer(longPress)
        btnNext.isExclusiveTouch = true
        btnPrevious.isExclusiveTouch = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    // Handling when user swipe down
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
                self.videoAndBars(state: false)
                self.userDataShow(state: false)
                self.navigationController?.popViewController(animated: false)
                break
            default:
                break
            }
        }
    }
    
    // Handling if user long press on screen
    @objc func longPressRecognizer(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began{
            // Long press in case of Image
            self.videoAndBars(state: false)
            self.userDataShow(state: false)
        } else if sender.state == UIGestureRecognizer.State.ended{
            // Long press in case of Image
            self.videoAndBars(state: true)
            self.userDataShow(state: true)
        }
    }
    
    @objc func appDidEnterBackground() {
        videoAndBars(state: false)
        backgroundPlay = true
    }
    
    @objc func appWillEnterForeground() {

        guard currentlyStoryIsVisible == true else { return }

        if backgroundPlay == true {
            backgroundPlay = false
            
            // 🔥 DO NOT AUTO PLAY
            // Sirf resume kare agar manually play karna ho
        }
    }
    
//    @objc func appDidEnterBackground() {
//        // Called when the app enters the background
//        currentlyStoryIsVisible = true
//        videoAndBars(state: false)
//        self.backgroundPlay = true
//    }
    
//    @objc func appWillEnterForeground() {
//        // Called when the app is about to enter the foreground
//        // Add your code here
//        if currentlyStoryIsVisible == true{
//            if backgroundPlay == true{
//                self.backgroundPlay = false
//                if storyOrOptionIsDisplayed == false{
//                    videoAndBars(state: true)
//                }
//            }
//            currentlyStoryIsVisible = false
//        }
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func storyBarSetup(){
        if let count = self.currStories?.count{
            storyBars.numberOfStories = count
        } else {
            self.navigationController?.popViewController(animated: false)
        }
        storyBars.storyDuration = storyDefaultTimeDuration
        storyBars.emptyColor = .white.withAlphaComponent(0.5)
        storyBars.fullColor = .white
        storyBars.backgroundColor = .clear
        storyBars.storyEndAction = { newStoryIndex in
            self.currentStoryIndex += 1
            self.nextStoryFunction()
        }
        storyBars.doneAction = {
            self.navigationController?.popViewController(animated: false)
        }
        storyBars.horizontalMargins = 0
        storyBars.interItemSpacing = 6
    }
    //MARK: For stopBars and video pause or play
    func videoAndBars(state : Bool){
        if state == true{
            storyBars.start()
            if videoPlayerView.isHidden == false{
                if let currPlayer = player{
                    currPlayer.play()
                }
            }
            
        } else {
            storyBars.stop()
            if videoPlayerView.isHidden == false{
                if let currPlayer = player{
                    currPlayer.pause()
                }
            }
            
        }
    }
    
    func userDataShow(state : Bool){
        if state == true{
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak self] in
                self?.imgUserDP.alpha = 1
                self?.lblYourStory.alpha = 1
                self?.storyBars.alpha = 1
            }
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak self] in
                self?.imgUserDP.alpha = 0
                self?.lblYourStory.alpha = 0
                self?.storyBars.alpha = 0
            }
        }
    }
    // to turn off button touches
    func offButtonTouch() {
        btnNext.isUserInteractionEnabled = false
        btnPrevious.isUserInteractionEnabled = false
    }
    // to turn on button touches
    func onButtonTouch(){
        btnNext.isUserInteractionEnabled = true
        btnPrevious.isUserInteractionEnabled = true
    }
    
    //MARK: Next and previous button calls
    @IBAction func storyAction(_ sender: UIButton) {
        offButtonTouch()
        if sender.tag == 0 {
            if self.currentStoryIndex == 0{
                
            } else {
                previousStory()
            }
        } else if sender.tag == 1 {
            storyBars.next()
            self.currentStoryIndex += 1
            nextStoryFunction()
        }
        onButtonTouch()
    }
    
    
    //MARK: For previous story functionality
    func previousStory() {
        self.videoAndBars(state: false)
        playerLayer?.removeFromSuperlayer()
        if currentStoryIndex != 0 {
            currentStoryIndex -= 1
            self.setImageOrVideo()
            storyBars.previous()
        } else {
            return
        }
    }
    
    //MARK: For next Story Functionality
    func nextStoryFunction(){
        self.videoAndBars(state: false)
        playerLayer?.removeFromSuperlayer()
        if self.currentStoryIndex == numberOfStories{
            self.navigationController?.popViewController(animated: false)
        } else if currentStoryIndex < numberOfStories{
            self.setImageOrVideo()
        } else {
            self.navigationController?.popViewController(animated: false)
            return
        }
    }
    
    func setImageOrVideo(){
        if !Connectivity.isConnectedToInternet {   // no internet connection
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.ckeck_network, completion: { value in
                self.navigationController?.popViewController(animated: true)
            })
            return
        }
        if self.currStories?[self.currentStoryIndex].type == "image"{
            //                self.videoAndBars(state: true)
            self.videoPlayerView.isHidden = true
            self.imgMyStory.isHidden = false
            if let imgUrl = self.currStories?[self.currentStoryIndex].mediaPath{
                storyBars.currentStoryDuration = storyDefaultTimeDuration
                self.imgMyStory.sd_setImage(with: URL(string: imgUrl)) {
                    image , error, _ , _ in
                    if image != nil{
                        self.videoAndBars(state: true)
                    }
                    if error != nil{
                        if !Connectivity.isConnectedToInternet{   // no internet connection
                            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.ckeck_network, completion: { value in
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                }
            }
        } else {
            self.imgMyStory.isHidden = true
            self.videoPlayerView.isHidden = false
            if let videoUrl = self.currStories?[self.currentStoryIndex].mediaPath{
                if let url = URL(string: videoUrl){
                    player = AVPlayer(url: url)
                    playerLayer = AVPlayerLayer(player: player)
                    playerLayer?.frame = self.view.bounds
                    if let currLayer = playerLayer{
                        self.videoPlayerView.layer.addSublayer(currLayer)
                    }
                    if let currPlayer = player{
                        if let duration = currPlayer.currentItem?.asset.duration{
                            let seconds = CMTimeGetSeconds(duration)
                            storyBars.currentStoryDuration = seconds
                        }
                    }
                    if Connectivity.isConnectedToInternet {
                        self.videoAndBars(state: true)
                    } else {
                        AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.ckeck_network, completion: { value in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }
        }
    }
}
