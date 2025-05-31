//
//  UpcomingClassesViewController.swift
//  MyPT
//
//  Created by techsaga corp on 09/05/25.
//

import UIKit
import AVKit

class UpcomingClassesViewController: CommonViewController {
    
    //MARK: ----------------Variable
    var classeData:UpcomingDataModel?
    var lookCategoryData:[ClassesWithCategoryModel]? = []
    
    
    private var videoUrl: String? {
        didSet {
            guard let videoStr = videoUrl, let videoURL = URL(string: videoStr) else { return }
            
            let player = AVPlayer(url: videoURL)
            let vc = CustomPlayerViewController()
            vc.player = player
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true) {
                player.play()
            }
        }
    }
    
    //MARK: ------------------ IBOUTLET
    @IBOutlet weak var classesNearByMBV: UIView!
    @IBOutlet weak var glimpseClassesMBV: UIView!
    @IBOutlet weak var resourcesMBV: UIView!
    @IBOutlet weak var categoryMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var thoughtsMBV: UIView!
    @IBOutlet weak var footerMBV: UIView!
    @IBOutlet weak var classesNearYouTitleBtn: UIButton!
    @IBOutlet weak var classesNearYouArrowBtn: UIButton!
    @IBOutlet weak var classesNearCollView: UICollectionView!
    @IBOutlet weak var glimpseClassesTitleBtn: UIButton!
    @IBOutlet weak var glimpseClassesArrowBtn: UIButton!
    @IBOutlet weak var glimpseClassesCollView: UICollectionView!
    @IBOutlet weak var resourcesTitleBtn: UIButton!
    @IBOutlet weak var resourcesArrowBtn: UIButton!
    @IBOutlet weak var resourcesCollView: UICollectionView!
    @IBOutlet weak var lookCategoryTitleBtn: UIButton!
    @IBOutlet weak var categoryViewAllBtn: UIButton!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var categoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var thoughtsLbl: UILabel!
    @IBOutlet weak var thoughtsWriterLbl: UILabel!
    @IBOutlet weak var footerImgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.classesNearCollView.isHidden = true
        self.glimpseClassesCollView.isHidden = true
        self.resourcesCollView.isHidden = true
        self.categoryCollView.isHidden = true
        
        self.setupFont()
        self.registerCell()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.upcomingClassesApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.glimpseCardScroll()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Classes"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    enum btnTag: Int {
        case classesNear = 2301, glimpseClasses, resources, lookCategory
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case btnTag.classesNear.rawValue:
            print("classesNear clicked..")
            if let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                let vc: ClassesViewController = ClassesViewController.instantiate(appStoryboard: .dashboard)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
            
        case btnTag.glimpseClasses.rawValue:
            print("glimpseClasses clicked..")
            break
            
        case btnTag.resources.rawValue:
            print("resources clicked..")
            
            let vc: ResourceViewController = ResourceViewController.instantiate(appStoryboard: .dashboard)
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case btnTag.lookCategory.rawValue:
            print("lookCategory clicked..")
            if let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                let vc: ClassCategoryViewController = ClassCategoryViewController.instantiate(appStoryboard: .dashboard)
                vc.classesWithCategoryData = self.classeData?.classesWithCategory
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        default:
            print("None....")
            break
        }
    }
    
    private func registerCell(){
        classesNearCollView.register(UINib(nibName: "UpcomingClassesNearCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingClassesNearCollectionViewCell")
        glimpseClassesCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        resourcesCollView.register(UINib(nibName: "ResourcesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ResourcesCollectionViewCell")
        categoryCollView.register(UINib(nibName: "ClassCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClassCategoryCollectionViewCell")
    }
    
    private func setupFont(){
        
        [
            self.classesNearYouTitleBtn.titleLabel,
            self.glimpseClassesTitleBtn.titleLabel,
            self.resourcesTitleBtn.titleLabel,
            self.lookCategoryTitleBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        self.categoryViewAllBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        self.thoughtsLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.thoughtsWriterLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        
        DispatchQueue.main.async {
            self.lineLbl.backgroundColor = UIColor.clear
            self.lineLbl.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if categoryCollView.contentSize.height != 0 {
            self.categoryCollViewHeightConstrnt.constant = categoryCollView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
    private func glimpseCardScroll(){
        self.glimpseCard(scrollView: glimpseClassesCollView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let allClassVideosCount = self.classeData?.allClassVideos?.count , allClassVideosCount > 1 {
                self.glimpseClassesCollView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}

//MARK: ----------------- COLLECTIONVIE DELEGATE/DATASOURCE
extension UpcomingClassesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == classesNearCollView {
            return collectionView.numberOfRows(count: self.classeData?.allClasses?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 80.0)), messageImageHeight: 80.0, fromTop: 1)
        }
        else if collectionView == glimpseClassesCollView{
            return collectionView.numberOfRows(count: self.classeData?.allClassVideos?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 80.0)), messageImageHeight: 80.0, fromTop: 1)
        }
        else if collectionView == resourcesCollView{
            return collectionView.numberOfRows(count: self.classeData?.resources?.count, title: "No resources found!", message: "", messageImage: UIImage(named: "ic_search_NoResult")?.resized(to: CGSize(width: 80, height: 80)), messageImageHeight: 50, fromCenter: nil, fromTop: 23)
        }
        else{
            return collectionView.numberOfRows(count: self.lookCategoryData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 80.0)), messageImageHeight: 80.0, fromTop: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == classesNearCollView {
            let cell: UpcomingClassesNearCollectionViewCell = classesNearCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingClassesNearCollectionViewCell", for: indexPath) as! UpcomingClassesNearCollectionViewCell
            cell.setCell(cellData: self.classeData?.allClasses?[indexPath.row])
            return cell
        }
        else if collectionView == glimpseClassesCollView{
            let glimpseClassesCell: WithMeCollectionViewCell = glimpseClassesCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            DispatchQueue.main.async {
                glimpseClassesCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                glimpseClassesCell.videoThumbnailImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            
            //            glimpseClassesCell.videoThumbnailImgView.image = UIImage(named: "ic_trainer")
            
            if let getUrl = URL(string: self.classeData?.allClassVideos?[indexPath.row] ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    glimpseClassesCell.videoThumbnailImgView.image = thumbNailImage
                    glimpseClassesCell.centerImgView.isHidden = false
                    glimpseClassesCell.centerImgView.image = UIImage(named: "ic_play_white")
                })
            } else{
                glimpseClassesCell.centerImgView.isHidden = true
            }
            
            return glimpseClassesCell
        }
        else if collectionView == resourcesCollView {
            let resourceCell: ResourcesCollectionViewCell = resourcesCollView.dequeueReusableCell(withReuseIdentifier: "ResourcesCollectionViewCell", for: indexPath) as! ResourcesCollectionViewCell
            
            resourceCell.stckBottomConstrnt.constant = 10.0
            resourceCell.likeBtn.isHidden = true
            resourceCell.ratingBtn.isHidden = true
            resourceCell.dot1Btn.isHidden = true
            resourceCell.dot2Btn.isHidden = true
            resourceCell.likesCountBtn.isHidden = true
            resourceCell.viewsCountBtn.isHidden = true
            
            resourceCell.bckImgView.loadImage(urlString: self.classeData?.resources?[indexPath.row].image, placeholder: nil)
            resourceCell.resourceTitleLbl.text = self.classeData?.resources?[indexPath.row].title
            
            return resourceCell
        }
        else if collectionView == categoryCollView {
            let categoryCell: ClassCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ClassCategoryCollectionViewCell", for: indexPath) as! ClassCategoryCollectionViewCell
            
            categoryCell.setCellData(cellData: self.lookCategoryData?[indexPath.row])
            return categoryCell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == classesNearCollView {
            if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
                vc.scheludeIdStr = "\(self.classeData?.allClasses?[indexPath.row].scheduleID ?? 0)"
                vc.inputLat = lat
                vc.inputLong = long
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if collectionView == resourcesCollView {
            let vc: ResourceDetailsViewController = ResourceDetailsViewController.instantiate(appStoryboard: .dashboard)
            vc.resourceData = self.classeData?.resources?[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == glimpseClassesCollView{
            self.videoUrl = self.classeData?.allClassVideos?[indexPath.row] as? String
        }
        else if collectionView == categoryCollView{
            if let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let _ = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
                let vc: CategoryWiseClassesViewController = CategoryWiseClassesViewController.instantiate(appStoryboard: .dashboard)
                vc.categoryIdStr = "\(lookCategoryData?[indexPath.row].categoryID ?? 0)" //"\(self.classeData?.classesWithCategory?[indexPath.row].categoryID ?? 0)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == classesNearCollView {
            return CGSize(width: collectionView.frame.size.width*0.82, height: 220)
        }
        else if collectionView == glimpseClassesCollView{
            return CGSize(width: collectionView.frame.size.width*0.63, height: collectionView.frame.size.height)
        }
        else if collectionView == resourcesCollView {
            return CGSize(width: collectionView.frame.size.width*0.82, height: 220)
        }
        else if collectionView == categoryCollView {
            return CGSize(width: collectionView.frame.size.width*0.44, height: 190)
        }
        else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == categoryCollView {
            DispatchQueue.main.async {
                self.updateViewConstraints()
            }
        }
    }
    
    //MARK: -----------------USED FOR MAKE CENTER ANUIMATED CELL OF UICOLLECION VIEW
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.glimpseCard(scrollView: scrollView)
    }
    
    private func glimpseCard(scrollView: UIScrollView){
        if scrollView == self.glimpseClassesCollView {
            let centerX = glimpseClassesCollView.bounds.width / 2 + glimpseClassesCollView.contentOffset.x
            
            var maxX: CGFloat = -CGFloat.infinity
            var minX: CGFloat = CGFloat.infinity
            for cell in glimpseClassesCollView.visibleCells {
                guard let myCell = cell as? WithMeCollectionViewCell else { continue }
                
                // Convert to superview to take transformations into account
                let convertedFrame = cell.superview?.convert(cell.frame, to: glimpseClassesCollView) ?? cell.frame
                let basePosition = convertedFrame.midX
                let distance = abs(centerX - basePosition)
                let scale = max(0.8, 1 - distance / glimpseClassesCollView.bounds.width)
                myCell.transform = CGAffineTransform(scaleX: 0.96, y: scale)
                
                // Determine rightmost visible cell
                if convertedFrame.maxX > maxX {
                    maxX = convertedFrame.maxX
                }
                
                // Determine leftmost visible cell
                if convertedFrame.minX < minX {
                    minX = convertedFrame.minX
                }
            }
        }
    }
}


extension UpcomingClassesViewController{
  
    private func upcomingClassesApi(){
        
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            
            let params:[String:String] = [
                "long": long,
                "lat": lat
            ]
            
            UpcomingClassVM.upcomingClassesApi(inputParams: params, isShowLoader: true, completion: {[weak self] resultData in
                guard let self = self else { return }
                
                self.classesNearCollView.isHidden = false
                self.glimpseClassesCollView.isHidden = false
                self.resourcesCollView.isHidden = false
                self.categoryCollView.isHidden = false
                
                self.classeData = resultData?.data
                self.lookCategoryData?.removeAll()
                
                if let _ = self.classeData?.allClasses {
                    self.classesNearCollView.reloadData()
                }
                if let _ = self.classeData?.resources {
                    self.resourcesCollView.reloadData()
                }
                if let _ = self.classeData?.allClassVideos {
                    self.glimpseClassesCollView.reloadData()
                    self.glimpseCardScroll()
                }
                if let lookCategoryList = self.classeData?.classesWithCategory {
                    self.lookCategoryData?.append(contentsOf: lookCategoryList.prefix(6))
                    self.categoryCollView.reloadData()
                }
            })
        }
        
//        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
//            guard let self = self, let lat = location?.coordinate.latitude, let long = location?.coordinate.longitude else { return }
//            self.getLat = "\(lat)"
//            self.getLong = "\(long)"
//            
//            let params:[String:String] = [
//                "long": "\(long)",
//                "lat": "\(lat)"
//            ]
//            
//            UpcomingClassVM.upcomingClassesApi(inputParams: params, isShowLoader: true, completion: {[weak self] resultData in
//                guard let self = self else { return }
//                
//                self.classesNearCollView.isHidden = false
//                self.glimpseClassesCollView.isHidden = false
//                self.resourcesCollView.isHidden = false
//                self.categoryCollView.isHidden = false
//                
//                self.classeData = resultData?.data
//                self.lookCategoryData?.removeAll()
//                
//                if let _ = self.classeData?.allClasses {
//                    self.classesNearCollView.reloadData()
//                }
//                if let _ = self.classeData?.resources {
//                    self.resourcesCollView.reloadData()
//                }
//                if let _ = self.classeData?.allClassVideos {
//                    self.glimpseClassesCollView.reloadData()
//                    self.glimpseCardScroll()
//                }
//                if let lookCategoryList = self.classeData?.classesWithCategory {
//                    self.lookCategoryData?.append(contentsOf: lookCategoryList.prefix(6))
//                    self.categoryCollView.reloadData()
//                }
//            })
//        }
    }
}
