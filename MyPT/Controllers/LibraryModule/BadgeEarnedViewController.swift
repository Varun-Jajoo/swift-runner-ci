//
//  BadgeEarnedViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/01/25.
//

import UIKit

class BadgeEarnedViewController: CommonViewController {
    
    //MARK: ------------- VARIABLE
    var badgeDayStreaksData: UserDayStreakDataModel?
    var totalBadgesCount: Int? = 6
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var badgeContainerMBV: UIStackView!
    @IBOutlet weak var multipleBadgeEarnedMBV: UIView!
    @IBOutlet weak var badgesCollView: UICollectionView!
    @IBOutlet weak var badgeEarnedMBV: UIView!
    @IBOutlet weak var customPageCtrnl: CustomPageControl!
    @IBOutlet weak var leftPodiumImgView: UIImageView!
    @IBOutlet weak var rightPodiumImgView: UIImageView!
    @IBOutlet weak var maxSetsImgView: UIImageView!
    @IBOutlet weak var badgeEarnedTitleLbl: UILabel!
    @IBOutlet weak var earnedDateTitleLbl: UILabel!
    @IBOutlet weak var maxSetsTitleLbl: UILabel!
    @IBOutlet weak var dayStreakTitleLbl: UILabel!
    //    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var calendarContainView: UIView!
    @IBOutlet weak var calendarDayStreakMBV: UIView!
    @IBOutlet weak var sunSubMBV: UIView!
    @IBOutlet weak var monSubMBV: UIView!
    @IBOutlet weak var tuesSubMBV: UIView!
    @IBOutlet weak var wedSubMBV: UIView!
    @IBOutlet weak var thuSubMBV: UIView!
    @IBOutlet weak var friSubMBV: UIView!
    @IBOutlet weak var satSubMBV: UIView!
    @IBOutlet weak var sunImgView: UIImageView!
    @IBOutlet weak var monImgView: UIImageView!
    @IBOutlet weak var tuesImgView: UIImageView!
    @IBOutlet weak var wedImgView: UIImageView!
    @IBOutlet weak var thuImgView: UIImageView!
    @IBOutlet weak var friImgView: UIImageView!
    @IBOutlet weak var satImgView: UIImageView!
    @IBOutlet weak var sunTitleLbl: UILabel!
    @IBOutlet weak var monTitleLbl: UILabel!
    @IBOutlet weak var tuesTitleLbl: UILabel!
    @IBOutlet weak var wedTitleLbl: UILabel!
    @IBOutlet weak var thuTitleLbl: UILabel!
    @IBOutlet weak var friTitleLbl: UILabel!
    @IBOutlet weak var satTitleLbl: UILabel!
    @IBOutlet weak var sunCountLbl: UILabel!
    @IBOutlet weak var monCountLbl: UILabel!
    @IBOutlet weak var tuesCountLbl: UILabel!
    @IBOutlet weak var wedCountLbl: UILabel!
    @IBOutlet weak var thuCountLbl: UILabel!
    @IBOutlet weak var friCountLbl: UILabel!
    @IBOutlet weak var satCountLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var dayStreakNoteLbl: UILabel!
    @IBOutlet weak var shareAchievementBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.badgeEarnedMBV.isHidden = true
        badgesCollView.register(UINib(nibName: "BadgesEarnedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BadgesEarnedCollectionViewCell")
        self.setupFont()
        self.setupAnimation()
        self.setInputData()
        self.setUpCustomPageControl()
        
        //        self.setUpCustomPageControl()
              
        //        badgesCollView.register(UINib(nibName: "BadgesEarnedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BadgesEarnedCollectionViewCell")
        
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
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.session_Summary], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: LibraryViewController.self)
    }
    
    @IBAction func shareAchievementBtnActn(_ sender: Any) {
        
        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
    }
    
    private func setInputData(){
        
        self.earnedDateTitleLbl.text = "Feb 23, 2025"
        self.maxSetsTitleLbl.text = "Max Sets"
        
        
        let daysImgView: [UIImageView?] = [
            sunImgView, monImgView, tuesImgView,
            wedImgView, thuImgView, friImgView, satImgView
        ]
        
        let dayIndexMap = ["sun": 0, "mon": 1, "tue": 2, "wed": 3, "thu": 4, "fri": 5, "sat": 6]
        
        (badgeDayStreaksData?.weekDays ?? []).forEach { dayStreak in
            guard let day = dayStreak.day?.value?.lowercased(),
                  let index = dayIndexMap[day],
                  let imgView = daysImgView[index],
                  let status = dayStreak.status?.value?.lowercased() else { return }

            if status == "completed" {
                imgView.image = UIImage(named: "ic_checkDay")
            } else if ["today_pending", "not_started", "upcoming"].contains(status) {
                imgView.image = UIImage(named: "ic_circle_gray")
            } else if status == "missed" {
                imgView.image = UIImage(named: "ic_circle_heck_red")
            }
        }
    }
    
    //MARK: --------------SETUP page controll
    func setUpCustomPageControl(){
        self.customPageCtrnl.activeDotSize =  CGSize(width: 50, height: 6)
        self.customPageCtrnl.currentDotColor = UIColor.appWhite
        self.customPageCtrnl.defaultDotColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        //rgba(49, 52, 58, 1)
        if let totalBadgesCount = self.totalBadgesCount {
            self.customPageCtrnl.numberOfPages = totalBadgesCount
        }
        
       /* self.customPageCtrnl.numberOfPages = self.totalBadgesCount  */ // Set the total number of pages
        self.customPageCtrnl.currentPage = 0    // Set the initial page
    }
    
    private func setupAnimation(){
//        self.badgeEarnedMBV.animShow(duration: 0.7, delay: 0.1) {
//            print("anomation done..")
//        }
        
        self.badgeContainerMBV.animShow(duration: 0.7, delay: 0.1) {
            print("anomation done..")
        }
        
        self.earnedDateTitleLbl.animShow(duration: 0.1, delay: 0.7) {
            print("anomation done..")
        }
        self.maxSetsTitleLbl.animShow(duration: 0.1, delay: 0.7) {
            print("anomation done..")
        }
        
        self.calendarContainView.animShow(duration: 0.7, delay: 0.2) {
            print("anomation done..")
        }
        
        //-------------- make it's scroll position
        //when totalBadgesCount is array then totalBadgesCount >= 0 && totalBadgesCount < itemCount
        if let totalBadgesCount = self.totalBadgesCount{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let itemCount = self.badgesCollView.numberOfItems(inSection: 0)
                if totalBadgesCount >= 0 && totalBadgesCount <= itemCount {
                    let indexPath = IndexPath(item: 2, section: 0)
                    self.badgesCollView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.calendarDayStreakMBV.backgroundColor = UIColor.appCard2
            self.calendarDayStreakMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.calendarContainView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            
            self.calendarDayStreakMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 20)
            
            self.calendarDayStreakMBV.setGradientBorder(cornerRadious:20.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            [self.sunSubMBV,
             self.monSubMBV,
             self.tuesSubMBV,
             self.wedSubMBV,
             self.thuSubMBV,
             self.friSubMBV,
             self.satSubMBV].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            })
            
            self.shareAchievementBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.badgeEarnedTitleLbl.font = AppFont.semibold.size(28.0, familyName: familyClashDisplay) //32.0
        self.earnedDateTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.maxSetsTitleLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
    }
    
}


extension BadgeEarnedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.totalBadgesCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BadgesEarnedCollectionViewCell = badgesCollView.dequeueReusableCell(withReuseIdentifier: "BadgesEarnedCollectionViewCell", for: indexPath) as! BadgesEarnedCollectionViewCell
//        DispatchQueue.main.async {
//            cell.badgeImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.badgeImgView.frame.height / 2.0)
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        return CGSize(width: collectionView.frame.width*0.33, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dayStreakCardAnimated(scrollView: scrollView)
        
    }
    
    private func dayStreakCardAnimated(scrollView: UIScrollView) {
        if scrollView == self.badgesCollView {
            let centerX = badgesCollView.bounds.width / 2 + badgesCollView.contentOffset.x
            
            var closestCell: BadgesEarnedCollectionViewCell?
            var minDistance: CGFloat = .greatestFiniteMagnitude
            
            for cell in badgesCollView.visibleCells {
                guard let myCell = cell as? BadgesEarnedCollectionViewCell else { continue }
                
                let convertedFrame = cell.superview?.convert(cell.frame, to: badgesCollView) ?? cell.frame
                let basePosition = convertedFrame.midX
                let distance = abs(centerX - basePosition)
                
                if distance < minDistance {
                    minDistance = distance
                    closestCell = myCell
                }
            }
            
            for cell in badgesCollView.visibleCells {
                guard let myCell = cell as? BadgesEarnedCollectionViewCell else { continue }
                
              
                /*
                if myCell == closestCell {
                    // Center cell → height 0.9, width same
                    myCell.transform = CGAffineTransform(scaleX: 1.3, y: 0.95) //CGAffineTransform(scaleX: 1.3, y: 0.9)
                    myCell.center.y = badgesCollView.bounds.midY
                    myCell.backgroundColor = UIColor.clear
                    myCell.bagdeImgViewTopConstrnt.constant = 1.0
                    myCell.badgeDescMBV.isHidden = false
                    myCell.setBlurred(false)
                    
                    DispatchQueue.main.async {
                        myCell.bagdeImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: myCell.bagdeImgView.frame.size.height/2)
                    }
                    
                } else {
                    // Left/Right → height 0.3, width 0.9 (slightly narrower)
                    myCell.transform = CGAffineTransform(scaleX: 0.75, y: 0.3)
                    
                    // Align top after scaling
                    myCell.center.y = myCell.bounds.height * 0.15  // tweak factor so it sticks to top
                    myCell.backgroundColor = UIColor.clear
                    myCell.bagdeImgViewTopConstrnt.constant = 40.0
                    myCell.badgeDescMBV.isHidden = true
                    
                    myCell.setBlurred(true)
                    
                    DispatchQueue.main.async {
                        myCell.bagdeImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: myCell.bagdeImgView.frame.size.height/2)
                    }
                }
                */
                
                if myCell == closestCell {
                    // Center cell → bigger scale
                    myCell.transform = CGAffineTransform(scaleX: 1.3, y: 0.95)
                    myCell.center.y = badgesCollView.bounds.midY
                    myCell.backgroundColor = .clear
                    myCell.bagdeImgViewTopConstrnt.constant = 1.0
                    myCell.badgeDescMBV.isHidden = false
                    myCell.setBlurred(false)
                    myCell.badgeImgView.makeCircular()

                } else {
                    // Side cells → smaller scale
                    myCell.transform = CGAffineTransform(scaleX: 0.75, y: 0.3)
                    myCell.center.y = myCell.bounds.height * 0.15
                    myCell.backgroundColor = .clear
                    myCell.bagdeImgViewTopConstrnt.constant = 40.0
                    myCell.badgeDescMBV.isHidden = true
                    myCell.setBlurred(true)
                    myCell.badgeImgView.makeCircular()
                }

//                myCell.bagdeImgView.makeCircular()

                
                //---------- For page control
                let centerPoint = CGPoint(x: badgesCollView.bounds.midX + badgesCollView.contentOffset.x,
                                                y: badgesCollView.bounds.midY + badgesCollView.contentOffset.y)
                      
                if let indexPath = badgesCollView.indexPathForItem(at: centerPoint) {
                    self.customPageCtrnl.currentPage = indexPath.row
                }
                
                /*
                if myCell == closestCell {
                    // Center cell → height 0.9, width stays same
                    myCell.transform = CGAffineTransform(scaleX: 1.0, y: 0.9)
                    myCell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    myCell.center.y = badgesCollView.bounds.midY
                    myCell.backgroundColor = UIColor.red
                } else {
                    // Left/Right → height 0.3, aligned top
                    myCell.transform = CGAffineTransform(scaleX: 1.0, y: 0.3)
                    myCell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0) // top anchor
                    myCell.frame.origin.y = 0
                    myCell.backgroundColor = UIColor.yellow
                }
                */
                
            }
        }
    }
    
}


