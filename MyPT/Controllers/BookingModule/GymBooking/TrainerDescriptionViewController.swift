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
    var specialitiesData: [TrainerTagModel]? = [] {
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
    var detailsFlowSetup:calendarFlow = .defaultFlow
    var isSlotsAvail:Bool?
    var istagMenuHeight: Bool?
    var isFromMyTrainers: Bool?
    var hasHomePackage: Bool?
    var hasGymPackage: Bool?
    var package_type: String?
    var fromMyTrainer: Bool?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
//    @IBOutlet weak var badgeImgView: UIImageView!
//    @IBOutlet weak var followrsMBV: UIView!
//    @IBOutlet weak var trainerMenuMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var experienceDetailsMBV: UIView!
    @IBOutlet weak var SpecialitiesMBV: UIView!
    @IBOutlet weak var CertificationsMBV: UIView!
    @IBOutlet weak var WhyTrainwithMeMBV: UIView!
    @IBOutlet weak var motivationMBV: UIView!
    @IBOutlet weak var mediaGalleryMBV: UIView!
//    @IBOutlet weak var followrsCountLbl: UILabel!
//    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
//    @IBOutlet weak var landMark: UIButton!
//    @IBOutlet weak var landMarkAddrLbl: UILabel!
    @IBOutlet weak var averageRatingLbl: UILabel!
    @IBOutlet weak var totalRatingsLbl: UILabel!
//    @IBOutlet weak var trainerMenuCollView: UICollectionView!
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
//    @IBOutlet weak var specialitiesLbl: UILabel!
    @IBOutlet weak var specialitiesCollView: UICollectionView!
    @IBOutlet weak var certificatesTitleLbl: UILabel!
    @IBOutlet weak var whyTrainMeLbl: UILabel!
    @IBOutlet weak var trainMeCollView: UICollectionView!
    @IBOutlet weak var motivationQuoteTitleLbl: UILabel!
    @IBOutlet weak var quoteMBV: UIView!
    @IBOutlet weak var motivationQuoteDescLbl: UILabel!
    @IBOutlet weak var motivationQuoteDescLblBottomConstrnt: NSLayoutConstraint!
    @IBOutlet weak var quoteWriterNameLbl: UILabel!
    @IBOutlet weak var mediaGalleryLbl: UILabel!
    @IBOutlet weak var mediaGalleryCollView: UICollectionView!
//    @IBOutlet weak var bookSlotBtn: UIButton!
    @IBOutlet weak var certificationsCollView: UICollectionView!
    @IBOutlet weak var certificationsCollViewHeightConstrnt: NSLayoutConstraint!
//    @IBOutlet weak var trainerTagHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var btnBookTrainer: UIButton!
    @IBOutlet weak var lblCertificateNoResultFound: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var scrollViewBottomHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //----------------Register Tableview/ Collectionveiew
//        trainerMenuCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        specialitiesCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        trainMeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        mediaGalleryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
//        certificationsCollView.register(UINib(nibName: "CertificatesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CertificatesCollectionViewCell")
        certificationsCollView.register(UINib(nibName: "BannerHomepageCVCell", bundle: nil), forCellWithReuseIdentifier: "BannerHomepageCVCell")
        
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
//                self.trainerMenuCollView.delegate?.collectionView?(self.trainerMenuCollView, didSelectItemAt: firstIndexPath)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.istagMenuHeight = true
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        navigationItem.rightBarButtonItem = self.rightNavBtn
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
    private func inputTagData() {
        self.tagsData = [
            ["title":"About Me","img":UIImage(named: "ic_barbell_ diagonal") as Any],
            ["title":"Review","img": UIImage(named: "ic_star_white") as Any],
            ["title":"Why Train With Me","img": UIImage(named: "ic_story_white") as Any],
            ["title":"Gallery","img": UIImage(named: "ic_gallery_white") as Any]
        ]
        self.istagMenuHeight = true
//        self.trainerMenuCollView.reloadData()
        
        //-----------------************
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let count =  self.tagsData?.count, count >= 0{
//                self.trainerMenuCollView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
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
    
    private func setInputData() {
        self.btnBookTrainer.setTitle(detailsModel?.isPackage ?? false ? "BOOK THE SLOT" : "SELECT THIS TRAINER", for: .normal)
        
        self.trainerFollow()
        self.trainerImgView.loadImage(urlString: detailsModel?.profile, placeholder: UIImage())
        self.trainerImgView.contentMode = .scaleToFill
        self.trainerImgView.clipsToBounds = true
        self.trainerNameLbl.text = self.detailsModel?.name
//        self.followrsCountLbl.text = self.detailsModel?.follower
        //        self.followersLbl.text = ""
        self.distanceBtn.setTitle(self.detailsModel?.distance, for: .normal)
        self.lblAddress.text = self.detailsModel?.location ?? ""
        self.averageRatingLbl.text = self.detailsModel?.noOfRating?.value
        self.totalRatingsLbl.text = (self.detailsModel?.averageRating?.value ?? "") + " ratings"
        self.descLbl.text = self.detailsModel?.description
        self.expCountLbl.text = self.detailsModel?.experience
        self.avgRatingCountLbl.text = self.detailsModel?.averageRating?.value
        
        let clientCoachedTxt = self.detailsModel?.clientCoached ?? ""
        let txtParts = clientCoachedTxt.components(separatedBy: " ")
        if let firstPart = txtParts.first, let secondPart = txtParts.dropFirst().joined(separator: " ") as String? {
            self.clientsCountLbl.text = firstPart
            self.clientsCoachedLbl.text = secondPart
        }
        
        self.motivationQuoteDescLbl.text = "\"\(self.detailsModel?.quote ?? "")\""
        self.quoteWriterNameLbl.isHidden = true
        self.quoteWriterNameLbl.text = nil
        self.motivationQuoteDescLblBottomConstrnt.constant = 0.0
//        
//        if let verified = self.detailsModel?.isVerified, verified {
//            badgeImgView.isHidden = false
//        }else{
//            badgeImgView.isHidden = true
//        }
        
        
        //------------------**********
        self.descLbl.appendReadmore(after: self.detailsModel?.description ?? "", trailingContent: .readmore)
        
        self.descLbl.addReadMoreTapGesture(target: self, action: #selector(handleReadMoreTap(_:)))
        
        //----------------********** Manage views
        self.descMBV.isHidden = true
//        self.experienceDetailsMBV.isHidden = true
        self.motivationMBV.isHidden = true
        
        if let description = self.detailsModel?.description, !description.trimmingCharacters(in: .whitespaces).isEmpty {
            self.descMBV.isHidden = false
        }
        if let quote = self.detailsModel?.quote, !quote.trimmingCharacters(in: .whitespaces).isEmpty {
            self.motivationMBV.isHidden = false
        }
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
    private func setupUI() {
    
        //---------------------**************UI
        DispatchQueue.main.async {
            self.viewBottom.isHidden = self.fromMyTrainer ?? false
            self.scrollViewBottomHeight.constant = self.fromMyTrainer ?? false ? 0 : 100
            self.trainerImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 1.0)], locations: [0.92,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            
            [
//                self.bookSlotBtn,
//                self.followrsMBV,
                self.btnBookTrainer,
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
//                self.followrsMBV,
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
    private func setUpFont() {
        self.trainerNameLbl.font = AppFont.medium.size(22.0, familyName: familyClashDisplay)
//        self.followrsCountLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
//        self.followersLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.lblAddress.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.descLbl.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.expCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.expDescLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.avgRatingCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.avgRatingDecLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.clientsCountLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.clientsCoachedLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//        self.specialitiesLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.certificatesTitleLbl.font = AppFont.medium.size(16.0, familyName: familyFunnelSans)
        self.whyTrainMeLbl.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        self.motivationQuoteTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        self.motivationQuoteDescLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.quoteWriterNameLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        self.mediaGalleryLbl.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
        self.distanceBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.averageRatingLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.totalRatingsLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.btnBookTrainer.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
    }
        
    //MARK: -------------- BOOK SLOT BTN ACTN
    @IBAction func bookSlotBtnActn(_ sender: Any) {
        if self.inputParam?.isFreeAssessmentSelected ?? false { // only for Free Assessment
            let vc: NewCalenderViewController = NewCalenderViewController.instantiate(appStoryboard: .calendar)
            vc.trainerIdStr = inputParam?.trainer_id
            vc.studioIdStr = inputParam?.studio_id
            vc.inputType = inputParam?.type
            vc.package_type = self.package_type
            vc.inputParam = self.inputParam
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if detailsModel?.isPackage ?? false { // Old Flow to book a slot
                if let isFull = detailsModel?.isfull, let slotAvail = detailsModel?.slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                    print("No slots available")
                    AlertHelper.shared.alertMesssage(view: self, title: "", message: "No slots available")
                } else {
                    let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
                    vc.trainerIdStr = inputParam?.trainer_id
                    vc.studioIdStr = inputParam?.studio_id
                    vc.inputType = inputParam?.type
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else { // New Flow without slot booking
                if inputParam?.isFromHomeTrainers ?? false {
                    if hasHomePackage ?? false || hasGymPackage ?? false { // If user have package
                        let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                        //                    vc.packageType = packageType
                        vc.inputType = inputParam?.type
                        vc.inputLat = Double(inputParam?.lat ?? "0.0")
                        vc.inputLong = Double(inputParam?.long ?? "0.0")
                        vc.inputParam = inputParam
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else { // If user does not have package
                        let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                        vc.inputType = inputParam?.type
                        vc.inputLat = Double(inputParam?.lat ?? "0.0")
                        vc.inputLong = Double(inputParam?.long ?? "0.0")
                        vc.inputParam = inputParam
//                        vc.inputParam = DetailsParam(
//                            trainer_id: "\(trainerDetails?.id ?? 0)",
//                            type: "home",
//                            long: "\(self.getLong ?? 0.0)",
//                            lat: "\(self.getLat ?? 0.0)",
//                            addressId: self.addressData?.first?.id?.value,
//                            addressData: self.addressData?.first,
//                            isGroup: trainerDetails?.is_group ?? false,
//                            isFromHomeTrainers: true
//                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if detailsModel?.is_group ?? false {
                        let vc:TrainingTeamViewController = TrainingTeamViewController.instantiate(appStoryboard: .purchase)
                        vc.trainerIdStr = inputParam?.trainer_id
                        vc.studioIdStr = inputParam?.studio_id
                        vc.inputType = inputParam?.type
                        vc.package_type = self.package_type
                        vc.inputParam = self.inputParam
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc: PackagesVC = PackagesVC.instantiate(appStoryboard: .purchase)
                        vc.trainerIdStr = inputParam?.trainer_id
                        vc.studioIdStr = inputParam?.studio_id
                        vc.inputType = inputParam?.type
                        vc.package_type = self.package_type
                        vc.inputParam = self.inputParam
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            }
        }
    }
    
    // MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
}


//MARK: -------------------UICOLLECTION VIEW DATASOURCE/DELEAGET
extension TrainerDescriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trainMeCollView {
            return 1
            //        }
            //        else if collectionView == trainerMenuCollView{
            //            return tagsData?.count ?? 0
        } else if collectionView == certificationsCollView {
                let count = detailsModel?.certificates == nil ? 0 : detailsModel?.certificates?.count ?? 0
                return collectionView.numberOfRows(
                    count: count,
                    title: AppAlertStrings.no_results_found,
                    message: nil,
                    messageImage: nil,
                    messageImageHeight: 50.0,
                    fromTop: 0
                )
//            return detailsModel?.certificates?.count ?? 0
        } else if collectionView == mediaGalleryCollView {
            return collectionView.numberOfRows(count: detailsModel?.galleries?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: nil, messageImageHeight: 50.0, fromTop: 0)
        } else {
            return self.specialitiesData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == specialitiesCollView {
            let cell:ProductCategoryCollViewCell = specialitiesCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
//            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
//            cell.imgBackground.isHidden = false
            cell.shouldHandleSelection = false
            cell.cellMBV.backgroundColor = UIColor.clear
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            cell.imgBackground.image = UIImage(named: "DistanceBG")
            cell.titleLbl.text = self.specialitiesData?[indexPath.row].name
            
            return cell
        }
        else if collectionView == trainMeCollView{
            let cell:WithMeCollectionViewCell = trainMeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
                      
            if let getUrl = URL(string: detailsModel?.trainWithMe as? String ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
                })
            } else{
                cell.centerImgView.isHidden = true
            }
        
            return cell
        } else if collectionView == certificationsCollView {
            
            guard let certificates = detailsModel?.certificates,
                  certificates.count > 0 else {
                return UICollectionViewCell()
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerHomepageCVCell", for: indexPath) as? BannerHomepageCVCell else { return UICollectionViewCell() }
            
            cell.imgBanner.sd_setImage(with: URL(string: certificates[indexPath.row].certificate_path ?? ""), placeholderImage: UIImage(named: "placeholder"))
            //            cell.cellConfigure(customData: self.customisePlans)
            //
            return cell

//            let cell = certificationsCollView.dequeueReusableCell(withReuseIdentifier: "CertificatesCollectionViewCell",for: indexPath) as! CertificatesCollectionViewCell
//
//            let item = certificates[indexPath.row]
//            cell.lavelTitleLbl.text = item.level
//            cell.certificateNameLbl.text = item.name
//
//            return cell
        }

        else if collectionView == mediaGalleryCollView {
            let cell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            if let getUrl = URL(string: detailsModel?.galleries?[indexPath.row].mediaPath ?? "") {
                getThumbnailImageFromVideoUrl(url: getUrl, completion: { (thumbNailImage) in
                    cell.videoThumbnailImgView.image = thumbNailImage
                    cell.centerImgView.isHidden = false
                    cell.centerImgView.image = UIImage(named: "ic_play_white")
                })
            } else {
                cell.centerImgView.isHidden = true
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == trainMeCollView{
            
            if let _ = istagMenuHeight {
                self.istagMenuHeight = nil
//                self.trainerTagHeightConstrnt.constant = 40
                self.trainMeCollView.layoutIfNeeded()
            }
            
            return CGSize(width: collectionView.frame.width*0.90, height: collectionView.frame.height)
            
        }
        else if collectionView == mediaGalleryCollView{
            return CGSize(width: collectionView.frame.width*0.41, height: collectionView.frame.height)
            
        } else if collectionView == certificationsCollView {
            return CGSize(width: 283, height: collectionView.frame.height)
//            return CGSize(width: collectionView.frame.width/2, height: collectionView.frame.height)
        } else if collectionView == specialitiesCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//            return CGSize(width: collectionView.frame.width*0.32, height: 24)
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
        if collectionView == trainMeCollView{
            self.videoUrl = detailsModel?.trainWithMe
        }else if collectionView == mediaGalleryCollView{
            self.videoUrl = detailsModel?.galleries?[indexPath.row].mediaPath
        }
    }
    
    // MARK: ---------Make Collectionview scroll Center
    func scrollToCenter(indexPath: IndexPath, collView: UICollectionView) {
//        guard let layout = collView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
//        
//        let cellWidth = layout.itemSize.width
//        let cellSpacing = layout.minimumLineSpacing
//        let totalCellWidth = cellWidth + cellSpacing
//        
//        let collectionViewWidth = trainerMenuCollView.frame.width
//        let targetOffset = (CGFloat(indexPath.item) * totalCellWidth) - (collectionViewWidth / 2) + (cellWidth / 2)
//        
//        collView.setContentOffset(CGPoint(x: max(0, targetOffset), y: 0), animated: true)
//        isCounter += 1
    }
}


extension TrainerDescriptionViewController {
    func getTrainerDetailsApi() {
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
                
                self.SpecialitiesMBV.isHidden = true
                self.CertificationsMBV.isHidden = false
                self.WhyTrainwithMeMBV.isHidden = true
                self.mediaGalleryMBV.isHidden = false
                
                if let specialitiesData = self.specialitiesData?.count, specialitiesData != 0 {
                    self.SpecialitiesMBV.isHidden = false
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self.specialitiesCollView.reloadData()
//                    })
                }
//                if let certificates = detailsModel?.certificates?.count, certificates != 0 {
                lblCertificateNoResultFound.isHidden = getResult.data?.certificates?.count == 0 ? false : true
                    self.CertificationsMBV.isHidden = false
                    self.certificationsCollView.reloadData()
//                }
                if let galleries = detailsModel?.galleries?.count, galleries != 0 {
                    self.WhyTrainwithMeMBV.isHidden = false
                    self.mediaGalleryCollView.reloadData()
                }
                
                if let trainWithMe = detailsModel?.trainWithMe , !trainWithMe.isEmpty {
                    self.WhyTrainwithMeMBV.isHidden = false
                    self.trainMeCollView.reloadData()
                }
            }
        })
    }
}
