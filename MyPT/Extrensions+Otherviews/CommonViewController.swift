//
//  CommonViewController.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit

class CommonViewController: UIViewController {
    
    var progressLayer:CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.statusBarColor(setColor: .clear)
        self.setupLargeTitleBg(bgColor: .clear)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func customBlurViewShow(viewShow:UIView?, alphBlur:Float = 0.2, bgColor:UIColor = .mainBg){
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = view.bounds
        blurView.backgroundColor = bgColor
        blurView.alpha = 0.2
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewShow?.insertSubview(blurView, at: 1)
    }
    
    
    func customBlurViewKeyboardWillHide(viewShow:UIView?){
        viewShow?.subviews.forEach { view in
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification:
                                Notification) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = view.bounds
        blurView.backgroundColor = .mainBg
        blurView.alpha = 0.2
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.subviews.forEach { view in
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.statusBarColor(setColor: .clear)
    }
    
    //MARK: ---------------- Make progressview at nav
    //background: rgba(249, 199, 141, 1);
    
    func setupNavigationBarProgress(progressBarWidth:CGFloat = 120.0,setTintColor : UIColor = UIColor.appDarkGray, settrackTintColor:UIColor = UIColor.appColor(.trackLineColor) ?? .gray, progressBarHeight: CGFloat = 4.0 ) {
        
        self.progressLayer?.removeFromSuperlayer()
        let progressLayer = CAShapeLayer()
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: progressBarHeight / 2)
        let endPoint = CGPoint(x: progressBarWidth, y: progressBarHeight / 2)
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        // Configure the progress layer
        progressLayer.path = path.cgPath
        progressLayer.fillColor = setTintColor.cgColor      // Background color of the progress bar
        progressLayer.strokeColor = settrackTintColor.cgColor    // Progress bar color
        progressLayer.lineWidth = progressBarHeight
        progressLayer.lineCap = .round;                       // Rounded edges
        progressLayer.strokeEnd = 0.0;                        // Initial progress is 0%
        
        // Create a container view for the progress bar
        let progressContainer = UIView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: progressBarHeight))
        progressContainer.backgroundColor = setTintColor // Background color of the container
        
        // Add the progress layer to the container view
        progressContainer.layer.addSublayer(progressLayer)
        
        // Set the container as the title view to center it
        self.navigationItem.titleView = progressContainer
        
        // Optionally set constraints if using Auto Layout
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressContainer.widthAnchor.constraint(equalToConstant: progressBarWidth), // Set a fixed width
            progressContainer.heightAnchor.constraint(equalToConstant: progressBarHeight) // Set the height of the progress bar
        ])
        self.progressLayer = progressLayer
        
    }
    
    func setProgress(_ progress: CGFloat) {
        // Animate progress change
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25) // Animation duration for smooth effect
        progressLayer?.strokeEnd = progress
        CATransaction.commit()
    }
    
    //MARK: ---------------- SET IMAGE INPLACE OF TOP TITILE
    func setupImageTitileNavBar(setNavImg:UIImage? = nil) {
        self.navigationController?.isNavigationBarHidden = false
        
        let titleImageWidth = self.view.frame.size.width * 0.32
        let titleImageHeight = self.view.frame.size.height * 0.64
        var navigationBarIconimageView = UIImageView()
        
        if #available(iOS 11.0, *) {
            navigationBarIconimageView.widthAnchor.constraint(equalToConstant: titleImageWidth).isActive = true
            navigationBarIconimageView.heightAnchor.constraint(equalToConstant: titleImageHeight).isActive = true
        } else {
            navigationBarIconimageView = UIImageView(frame: CGRect(x: 0, y: 0, width: titleImageWidth, height: titleImageHeight))
        }
        navigationBarIconimageView.contentMode = .scaleAspectFit
        navigationBarIconimageView.image = setNavImg
        self.navigationController?.navigationBar.topItem?.titleView = navigationBarIconimageView
    }
    
    //MARK: ---------------- SET  NAVIGATION TOP TITILE
    func setNavigationTitle(title: String? = nil, color: UIColor? = .black, font: UIFont? = UIFont.boldSystemFont(ofSize: 22.0)) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: (color ?? UIColor.black),
            .font: (font ?? UIFont.boldSystemFont(ofSize: 18))
        ]
        
        self.navigationController?.navigationBar.topItem?.title = title
        
        /*
         guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
         return
         }
         
         guard let navigationController = scene.windows.first?.rootViewController as? UINavigationController else {
         return
         }
         
         navigationController.navigationBar.titleTextAttributes = [
         .foregroundColor: (color ?? UIColor.black),
         .font: (font ?? UIFont.boldSystemFont(ofSize: 18))
         ]
         navigationController.navigationBar.topItem?.title = title
         */
        
    }
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS WITH OPTIONAL TITLE
    func setLeftMenu(leftImgs:[UIImage?] = [nil], setTitle:[String?] = [nil], setTintColor:UIColor? = .appWhite, setTitleColor:UIColor? = .appWhite){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        var backButton:[UIButton] = []
        backButton.removeAll()
        
        var leftBarButtonsArray:[UIBarButtonItem] = []
        leftBarButtonsArray.removeAll()
        
        for imgs in leftImgs.enumerated() {
            let backBtn = UIButton(type: .custom)
            backBtn.setImage(imgs.element, for: .normal)
//                backBtn.setTitle("back", for: .normal)
            backBtn.tintColor = setTintColor
            backBtn.setTitleColor(setTitleColor, for: .normal)
            backBtn.sizeToFit()
            backBtn.tag = imgs.offset
            backBtn.addTarget(self, action: #selector(leftBtnActn(sender: )), for: .touchUpInside)
            
            backButton.append(backBtn)
            
            leftBarButtonsArray.append(UIBarButtonItem(customView: backButton[imgs.offset]))
        }
        
        for titleStr in setTitle.enumerated() {
            if titleStr.offset < leftImgs.count {
                backButton[titleStr.offset].setTitle(titleStr.element, for: .normal)
            }
        }
        
        navigationItem.leftBarButtonItems = leftBarButtonsArray
    }
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS ACTION
    @objc func leftBtnActn(sender:UIButton){
        print("Back Nav Tag",sender.tag)
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: ---------------- SET IMAGE RIGHT MENU BUTTONS WITH OPTIONAL TITLE
    func setRighMenu(rightImgs:[UIImage?] = [nil], setTitle:[String?] = [nil] , setTintColor:UIColor? = .clear, setTitleColor:UIColor? = .black, isRightImg:[Bool?] = [false], spacing: CGFloat = 5.0){
        self.navigationController?.isNavigationBarHidden = false
        
        var rightButton:[UIButton] = []
        rightButton.removeAll()
        var rightBarButtonsArray:[UIBarButtonItem] = []
        rightBarButtonsArray.removeAll()
        
        for imgs in rightImgs.enumerated() {
            let rightBtn = UIButton(type: .custom)
            rightBtn.setImage(imgs.element, for: .normal)
            rightBtn.tintColor = setTintColor
            rightBtn.setTitleColor(setTitleColor, for: .normal)
            
            rightBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
            // Set spacing between image and title
            rightBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
            rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
            
            rightBtn.sizeToFit()
            rightBtn.tag = imgs.offset
            
            rightBtn.addTarget(self, action: #selector(rightBtnActn(sender: )), for: .touchUpInside)
            
            // Adjust content direction if isRightImg[index] is true, else default to left-to-right
            if imgs.offset < isRightImg.count, isRightImg[imgs.offset] ?? false {
                rightBtn.semanticContentAttribute = .forceRightToLeft
                // Set spacing between image and title
                rightBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
                rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
            }
            
            rightButton.append(rightBtn)
            
            rightBarButtonsArray.append(UIBarButtonItem(customView: rightButton[imgs.offset]))
            // Set the image to the right
            
        }
        
        for titleStr in setTitle.enumerated() {
            if titleStr.offset < rightImgs.count {
                rightButton[titleStr.offset].setTitle(titleStr.element, for: .normal)
            }
        }
        
        navigationItem.rightBarButtonItems = rightBarButtonsArray
    }
    
    
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS ACTION
    @objc func rightBtnActn(sender:UIButton){
        print("Back Nav Tag",sender.tag)
    }
    
    func setNavigationColor(setColor colorBG:UIColor? = nil){
        self.navigationController?.navigationBar.backgroundColor = colorBG
    }
    
    
    func statusBarColor(setColor statusbarColor:UIColor? = nil)
    {
        var frameStatus = CGRect()
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: \.isKeyWindow)
            frameStatus = window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        } else {
            frameStatus = UIApplication.shared.statusBarFrame
        }
        
        let statusBarView = UIView(frame: frameStatus)
        statusBarView.backgroundColor = statusbarColor
        view.addSubview(statusBarView)
    }
    
    func showNavigationBar()
    {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func hideNavigationBar()
    {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setTranspertNavigation()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    //MARK: -------------MAKE TRANSPARENT OF LARGE TITLE BACKGROUND/COLOR
    func setupLargeTitleBg(bgColor: UIColor = UIColor.clear){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = bgColor //clear color is make transparent
        navBarAppearance.shadowImage = nil // line
        navBarAppearance.shadowColor = nil // line
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).standardAppearance = navBarAppearance
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).scrollEdgeAppearance = navBarAppearance
    }
}
