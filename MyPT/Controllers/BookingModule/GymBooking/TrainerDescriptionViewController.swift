//
//  TrainerDescriptionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/11/24.
//

import UIKit
import AVFoundation
import AVKit

class TrainerDescriptionViewController: CommonViewController {

    //MARK: -------------VARIABLE
    var specialitiesData:[TrainerTagModel]? = [] {
        didSet{
            if let specialitiesData = specialitiesData {
                if specialitiesData.count > 0 {
                    restrictedRange = [0...specialitiesData.count - 1]
                }
                self.specialitiesCollView.reloadData()
            }
        }
    }
  
    private var videoUrl: String? {
        didSet{
            guard let videoStr = videoUrl, let videoURL = URL(string: videoStr) else { return }
               let player = AVPlayer(url: videoURL)
               let vc = AVPlayerViewController()
               vc.player = player
               present(vc, animated: true) {
                   player.play()
               }
        }
    }
    
    //-----------------------FOLLOW/UNFOLLOW BTN
    lazy var rightNavBtn: UIBarButtonItem = {
        let button =  UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        button.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        return UIBarButtonItem(customView: button)
    }()
    
    var isExpandedLbl = false
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    // State to track expanded or collapsed
    private var isExpanded = false
    var tagsData:[[String:Any]]?
    var detailsModel:TrainerDetalsModel?
//    var specialitiesData:[TrainerTagModel]?
    var inputParam: DetailsParam?
    private var isCounter:Int = 0
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var badgeImgView: UIImageView!
    @IBOutlet weak var followrsMBV: UIView!
    @IBOutlet weak var followrsCountLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var landMark: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var ratingCountBtn: UIButton!
    @IBOutlet weak var trainerMenuCollView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var experienceMBV: UIView!
    @IBOutlet weak var avgRatingMBV: UIView!
    @IBOutlet weak var clientCoachedMBV: UIView!
    @IBOutlet weak var expCountLbl: UILabel!
    @IBOutlet weak var expDescLbl: UILabel!
    @IBOutlet weak var avgRatingCountLbl: UILabel!
    @IBOutlet weak var avgRatingDecLbl: UILabel!
    @IBOutlet weak var clientsCountLbl: UILabel!
    @IBOutlet weak var clientsCoachedLbl: UILabel!
    @IBOutlet weak var specialitiesLbl: UILabel!
    @IBOutlet weak var specialitiesCollView: UICollectionView!
    @IBOutlet weak var certificatesTitleLbl: UILabel!
    @IBOutlet weak var whyTrainMeLbl: UILabel!
    @IBOutlet weak var trainMeCollView: UICollectionView!
    @IBOutlet weak var motivationQuoteTitleLbl: UILabel!
    @IBOutlet weak var quoteMBV: UIView!
    @IBOutlet weak var motivationQuoteDescLbl: UILabel!
    @IBOutlet weak var quoteWriterNameLbl: UILabel!
    @IBOutlet weak var mediaGalleryLbl: UILabel!
    @IBOutlet weak var mediaGalleryCollView: UICollectionView!
    @IBOutlet weak var bookSlotBtn: UIButton!
    @IBOutlet weak var certificationsCollView: UICollectionView!
    @IBOutlet weak var certificationsCollViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //----------------Register Tableview/ Collectionveiew
        trainerMenuCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        specialitiesCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        trainMeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        mediaGalleryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        certificationsCollView.register(UINib(nibName: "CertificatesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CertificatesCollectionViewCell")
        
        setupUI()
        setUpFont()
        self.inputTagData()
        self.getTrainerDetailsApi()
        
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        if let count =  self.tagsData?.count, count >= 0{
            DispatchQueue.main.async {
                self.trainerMenuCollView.delegate?.collectionView?(self.trainerMenuCollView, didSelectItemAt: firstIndexPath)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
        navigationItem.rightBarButtonItem = self.rightNavBtn
        //        self.setupRightNav()
        //        self.setRighMenu(rightImgs: [AppImages.follow], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
        
    //MARK: --------------FOLLOW / UNFOLLOW BTN ACTN
    @objc func rightButtonTapped() {
        print("Custom right button tapped")
        
        //-------------------Follow Api
        CreatePackageVM.trainerFollowApi(viewController: self, inputId: "\(self.detailsModel?.id ?? 0)", completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if getResultData["status"] as? Bool == true {
                let result = getResultData["data"] as? [String:Any]
                let followStatus = result?["isFollowed"] as? Bool
                self.detailsModel?.isFollowing = followStatus
                self.trainerFollow()
                AlertHelper.shared.alertMesssage(view: self, title: "", message: getResultData["msg"] as? String ?? "")
            }
        })
    }

    
    //MARK: ----------TAG DATA
    private func inputTagData(){
        self.tagsData = [
            ["title":"About Me","img":UIImage(named: "ic_barbell_ diagonal") as Any],
            ["title":"Review","img": UIImage(named: "ic_star_white") as Any],
            ["title":"Why Train With Me","img": UIImage(named: "ic_story_white") as Any],
            ["title":"Gallery","img": UIImage(named: "ic_gallery_white") as Any]
        ]
        self.trainerMenuCollView.reloadData()
        
        //-----------------************
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let count =  self.tagsData?.count, count >= 0{
                self.trainerMenuCollView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func trainerFollow(){
        if let button = rightNavBtn.customView as? UIButton {
            
            if let isFollowing = self.detailsModel?.isFollowing {
                let setTitle = isFollowing  ? "FOLLOWING" : "FOLLOW"
                button.setTitle(setTitle, for: .normal)
            }
        }
    }
    
    private func setInputData(){
        
        self.trainerFollow()
        self.trainerImgView.loadImage(urlString: detailsModel?.profile, placeholder: AppImages.navLeft)
        self.trainerNameLbl.text = self.detailsModel?.name
        self.followrsCountLbl.text = self.detailsModel?.follower
        //        self.followersLbl.text = ""
        self.distanceBtn.setTitle(self.detailsModel?.distance, for: .normal)
        self.landMark.setTitle(self.detailsModel?.location, for: .normal)
        self.ratingBtn.setTitle(self.detailsModel?.noOfRating, for: .normal)
        self.ratingCountBtn.setTitle(self.detailsModel?.averageRating, for: .normal)
        self.descLbl.text = self.detailsModel?.description
        self.expCountLbl.text = self.detailsModel?.experience
        self.avgRatingCountLbl.text = self.detailsModel?.averageRating
        
        let clientCoachedTxt = self.detailsModel?.clientCoached ?? ""
        let txtParts = clientCoachedTxt.components(separatedBy: " ")
        if let firstPart = txtParts.first, let secondPart = txtParts.dropFirst().joined(separator: " ") as String? {
            self.clientsCountLbl.text = firstPart
            self.clientsCoachedLbl.text = secondPart
        }
        
        self.motivationQuoteDescLbl.text = "\"\(self.detailsModel?.quote ?? "")\""
        self.quoteWriterNameLbl.isHidden = true
        
        if let verified = self.detailsModel?.isVerified, verified {
            badgeImgView.isHidden = false
        }else{
            badgeImgView.isHidden = true
        }
        
        
        //------------------**********
        self.descLbl.appendReadmore(after: self.detailsModel?.description ?? "", trailingContent: .readmore)
        
        self.descLbl.addReadMoreTapGesture(target: self, action: #selector(handleReadMoreTap(_:)))
        
        //        self.mediaGalleryLbl.text = ""
        //        self.expDescLbl.text = ""
        //        self.avgRatingDecLbl.text = ""
        //        self.clientsCoachedLbl.text = ""
        //        self.specialitiesLbl.text = ""
        //        self.certificatesTitleLbl.text = ""
        //        self.whyTrainMeLbl.text = ""
        //        self.motivationQuoteTitleLbl.text = ""
    }
    
    //MARK: ------------------FOR MAKING EXPANDABLE STRING OF UILABEL
    @objc private func handleReadMoreTap(_ gesture: UITapGestureRecognizer) {
           let tapLocation = gesture.location(in: self.descLbl)
           guard let tappedIndex = self.descLbl.getTappedTextIndex(tapLocation) else { return }
           
           let readMoreText = TrailingContent.readmore.text
           let readLessText = TrailingContent.readless.text
           let fullAttributedString = self.descLbl.attributedText?.string ?? ""

           if fullAttributedString.range(of: readMoreText) != nil, tappedIndex >= (fullAttributedString.count - readMoreText.count) {
               self.descLbl.appendReadLess(after: self.detailsModel?.description ?? "", trailingContent: .readless)
           } else if fullAttributedString.range(of: readLessText) != nil, tappedIndex >= (fullAttributedString.count - readLessText.count) {
               self.descLbl.appendReadmore(after: self.detailsModel?.description ?? "", trailingContent: .readmore)
           }
       }
    
    
    //MARK: ---------- SET UI
    private func setupUI(){
    
        //---------------------**************UI
        DispatchQueue.main.async {
            [
                self.bookSlotBtn,
                self.followrsMBV,
                self.experienceMBV,
                self.avgRatingMBV,
                self.clientCoachedMBV,
                self.clientCoachedMBV,
                self.quoteMBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
        
            //----------------Gradient view
            [
                self.followrsMBV,
                self.experienceMBV,
                self.avgRatingMBV,
                self.clientCoachedMBV,
                self.clientCoachedMBV,
                self.quoteMBV
            ].forEach({
                $0?.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            })
        }
    }
    
    //------------------************Font
    private func setUpFont(){
        self.trainerNameLbl.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        self.followrsCountLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.followersLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.landMark.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.descLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.expCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.expDescLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.avgRatingCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.avgRatingDecLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.clientsCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.clientsCoachedLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.specialitiesLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.certificatesTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.whyTrainMeLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.motivationQuoteTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        self.motivationQuoteDescLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.quoteWriterNameLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        self.mediaGalleryLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.distanceBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.ratingCountBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.bookSlotBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
    }

        
    //MARK: -------------- BOOK SLOT BTN ACTN
    @IBAction func bookSlotBtnActn(_ sender: Any) {
        
        let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
        vc.trainerIdStr = inputParam?.trainer_id
        vc.studioIdStr = inputParam?.studio_id
        vc.inputType = inputParam?.type
        self.navigationController?.pushViewController(vc, animated: true)
        
        /*
        let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
        vc.slotBookFlow = .bookTrainer
        self.navigationController?.pushViewController(vc, animated: true)
        */
        
        /*
         //        let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
         //        vc.modalPresentationStyle = .automatic
         //        self.present(vc, animated: true)
        let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
        
        */
    }
    
}


//MARK: -------------------UICOLLECTION VIEW DATASOURCE/DELEAGET
extension TrainerDescriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trainMeCollView{
            return 1
        }
        else if collectionView == trainerMenuCollView{
            return tagsData?.count ?? 0
        }else if collectionView == certificationsCollView{
            return detailsModel?.certificates?.count ?? 0
        }else if collectionView == mediaGalleryCollView{
            return collectionView.numberOfRows(count: detailsModel?.galleries?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: nil, messageImageHeight: 50.0, fromTop: 0)
//            return detailsModel?.galleries?.count ?? 0
        }
        else{
            return self.specialitiesData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainerMenuCollView {
            let cell:WorkoutCategoryCollectionViewCell = trainerMenuCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            cell.categoryTitleLbl.text = tagsData?[indexPath.row]["title"] as? String
            cell.categoryImgView.image = tagsData?[indexPath.row]["img"] as? UIImage
          
            /*
             title
             img
             */
            return cell
        }
        else if collectionView == specialitiesCollView{
            let cell:ProductCategoryCollViewCell = specialitiesCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            
            cell.titleLbl.text = self.specialitiesData?[indexPath.row].name
            
            return cell
        }
        else if collectionView == trainMeCollView{
            let cell:WithMeCollectionViewCell = trainMeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
           
//            cell.videoThumbnailImgView.loadImage(urlString: detailsModel?.trainWithMe as? String, placeholder: AppImages.navLeft)
            
//             let urlString = detailsModel?.trainWithMe as? String
//            let url = URL(string: urlString ?? "")
           
            if let getUrl = URL(string: detailsModel?.trainWithMe as? String ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
                    
//                    cell.centerImgView.image = UIImage(named: "ic_thumbnailVideo")
                    //ic_thumbnailVideo
                })
            } else{
                cell.centerImgView.isHidden = true
            }
        
            return cell
        }
        else if collectionView == certificationsCollView{
            let cell: CertificatesCollectionViewCell = certificationsCollView.dequeueReusableCell(withReuseIdentifier: "CertificatesCollectionViewCell", for: indexPath) as! CertificatesCollectionViewCell
            
            cell.lavelTitleLbl.text = detailsModel?.certificates?[indexPath.row].level as? String
            cell.certificateNameLbl.text = detailsModel?.certificates?[indexPath.row].name as? String
            
//            if indexPath.row % 2 == 0 {
//                cell.achivementImgView.isHidden = true
//            }else{
//                cell.achivementImgView.isHidden = false
//            }
            
            return cell
            
        }
        else if collectionView == mediaGalleryCollView{
            let cell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
//            cell.videoThumbnailImgView.loadImage(urlString: detailsModel?.galleries?[indexPath.row].mediaPath as? String, placeholder: AppImages.navLeft)
            
            //cell.centerImgView.image = UIImage(named: "ic_thumbnailVideo")
            
            if let getUrl = URL(string: detailsModel?.galleries?[indexPath.row].mediaPath ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
                    //ic_thumbnailVideo
                })
            } else{
                cell.centerImgView.isHidden = true
            }
            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == trainMeCollView{
            return CGSize(width: collectionView.frame.width*0.90, height: collectionView.frame.height)
            
        }
        else if collectionView == mediaGalleryCollView{
            return CGSize(width: collectionView.frame.width*0.41, height: collectionView.frame.height)
            
        }
        else if collectionView == certificationsCollView{
            return CGSize(width: collectionView.frame.width*0.32, height: collectionView.frame.height)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        if collectionView == specialitiesCollView{
            return !restrictedRange.contains { $0.contains(indexPath.item) }
        }else{
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trainerMenuCollView {
            scrollToCenter(indexPath: indexPath, collView: trainerMenuCollView)
         
            guard isCounter > 1 else { return  }
            isCounter = (isCounter >= 2) ? 2 : isCounter
            print("isCounter: ", isCounter)
            
            if (tagsData?[indexPath.row]["title"] as? String)?.uppercased() == "Gallery".uppercased() {
                scrollToView(self.mediaGalleryCollView)
            }else if (tagsData?[indexPath.row]["title"] as? String)?.uppercased() == "Why Train With Me".uppercased(){
                scrollToView(self.trainMeCollView)
            }else if (tagsData?[indexPath.row]["title"] as? String)?.uppercased() == "Review".uppercased(){
                scrollToView(self.certificationsCollView)
            }
            else if (tagsData?[indexPath.row]["title"] as? String)?.uppercased() == "About Me".uppercased(){
                scrollToView(self.descLbl)
                
            }
            
        }else if collectionView == trainMeCollView{
            self.videoUrl = detailsModel?.trainWithMe
        }else if collectionView == mediaGalleryCollView{
            self.videoUrl = detailsModel?.galleries?[indexPath.row].mediaPath
        }
    }
    
    // MARK: ---------Make Collectionview scroll Center
    func scrollToCenter(indexPath: IndexPath, collView: UICollectionView) {
        guard let layout = collView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cellWidth = layout.itemSize.width
        let cellSpacing = layout.minimumLineSpacing
        let totalCellWidth = cellWidth + cellSpacing
        
        let collectionViewWidth = trainerMenuCollView.frame.width
        let targetOffset = (CGFloat(indexPath.item) * totalCellWidth) - (collectionViewWidth / 2) + (cellWidth / 2)
        
        collView.setContentOffset(CGPoint(x: max(0, targetOffset), y: 0), animated: true)
        isCounter += 1
    }
}


extension TrainerDescriptionViewController{
    
    func getTrainerDetailsApi(){
        let params:[String:String] = [
            "trainer_id": inputParam?.trainer_id ?? "",
            "studio_id": inputParam?.studio_id ?? "",
            "type": inputParam?.type ?? "",
            "long": inputParam?.long ?? "",
            "lat": inputParam?.lat ?? ""
        ]
        
        TrainerVM.getTrainerDetailsApi(viewController: self, inputParms: params, completion: {[weak self] getResult in
            guard let self = self, let getResult = getResult else { return  }
            print("get result: ", getResult)
            if getResult.status == true{
                self.detailsModel = nil
                self.specialitiesData?.removeAll()
                self.detailsModel = getResult.data
                self.specialitiesData?.append(contentsOf: self.detailsModel?.tags ?? [])
                self.setInputData()
                self.trainMeCollView.reloadData()
                self.certificationsCollView.reloadData()
                self.mediaGalleryCollView.reloadData()
            }
        })
    }
}

