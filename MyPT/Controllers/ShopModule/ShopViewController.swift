//
//  ShopViewController.swift
//  MyPT
//
//  Created by techsaga corp on 21/02/25.
//

import UIKit
import AVFoundation

class ShopViewController: CommonViewController {

    //MARK: -------------------VARIABLE
//    var shopCatData:[HydrationDataModel]?
    var shopCatData:[[String:Any]]?
    var player: LoopingPlayer?
    
    
    //MARK :-------------------IBOUTLET
    @IBOutlet weak var productsSearch: UISearchBar!
    @IBOutlet weak var shopCategoryMBV: UIView!
    @IBOutlet weak var trendingProductsMBV: UIView!
    @IBOutlet weak var featuredProducts: UIView!
    @IBOutlet weak var addsMBV: UIView!
    @IBOutlet weak var frequentlyPurchasedItemsMBV: UIView!
    @IBOutlet weak var exclusiveMBV: UIView!
    @IBOutlet weak var exploreMoreproductsMBV: UIView!
    @IBOutlet weak var timeStackV: UIStackView!
    @IBOutlet weak var timeStckMBV: UIView!
    @IBOutlet weak var hoursMBV: UIView!
    @IBOutlet weak var minutesMBV: UIView!
    @IBOutlet weak var secMBV: UIView!
    @IBOutlet weak var bottomVideoMBV: UIView!

    @IBOutlet weak var shopCategoryTitleLbl: UILabel!
    @IBOutlet weak var trendingProductsTitleLbl: UILabel!
    @IBOutlet weak var featuredProductsTitleLbl: UILabel!
    @IBOutlet weak var purchaseItemsTitleLbl: UILabel!
    @IBOutlet weak var exclusiveDealTitleLbl: UILabel!
    @IBOutlet weak var trendingProductMoreBtn: UIButton!
    @IBOutlet weak var featureProductMoreBtn: UIButton!
    @IBOutlet weak var purchasedItemsMoreBtn: UIButton!
    @IBOutlet weak var exploreMoreProductsBtn: UIButton!
    @IBOutlet weak var hoursBtn: UIButton!
    @IBOutlet weak var minutesBtn: UIButton!
    @IBOutlet weak var secBtn: UIButton!
    
    @IBOutlet weak var shopCatoryCollView: UICollectionView!
    @IBOutlet weak var shopSubCatoryCollView: UICollectionView!
    @IBOutlet weak var trendingProductsCollView: UICollectionView!
    @IBOutlet weak var featuredProductsCollView: UICollectionView!
    @IBOutlet weak var addsCollView: UICollectionView!
    @IBOutlet weak var purchasedItemsCollView: UICollectionView!
    @IBOutlet weak var exclusiveDealCollView: UICollectionView!
    
    @IBOutlet weak var shopCatPageControl: CustomPageControl!
    @IBOutlet weak var trendingProductsPageControl: CustomPageControl!
    @IBOutlet weak var featuredProductsPageControl: CustomPageControl!
    @IBOutlet weak var purchasedItemsPageControl: CustomPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
        self.setUISearchbar()
        self.setUpCustomPageControl()
        self.setupInputData()
        self.setUpVideo()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
//        let firstIndexPath = IndexPath(item: 2, section: 0)
//        DispatchQueue.main.async {
//            self.exclusiveDealCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//            // Optional: perform any additional setup for the selected cell
//            self.exclusiveDealCollView.delegate?.collectionView?(self.exclusiveDealCollView, didSelectItemAt: firstIndexPath)
//            self.view.layoutIfNeeded()
//        }
    }
    
    //MARK: -----------------COMMON BTN ACTN
    enum btnTag: Int {
    case shopCategory = 801, trendingProducts, featuredProducts, purchasedItems, exploreMoreProducts
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case btnTag.shopCategory.rawValue:
            print("shop category btn clicked")
        case btnTag.trendingProducts.rawValue:
            print("trending products")
            let vc: OrderRefundViewController = OrderRefundViewController.instantiate(appStoryboard: .shop) // only for testing
//            let vc: ReturnRequestViewController = ReturnRequestViewController.instantiate(appStoryboard: .shop)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case btnTag.featuredProducts.rawValue:
            print("featured products clicked.")
            let vc: ProductsViewController = ProductsViewController.instantiate(appStoryboard: .shop)
            self.navigationController?.pushViewController(vc, animated: true)
        case btnTag.purchasedItems.rawValue:
            print("purchaseed items")
        case btnTag.exploreMoreProducts.rawValue:
            print("Explore more products")
            
        default:
            break
        }
    }
    
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.shop], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupInputData(){
        
        self.shopCatData = [
            [
                "title":"Fitness Equipment",
                "img":"ic_strength",
                "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 27.0/255.0, green: 47.0/255.0, blue: 76.0/255.0, alpha: 1.0)]
            ],
            [
                "title":"Home Gym Essentials",
                "img":"ic_bicycling",
                "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 27.0/255.0, green: 76.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
            ],
            [
                "title":"Apparel & Accessories",
                "img":"ic_endurance",
                "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 76.0/255.0, green: 62.0/255.0, blue: 27.0/255.0, alpha: 1.0)]
            ],
            [
                "title":"Supplements & Nutrition",
                "img":"ic_yoga",
                "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 76.0/255.0, green: 27.0/255.0, blue: 62.0/255.0, alpha: 1.0)]
            ]
        ]
        
        self.shopCatoryCollView.reloadData()
        
        /*
        shopCatData = [
            HydrationDataModel(subTitle: "Fitness Equipment", qnty: ""),
            HydrationDataModel(subTitle: "Home Gym Essentials", qnty: ""),
            HydrationDataModel(subTitle: "Apparel & Accessories", qnty: ""),
            HydrationDataModel(subTitle: "Supplements & Nutrition", qnty: ""),
        ]
        */
    }
    
    //MARK: --------------SETUP page controll
    func setUpCustomPageControl(){
        
        [
            self.shopCatPageControl,
            self.trendingProductsPageControl,
            self.featuredProductsPageControl,
            self.purchasedItemsPageControl
        ].forEach({
            $0?.activeDotSize =  CGSize(width: 26, height: 8)
            $0?.currentDotColor = UIColor.appWhite
            $0?.defaultDotColor = UIColor.txtDarkGray
        })
        
        self.shopCatPageControl.numberOfPages = 3  // Set the total number of pages
        self.shopCatPageControl.currentPage = 0    // Set the initial page
       
        self.trendingProductsPageControl.numberOfPages = 3  // Set the total number of pages
        self.trendingProductsPageControl.currentPage = 0    // Set the initial page
        self.featuredProductsPageControl.numberOfPages = 3  // Set the total number of pages
        self.featuredProductsPageControl.currentPage = 0    // Set the initial page
        self.purchasedItemsPageControl.numberOfPages = 3  // Set the total number of pages
        self.purchasedItemsPageControl.currentPage = 0    // Set the initial page
        
//        self.shopCatPageControl.activeDotSize = CGSize(width: 26, height: 8)
//        self.shopCatPageControl.currentDotColor = UIColor.appWhite
//        self.shopCatPageControl.defaultDotColor = UIColor.txtDarkGray
        
        //-------------------*********** trendingProductsPageControl
       
//        self.trendingProductsPageControl.activeDotSize = CGSize(width: 26, height: 8)
//        self.trendingProductsPageControl.currentDotColor = UIColor.appWhite
//        self.trendingProductsPageControl.defaultDotColor = UIColor.txtDarkGray
        
        //-------------------*********** featuredProductsPageControl
      
//        self.featuredProductsPageControl.activeDotSize = CGSize(width: 26, height: 8)
//        self.featuredProductsPageControl.currentDotColor = UIColor.appWhite
//        self.featuredProductsPageControl.defaultDotColor = UIColor.txtDarkGray
        
        //-------------------*********** purchasedItemsPageControl
 
//        self.purchasedItemsPageControl.activeDotSize = CGSize(width: 26, height: 8)
//        self.purchasedItemsPageControl.currentDotColor = UIColor.appWhite
//        self.purchasedItemsPageControl.defaultDotColor = UIColor.txtDarkGray
        
     

    }
    
    //MARK: --------------FOR VIDEO PLAHY
    func setUpVideo(){
        //MyPTGems.mp4 //shopBottom.mov
        if let filePath = Bundle.main.path(forResource: "shopBottom", ofType: "mov") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Initialize LoopingPlayer
            player = LoopingPlayer(url: fileURL)
            player?.progressDelegate = self
            
            // Add video layer
            if let player = player {
                let playerLayer = AVPlayerLayer(player: player)
                DispatchQueue.main.async {
                    playerLayer.frame = self.bottomVideoMBV.bounds
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    playerLayer.zPosition = -1
                    self.bottomVideoMBV.layer.addSublayer(playerLayer)
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
 
    func setupUI(){
        self.shopSubCatoryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        self.addsCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        shopCatoryCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        shopSubCatoryCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        trendingProductsCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        featuredProductsCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        purchasedItemsCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
                
        exclusiveDealCollView.register(UINib(nibName: "ExclusiveDealCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExclusiveDealCollectionViewCell")
        
        DispatchQueue.main.async {
            self.productsSearch.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.exploreMoreProductsBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            
            self.featuredProducts.addGradient(colors: UIColor.appMultiColor(.magentaGradient), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
            self.featuredProducts.setGradientBorder(cornerRadious: 0, width: 2, colors: UIColor.appMultiColor(.topBottomGradient), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
            self.timeStckMBV.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor.appBorder.withAlphaComponent(0.2), offSet: CGSize(width: 0, height: -5), opacity: 0.8, shadowRadius: 0.4, cornerRadious: 9.54)
          
            [
                self.hoursBtn, self.minutesBtn, self.secBtn
            ].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.54)
                $0?.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 9.54)
            })
            
        }
    }
    
    func setUISearchbar(){
        self.productsSearch.barTintColor = UIColor.clear
        self.productsSearch.isTranslucent = false
        self.productsSearch.backgroundColor = .clear
        self.productsSearch.searchTextField.backgroundColor = .clear
        self.productsSearch.layer.borderWidth = 1.0
        self.productsSearch.layer.borderColor = UIColor.txtDarkGray.cgColor
                
        self.productsSearch.setImage(UIImage(named: "ic_search_normal"), for: .search, state: .normal)
        
         if let searchTextField = self.productsSearch.value(forKey: "searchField") as? UITextField {
             searchTextField.backgroundColor = UIColor.clear
             searchTextField.textColor = UIColor.appWhite
             searchTextField.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: "Products", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
         }
    }
    
    
    func setupFont(){
        [
            self.shopCategoryTitleLbl,
            self.trendingProductsTitleLbl,
            self.featuredProductsTitleLbl,
            self.purchaseItemsTitleLbl,
            self.exclusiveDealTitleLbl
        ].forEach({
            $0?.font = AppFont.medium.size(16.0, familyName: familyManrope)
        })
        
        self.exploreMoreProductsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
}

//MARK: ------------------------------------- UICOLLECTIONVIEW  DELEGATE/ DATASOURCE
extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shopCatoryCollView {
            return shopCatData?.count ?? 0
        }else if collectionView == exclusiveDealCollView{
            return 15
        }
        else{
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == shopCatoryCollView{
            let cell: MoreExploreCollectionViewCell = shopCatoryCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
            
            cell.imgBgCover.isHidden = false
            DispatchQueue.main.async {
                cell.imgBgCover.addGradient(colors: self.shopCatData?[indexPath.row]["gredientColor"] as? [UIColor] ?? [.red,.green] , locations: [0,1], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            }
            
            cell.titleLbl.text = shopCatData?[indexPath.row]["title"] as? String
            cell.categoryImgView.image = UIImage(named: shopCatData?[indexPath.row]["img"] as? String ?? "")
            
            cell.categoryImgView.applyTransition(type: .moveIn, subtype: .fromTop, duration: 0.3, timingFunction: .easeInEaseOut) {
                //animation is done.
            }
            
            return cell
        }
        else if collectionView == shopSubCatoryCollView{
            let cell: WithMeCollectionViewCell = shopSubCatoryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.centerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            cell.videoThumbnailImgView.isHidden = false
            cell.centerImgView.isHidden = true
            cell.videoThumbnailImgView.image = UIImage(named: "ic_shopBanner")
            cell.videoThumbnailImgView.contentMode = .scaleToFill
            
            return cell
        }
        else if collectionView == trendingProductsCollView {
            let cell: ProductsListCollViewCell = trendingProductsCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.cellMBV.setGradientBorder(cornerRadious: 12.0, width: 1.0, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            cell.ratingBtn.isHidden = true
            return cell
        }
        else if collectionView == featuredProductsCollView{
            let cell: ProductsListCollViewCell = featuredProductsCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.cellMBV.setGradientBorder(cornerRadious: 12.0, width: 1.0, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            cell.ratingBtn.isHidden = true
            
            return cell
        }
        else if collectionView == addsCollView{
            let cell: WithMeCollectionViewCell = addsCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.centerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            cell.videoThumbnailImgView.isHidden = false
            cell.centerImgView.isHidden = true
            cell.videoThumbnailImgView.image = UIImage(named: "ic_shopAdds")
            cell.videoThumbnailImgView.contentMode = .scaleToFill
            
            return cell
        }
        else if collectionView == purchasedItemsCollView{
            let cell: ProductsListCollViewCell = purchasedItemsCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.cellMBV.setGradientBorder(cornerRadious: 12.0, width: 1.0, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            cell.ratingBtn.isHidden = true
            
            return cell
        }
        else if collectionView == exclusiveDealCollView{
            let cell: ExclusiveDealCollectionViewCell = exclusiveDealCollView.dequeueReusableCell(withReuseIdentifier: "ExclusiveDealCollectionViewCell", for: indexPath) as! ExclusiveDealCollectionViewCell
//            DispatchQueue.main.async {
//                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
//                cell.centerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
////                cell.cellMBV.backgroundColor = UIColor.red
//            }
//            cell.videoThumbnailImgView.isHidden = false
//            cell.centerImgView.isHidden = true
//            cell.videoThumbnailImgView.image = UIImage(named: "ic_shopAdds")
//            cell.videoThumbnailImgView.contentMode = .scaleToFill
            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc: ProductsViewController = ProductsViewController.instantiate(appStoryboard: .shop)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.getScroll(currentScroll: scrollView)
      }
    
    //MARK: ------------------For page control
    func getScroll(currentScroll: UIScrollView){
        let collectionPageMap: [UICollectionView: CustomPageControl] = [
              shopSubCatoryCollView: shopCatPageControl,
              trendingProductsCollView: trendingProductsPageControl,
              featuredProductsCollView: featuredProductsPageControl,
              purchasedItemsCollView: purchasedItemsPageControl
          ]
          
          if let collectionView = collectionPageMap.keys.first(where: { $0 == currentScroll }),
             let pageControl = collectionPageMap[collectionView] {
              let centerPoint = CGPoint(x: collectionView.bounds.midX + collectionView.contentOffset.x,
                                        y: collectionView.bounds.midY + collectionView.contentOffset.y)
              
              if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
                  pageControl.currentPage = indexPath.row
              }
          }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == shopCatoryCollView {
            return CGSize(width: collectionView.frame.size.width * 0.2, height: collectionView.frame.size.height)
        }
        else if collectionView == shopSubCatoryCollView || collectionView == addsCollView{
            return CGSize(width: collectionView.frame.size.width * 0.88, height: collectionView.frame.size.height)
        }
        else if collectionView == exclusiveDealCollView{
            return CGSize(width: collectionView.frame.size.width * 0.63, height: collectionView.frame.size.height)
        }
        else {
            return CGSize(width: collectionView.frame.size.width * 0.45, height: collectionView.frame.size.height)
        }
    }
    
    //MARK: -----------------USED FOR MAKE CENTER ANUIMATED CELL OF UICOLLECION VIEW
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Simulate "Page" Function
        if scrollView == self.exclusiveDealCollView {
            let pageWidth: Float = Float(self.exclusiveDealCollView.frame.width * 0.63)
            let currentOffset: Float = Float(scrollView.contentOffset.x)
            let targetOffset: Float = Float(targetContentOffset.pointee.x)
            var newTargetOffset: Float = 0
            if targetOffset > currentOffset {
                newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
            }
            else {
                newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
            }
            if newTargetOffset < 0 {
                newTargetOffset = 0
            }
            else if (newTargetOffset > Float(scrollView.contentSize.width)){
                newTargetOffset = Float(Float(scrollView.contentSize.width))
            }
            
            targetContentOffset.pointee.x = CGFloat(currentOffset)
            scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
            
            // Make Transition Effects for cells
            let duration = 0.2
            var index = newTargetOffset / pageWidth;
            var cell:UICollectionViewCell = self.exclusiveDealCollView.cellForItem(at: IndexPath(row: Int(index), section: 0)) ?? UICollectionViewCell()
            if (index == 0) { // If first index
                UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: nil)
                index += 1
                cell = self.exclusiveDealCollView.cellForItem(at: IndexPath(row: Int(index), section: 0))!
                UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                    cell.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
                }, completion: nil)
            }else{
                UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                    cell.transform = CGAffineTransform.identity;
                }, completion: nil)
                
                index -= 1 // left
                if let cell = self.exclusiveDealCollView.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                    UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                        cell.transform = CGAffineTransform(scaleX: 1.0, y: 0.8);
                    }, completion: nil)
                }
                
                index += 1
                index += 1 // right
                if let cell = self.exclusiveDealCollView.cellForItem(at: IndexPath(row: Int(index), section: 0)) {
                    UIView.animate(withDuration: duration, delay: 0.0, options: [ .curveEaseOut], animations: {
                        cell.transform = CGAffineTransform(scaleX: 1.0, y: 0.8);
                    }, completion: nil)
                }
            }
        }

    }
    
}


extension ShopViewController: LoopingPlayerProgressDelegate{
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}
