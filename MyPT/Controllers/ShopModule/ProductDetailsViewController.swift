//
//  ProductDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/02/25.
//

import UIKit

class ProductDetailsViewController: CommonViewController {

    //MARK: ------------------VARIABLE
    var isOutOfStock:Bool?

    
    //MARK: -------------------IBOUTLET
    @IBOutlet weak var productBannerCollView: UICollectionView!
    @IBOutlet weak var chooseColorCollView: UICollectionView!
    @IBOutlet weak var similarProductsCollView: UICollectionView!
    @IBOutlet weak var bannerPageCtrnl: CustomPageControl!
    @IBOutlet weak var offerPerBtn: UIButton!
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var checkDelivaryDateBtn: UIButton!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var chooseColorLbl: UILabel!
    @IBOutlet weak var delivaryDetailsTitleLbl: UILabel!
    @IBOutlet weak var productDetailsTitleLbl: UILabel!
    @IBOutlet weak var productDetailsDescLbl: UILabel!
    @IBOutlet weak var similarProductTitleLbl: UILabel!
     
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupUI()
        self.setupFont()
        self.setUpCustomPageControl()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.product], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.shareGymWorkout], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    override func rightBtnActn(sender: UIButton) {
        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
    }
    
    @IBAction func checkDelivaryDateBtnActn(_ sender: Any) {
        let vc: SelectAddressPopupViewController = SelectAddressPopupViewController.instantiate(appStoryboard: .shop)
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
    
    
    @IBAction func addToCartBtnActn(_ sender: Any) {
        let vc: CheckoutCartViewController = CheckoutCartViewController.instantiate(appStoryboard: .shop)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    //MARK: --------------SETUP page controll
    func setUpCustomPageControl(){
        self.bannerPageCtrnl.activeDotSize =  CGSize(width: 30, height: 6)
        self.bannerPageCtrnl.currentDotColor = UIColor.appWhite
        self.bannerPageCtrnl.defaultDotColor = UIColor.txtDarkGray
        self.bannerPageCtrnl.numberOfPages = 3  // Set the total number of pages
        self.bannerPageCtrnl.currentPage = 0    // Set the initial page
    }
    
    func setupUI(){
    
        productBannerCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        chooseColorCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        similarProductsCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        
        
        let title = "CHECK DELIVERY DATE"
        let attributedString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                         .underlineColor: UIColor.txtDarkGray, .foregroundColor: UIColor.txtDarkGray,
                         .font: AppFont.regular.size(12.0, familyName: familyManrope)
            ]
        )
        self.checkDelivaryDateBtn.setAttributedTitle(attributedString, for: .normal)
        
        //----------------------****************
        DispatchQueue.main.async {
            self.offerPerBtn.addGradient(colors: UIColor.appMultiColor(.greenGradient), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: self.offerPerBtn.frame.size.height/2.0)
            self.offerPerBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.offerPerBtn.frame.size.height/2.0)
            self.addToCartBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        //---------------------***************
        
        if let isOutOfStock = isOutOfStock, isOutOfStock {
            self.addToCartBtn.isUserInteractionEnabled = false
            self.addToCartBtn.setTitle("OUT OF STOCK", for: .normal)
            self.addToCartBtn.setTitleColor(UIColor.appLightGray, for: .normal)
            self.addToCartBtn.backgroundColor = UIColor.appDarkGray
        }else{
            self.addToCartBtn.isUserInteractionEnabled = true
            self.addToCartBtn.setTitle("ADD TO CART", for: .normal)
            self.addToCartBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.addToCartBtn.backgroundColor = UIColor.appWhite
        }
    }
    
    func setupFont(){
        self.productNameLbl.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.offerPerBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.addToCartBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.checkDelivaryDateBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyManrope)
       
        self.productDetailsDescLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        
        [
            self.chooseColorLbl,
            self.delivaryDetailsTitleLbl,
            self.productDetailsTitleLbl,
            self.similarProductTitleLbl,
        ].forEach({
            $0?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        })
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(32.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(32.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes), "329AED".strikeThrough(with: AppFont.medium.size(16.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
        ] as [AttributedStringComponent]
        
        self.productPriceLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }

}

//MAR: -------------------------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension ProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productBannerCollView {
            return 3
        }else{
            return 5
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == productBannerCollView {
            let cell: WithMeCollectionViewCell = productBannerCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
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
        else if collectionView == chooseColorCollView{
            let cell: MoreExploreCollectionViewCell = chooseColorCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
            
            cell.imgBgCover.isHidden = false
            DispatchQueue.main.async {
                cell.imgBgCover.addGradient(colors: UIColor.appMultiColor(.gradientColor) , locations: [0,1], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
                cell.categoryImgView.setCornerRadius(borderWidth: 0.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            }
            
            cell.titleLbl.text = "red"
            cell.titleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
//            cell.categoryImgView.image = UIImage(named: "")
            
            return cell
        }
        else if collectionView == similarProductsCollView {
            let cell: ProductsListCollViewCell = similarProductsCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.cellMBV.setGradientBorder(cornerRadious: 12.0, width: 1.0, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            cell.ratingBtn.isHidden = true
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == chooseColorCollView {
            let deselectedcell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell
            print("deselected indexpath row= ", indexPath.row)
            guard let deselectedcell = deselectedcell else { return }
            deselectedcell.categoryImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == chooseColorCollView {
            let deselectedcell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell
            print("deselected indexpath row= ", indexPath.row)
            guard let deselectedcell = deselectedcell else { return }
            deselectedcell.categoryImgView.setCornerRadius(borderWidth: 0.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == productBannerCollView{
            return CGSize(width: collectionView.frame.size.width * 0.88, height: collectionView.frame.size.height)
        }else if collectionView == chooseColorCollView{
            return CGSize(width: collectionView.frame.size.width * 0.2, height: collectionView.frame.size.height)
        }
        else{
            return CGSize(width: collectionView.frame.size.width * 0.45, height: collectionView.frame.size.height)
        }
        
    }
    
    //MARK: ------------------For page control
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == productBannerCollView{
            let centerPoint = CGPoint(x: productBannerCollView.bounds.midX + productBannerCollView.contentOffset.x,
                                            y: productBannerCollView.bounds.midY + productBannerCollView.contentOffset.y)
                  
            if let indexPath = productBannerCollView.indexPathForItem(at: centerPoint) {
                bannerPageCtrnl.currentPage = indexPath.row
            }
        }
      }
    
}
