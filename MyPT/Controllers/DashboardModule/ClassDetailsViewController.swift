//
//  ClassDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/05/25.
//

import UIKit
import AVKit

enum ClassDetailsFlow {
    case guestUser
    case defaultClassDetails
}

class ClassDetailsViewController: CommonViewController {
    
    //-----------------
    var flowClassDetails: ClassDetailsFlow = .defaultClassDetails
    
    //    var classDetails: UpcomingClassModel?
    var restrictedRange: [ClosedRange<Int>] = [0...4]
    var classDetails: ClassDetailsModel?
    var inputLat: String?
    var inputLong: String?
    var scheludeIdStr: String?
    
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
    
    //-----------------------SHARE BTN
    lazy var shareNavBtn: UIBarButtonItem = {
        let button =  UIButton(type: .system)
        button.tintColor = UIColor.appWhite
        button.backgroundColor = .clear
        button.setImage(AppImages.shareGymWorkout, for: .normal)
        button.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        button.addTarget(self, action: #selector(shareBtnTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return UIBarButtonItem(customView: button)
    }()
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var trainerProfileMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var aboutTrainerMBV: UIView!
    @IBOutlet weak var sessionsMBV: UIView!
    @IBOutlet weak var sessionsCountMBV: UIView!
    @IBOutlet weak var avgRatingMBV: UIView!
    @IBOutlet weak var clientCoachMBV: UIView!
    @IBOutlet weak var spscialitiesMBV: UIView!
    @IBOutlet weak var certificationsMBV: UIView!
    @IBOutlet weak var trainWithMeMBV: UIView!
    @IBOutlet weak var motivationQuoteMBV: UIView!
    @IBOutlet weak var quoteMBV: UIView!
    @IBOutlet weak var mediaGalleryMBV: UIView!
    @IBOutlet weak var followersMBV: UIView!
    @IBOutlet weak var classImgView: UIImageView!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var studentsCountLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var classDescLbl: UILabel!
    @IBOutlet weak var aboutTrainerTitleLbl: UILabel!
    @IBOutlet weak var trainerProfileImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var trainerBadgeImgView: UIImageView!
    @IBOutlet weak var followCountsLbl: UILabel!
    @IBOutlet weak var followersTitleLbl: UILabel!
    @IBOutlet weak var sessionsCountLbl: UILabel!
    @IBOutlet weak var sessionsTitleLbl: UILabel!
    @IBOutlet weak var angRatingCountLbl: UILabel!
    @IBOutlet weak var avgRatingTitleLbl: UILabel!
    @IBOutlet weak var coachCountLbl: UILabel!
    @IBOutlet weak var coachTitleLbl: UILabel!
    @IBOutlet weak var specialitiesTitleLbl: UILabel!
    @IBOutlet weak var specialityCollView: UICollectionView!
    @IBOutlet weak var CertificationsTitleLbl: UILabel!
    @IBOutlet weak var CertificationsCollView: UICollectionView!
    @IBOutlet weak var WhyTrainwithMeTitleLbl: UILabel!
    @IBOutlet weak var WhyTrainwithMeCollView: UICollectionView!
    @IBOutlet weak var motivationQuoteTitleLbl: UILabel!
    @IBOutlet weak var motivationQuoteLbl: UILabel!
    @IBOutlet weak var writerLbl: UILabel!
    @IBOutlet weak var mediaGalleryTitleLbl: UILabel!
    @IBOutlet weak var mediaGalleryCollView: UICollectionView!
    @IBOutlet weak var bookingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descMBV.isHidden = true
        self.aboutTrainerMBV.isHidden = true
        self.sessionsMBV.isHidden = true
        self.avgRatingMBV.isHidden = true
        self.clientCoachMBV.isHidden = true
        self.spscialitiesMBV.isHidden = true
        self.certificationsMBV.isHidden = true
        self.trainWithMeMBV.isHidden = true
        self.motivationQuoteMBV.isHidden = true
        self.mediaGalleryMBV.isHidden = true
        self.bookingBtn.isUserInteractionEnabled = false
        
        self.setupFont()
        self.setupUI()
        self.registerCell()
//        self.classDetailsApi()
        
        if let _ = inputLat, let _ = inputLong{
            self.classDetailsApi()
        }else{
            self.getLocation()
        }
        
        self.setInputData()
        
        bookingBtn.setTitle(AppStrings.reserve_Slot, for: .normal)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
        navigationItem.rightBarButtonItem = self.shareNavBtn
    }
    
    @objc func shareBtnTapped() {
        print("Custom right button tapped")
        ImageDownloader.shared.downloadImage(from: (classDetails?.classProfile ?? ""), completion: {[weak self] img in
            guard let self = self , let img = img else {
                return
            }
            let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + (isTesting ? AppBaseUrl.baseDevUrl.rawValue : AppBaseUrl.baseProductionUrl.rawValue)
            print(getBaseUrl)
            let urlString = "\(getBaseUrl)/class/\(scheludeIdStr ?? "")/\(flowClassDetails)"
            Utility.shared.shareSocial(viewController: self, textToShare: classDetails?.className ?? "", imageToShare: img, urlShareStr: urlString)
        })
        
        //        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
    }
    
    
    private func setInputData(){
        //------------------**********
        self.distanceBtn.titleLabel?.numberOfLines = 3
        self.addressBtn.titleLabel?.numberOfLines = 3
        
        self.classImgView.loadImage(urlString: classDetails?.classProfile, placeholder: nil)
        self.classNameLbl.text = classDetails?.className
        self.dateBtn.setTitle(classDetails?.time, for: .normal)
        if let classCapacity = classDetails?.capacity {
            self.studentsCountLbl.text = "Class of \(classCapacity) students"
        }
        self.distanceBtn.setTitle((classDetails?.distance ?? ""), for: .normal)
        self.addressBtn.setTitle((classDetails?.location ?? ""), for: .normal)
        
        //        self.classDescLbl
        //        self.aboutTrainerTitleLbl
        self.trainerProfileImgView.loadImage(urlString: classDetails?.profile, placeholder: nil)
        self.trainerNameLbl.text = classDetails?.name
        self.followCountsLbl.text = classDetails?.followers
        //        self.followersTitleLbl
        //        self.sessionsCountLbl.text = classDetails?.sessions
        //        self.sessionsTitleLbl
        //        self.angRatingCountLbl.text = "\(classDetails?.averageRating)"
        
        if let avgRating = classDetails?.averageRating {
            self.angRatingCountLbl.text = "\(avgRating)"
        }
        
        if let verified = self.classDetails?.isVerified, verified {
            self.trainerBadgeImgView.isHidden = false
        }else{
            self.trainerBadgeImgView.isHidden = true
        }
        
        let sessionCountTxt = self.classDetails?.sessions?.value ?? ""
        let sessionParts = sessionCountTxt.components(separatedBy: " ")
        if let sessionFirst = sessionParts.first, let sessionSecondPart = sessionParts.dropFirst().joined(separator: " ") as String? {
            self.sessionsCountLbl.text = sessionFirst
            self.sessionsTitleLbl.text = sessionSecondPart
        }
        
        let clientCoachedTxt = self.classDetails?.clientCoached ?? ""
        let txtParts = clientCoachedTxt.components(separatedBy: " ")
        if let firstPart = txtParts.first, let secondPart = txtParts.dropFirst().joined(separator: " ") as String? {
            self.coachCountLbl.text = firstPart
            self.coachTitleLbl.text = secondPart
        }
        
        /*
         "is_member": true, when getting true ->show only  Reserve Slot
         if getting false -> show Reserve Slot @ AED 299
         */
        
        if let isMember = self.classDetails?.isMember, isMember {
            self.bookingBtn.isUserInteractionEnabled = false
            bookingBtn.setTitle(AppStrings.reserve_Slot, for: .normal)
        }else{
            let classPrice = "@ AED " + (self.classDetails?.price?.value ?? "")
            
            bookingBtn.setTitle(AppStrings.reserve_Slot + classPrice, for: .normal)
            self.bookingBtn.isUserInteractionEnabled = true
        }
        
        //----------------********** Manage views
        //        self.descMBV.isHidden = true
        ////        self.experienceDetailsMBV.isHidden = true
        //        self.motivationQuoteMBV.isHidden = true
        
        self.motivationQuoteLbl.text = classDetails?.quote
        if let description = self.classDetails?.classDescription , !description.trimmingCharacters(in: .whitespaces).isEmpty {
            self.descMBV.isHidden = false
        }
        if let trainerName = classDetails?.name, !trainerName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.aboutTrainerMBV.isHidden = false
        }
        if let quote = self.classDetails?.quote, !quote.trimmingCharacters(in: .whitespaces).isEmpty {
            self.motivationQuoteMBV.isHidden = false
        }
        
        
        //        self.avgRatingTitleLbl
        //        self.coachCountLbl
        //        self.coachTitleLbl
        //        self.specialitiesTitleLbl
        //        self.specialityCollView
        //        self.CertificationsTitleLbl
        //        self.CertificationsCollView
        //        self.WhyTrainwithMeTitleLbl
        //        self.WhyTrainwithMeCollView
        //        self.motivationQuoteTitleLbl
        
        //        self.writerLbl
        //        self.mediaGalleryTitleLbl
        //        self.mediaGalleryCollView
        
        
        //------------------*********Desc
        self.classDescLbl.appendReadmore(after: classDetails?.classDescription ?? "", trailingContent: .readmore)
        
        self.classDescLbl.addReadMoreTapGesture(target: self, action: #selector(handleReadMoreTap(_:)))
        
        self.setupUI()
        
    }
    
    //MARK: ------------------FOR MAKING EXPANDABLE STRING OF UILABEL
    @objc private func handleReadMoreTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.classDescLbl)
        guard let tappedIndex = self.classDescLbl.getTappedTextIndex(tapLocation) else { return }
        
        let readMoreText = TrailingContent.readmore.text
        let readLessText = TrailingContent.readless.text
        let fullAttributedString = self.classDescLbl.attributedText?.string ?? ""
        
        if fullAttributedString.range(of: readMoreText) != nil, tappedIndex >= (fullAttributedString.count - readMoreText.count) {
            self.classDescLbl.appendReadLess(after: classDetails?.classDescription ?? "", trailingContent: .readless)
        } else if fullAttributedString.range(of: readLessText) != nil, tappedIndex >= (fullAttributedString.count - readLessText.count) {
            self.classDescLbl.appendReadmore(after: classDetails?.classDescription ?? "", trailingContent: .readmore)
        }
    }
    
    private func getLocation(){
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self else { return }
            
            appUserDefaults.setLatLong(value: "\(location?.coordinate.latitude ?? 0),\(location?.coordinate.longitude ?? 0)")
            appUserDefaults.setCurrentAddr(value: addressPart.0)
            
            self.inputLat = "\(location?.coordinate.latitude ?? 0)"
            self.inputLong = "\(location?.coordinate.longitude ?? 0)"
            
            self.classDetailsApi()
        }
    }
    
    private func registerCell(){
        //----------------Register Tableview/ Collectionveiew
        specialityCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        WhyTrainwithMeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        CertificationsCollView.register(UINib(nibName: "CertificatesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CertificatesCollectionViewCell")
        mediaGalleryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            
            self.classImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            
//            self.classImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 0.8)], locations: [0.96,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            
            self.dateBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.dateBtn.frame.size.height/2.0)
            self.trainerProfileImgView.setCornerRadius(borderWidth: 2.0, borderColor: UIColor(red: 36.0/255.0, green: 38.0/255.0, blue: 43.0/255.0, alpha: 0.8), cornerRadious: self.trainerProfileImgView.frame.size.height/2.0)
            //rgba(36, 38, 43, 1)
            [
                self.bookingBtn,
                self.followersMBV,
                self.sessionsCountMBV,
                self.avgRatingMBV,
                self.clientCoachMBV,
                self.quoteMBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            //----------------Gradient view
            [
                self.followersMBV,
                self.sessionsCountMBV,
                self.avgRatingMBV,
                self.clientCoachMBV,
                self.quoteMBV
            ].forEach({
                $0?.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            })
        }
    }
    
    private func setupFont(){
        self.trainerNameLbl.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        self.classNameLbl.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
        self.motivationQuoteLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.writerLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        self.followCountsLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.bookingBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        [
            self.studentsCountLbl,
            self.addressBtn.titleLabel,
            self.distanceBtn.titleLabel,
            self.classDescLbl
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        [
            self.sessionsCountLbl,
            self.angRatingCountLbl,
            self.coachCountLbl
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        })
        
        [
            self.sessionsTitleLbl,
            self.avgRatingTitleLbl,
            self.coachTitleLbl,
            self.dateBtn.titleLabel,
            self.followersTitleLbl
        ].forEach({ [weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [
            self.aboutTrainerTitleLbl,
            self.specialitiesTitleLbl,
            self.CertificationsTitleLbl,
            self.WhyTrainwithMeTitleLbl,
            self.motivationQuoteTitleLbl,
            self.mediaGalleryTitleLbl
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
    }
    
    @IBAction func bookingBtnActn(_ sender: Any) {
        print("Booking Btn clicked...")
        
        
        switch flowClassDetails {
        case .guestUser:
            if appUserDefaults.clearUserDefault() {
                appSceneDelegate?.goToMainView()
            }
            
        case .defaultClassDetails:
            
            if let scheduleId = classDetails?.schduleID {
                UpcomingClassVM.bookingClassApi(inputScheduleId: "\(scheduleId)", completion: {[weak self] getBookClassData in
                    guard let self = self, let getBookClassData = getBookClassData else { return  }
                    if getBookClassData.status == true {
                        let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
                        vc.bookClassModel = getBookClassData.data
                        vc.billingViewFlow = .upcomingClass
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
        
        /*
        if let scheduleId = classDetails?.schduleID {
            UpcomingClassVM.bookingClassApi(inputScheduleId: "\(scheduleId)", completion: {[weak self] getBookClassData in
                guard let self = self, let getBookClassData = getBookClassData else { return  }
                if getBookClassData.status == true {
                    let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
                    vc.bookClassModel = getBookClassData.data
                    vc.billingViewFlow = .upcomingClass
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        */
    }
}

//MARK: ----------------UICOLLECTIONVIEW DELEAGTE/ DATASOURCE
extension ClassDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == specialityCollView{
            return self.classDetails?.tags?.count ?? 0
        }
        else if collectionView == WhyTrainwithMeCollView{
            return 1
        }
        else if collectionView == CertificationsCollView{
            return self.classDetails?.certificates?.count ?? 0
        }
        else if collectionView == mediaGalleryCollView{
            return self.classDetails?.mediaGallery?.count ?? 0
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == specialityCollView{
            let cell:ProductCategoryCollViewCell = specialityCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.titleLbl.text = self.classDetails?.tags?[indexPath.row] as? String //self.classDetails?.tags?[indexPath.row].name
            
            return cell
        }
        else if collectionView == CertificationsCollView{
            let cell: CertificatesCollectionViewCell = CertificationsCollView.dequeueReusableCell(withReuseIdentifier: "CertificatesCollectionViewCell", for: indexPath) as! CertificatesCollectionViewCell
            
            cell.lavelTitleLbl.text = classDetails?.certificates?[indexPath.row].level as? String
            cell.certificateNameLbl.text = classDetails?.certificates?[indexPath.row].name as? String
            
            return cell
            
        }
        else if collectionView == WhyTrainwithMeCollView{
            let cell:WithMeCollectionViewCell = WhyTrainwithMeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            DispatchQueue.main.async {
                cell.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            }
            
            if let getUrl = URL(string: classDetails?.trainWithMe as? String ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
                })
            } else{
                cell.centerImgView.isHidden = true
            }
            
            return cell
        }
        else if collectionView == mediaGalleryCollView{
            let cell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
            DispatchQueue.main.async {
                cell.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            }
            
            if let getUrl = URL(string: classDetails?.mediaGallery?[indexPath.row] ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
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
        
        if collectionView == WhyTrainwithMeCollView{
            return CGSize(width: collectionView.frame.width*0.90, height: collectionView.frame.height)
            
        }
        else if collectionView == CertificationsCollView{
            return CGSize(width: collectionView.frame.width*0.32, height: collectionView.frame.height)
        }
        else if collectionView == mediaGalleryCollView{
            return CGSize(width: collectionView.frame.width*0.41, height: collectionView.frame.height)
            
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == WhyTrainwithMeCollView{
            self.videoUrl = classDetails?.trainWithMe
        }else if collectionView == mediaGalleryCollView{
            self.videoUrl = classDetails?.mediaGallery?[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        if collectionView == specialityCollView{
            return !restrictedRange.contains { $0.contains(indexPath.item) }
        }else{
            return true
        }
    }
}


extension ClassDetailsViewController{
    
    private func classDetailsApi(){
        let params:[String:String] = [
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
            "schdule_id": self.scheludeIdStr ?? ""
        ]
        
        UpcomingClassVM.classDetailsApi(inputParams: params, completion: {[weak self] getResultData in
            
            guard let self = self, let getResultData = getResultData else { return }
            self.classDetails = getResultData.data
            self.setInputData()
            
            if let tags = self.classDetails?.tags, tags.count != 0 {
                if tags.count > 0 {
                    restrictedRange = [0...tags.count - 1]
                }
                self.spscialitiesMBV.isHidden = false
                self.specialityCollView.reloadData()
            }
            
            if let certificates = self.classDetails?.certificates, certificates.count != 0 {
                self.certificationsMBV.isHidden = false
                self.CertificationsCollView.reloadData()
            }
            
            if let mediaGallery = self.classDetails?.mediaGallery, mediaGallery.count != 0 {
                self.mediaGalleryMBV.isHidden = false
                self.mediaGalleryCollView.reloadData()
            }
            
            if let trainWithMe = self.classDetails?.trainWithMe, !trainWithMe.isEmpty{
                self.trainWithMeMBV.isHidden = false
                self.WhyTrainwithMeCollView.reloadData()
            }
        })
    }
}
