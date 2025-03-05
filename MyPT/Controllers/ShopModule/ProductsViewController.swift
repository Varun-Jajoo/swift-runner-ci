//
//  ProductsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/02/25.
//

import UIKit

class ProductsViewController: CommonViewController {

    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var productsCollView: UICollectionView!
    @IBOutlet weak var sortByMStck: UIStackView!
    @IBOutlet weak var sortByBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var lineLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        productsCollView.register(FooterProductsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterProductsCollectionReusableView.identifier)
        
        productsCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.myPT_Products], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func sortByBtnAct(_ sender: Any) {
        print("sort by btn")
        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.planFlowSetup = .productSortBy
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func filterBtnActn(_ sender: Any) {
        print("filter btn atcn.")
        let vc: ProductsFilterViewController = ProductsFilterViewController.instantiate(appStoryboard: .shop)
        vc.sendBackCount = {[weak self] getCount in
            guard let self = self else { return  }
            if let getCount = getCount, getCount != 0 {
                self.filterBtn.setTitle("FILTER(\(getCount))", for: .normal)
            }else{
                self.filterBtn.setTitle("FILTER", for: .normal)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setupUI(){
        
        self.sortByBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.filterBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.sortByMStck.roundSideCorners(radius: 20.0, cornerSide: [.topLeft, .topRight])
            self.sortByMStck.setGradientBorder(cornerRadious: 20.0, width: 1.0, colors: [UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            self.lineLbl.addGradient(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0.2), UIColor(red: 190.0/255.0, green: 204.0/255.0, blue: 212.0/255.0, alpha: 1.0), UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0.2)], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0.5)
        }
        
    }
    
}

extension ProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductsListCollViewCell = productsCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
        
        DispatchQueue.main.async {
            cell.cellMBV.setGradientBorder(cornerRadious: 12.0, width: 1.0, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            cell.ratingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            cell.ratingBtn.backgroundColor = UIColor(red: 160.0/255.0, green: 124.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            cell.ratingBtn.addBlurView(viewShow: cell.ratingBtn, alphBlur: 1.0, bgColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.15))
        }
        
        cell.ratingBtn.isHidden = true
        
        if indexPath.row % 3 == 0 {
            cell.ratingBtn.isHidden = false
            cell.ratingBtn.setImage(nil, for: .normal)
            cell.ratingBtn.setTitle("Out of Stack", for: .normal)
            cell.ratingBtn.accessibilityHint = "Out of Stack"
            cell.ratingBtn.setTitleColor(UIColor.appWhite, for: .normal)
            cell.ratingBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
            //rgba(160, 124, 0, 1)
        }else{
            cell.ratingBtn.accessibilityHint = nil
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell: ProductsListCollViewCell = collectionView.cellForItem(at: indexPath) as! ProductsListCollViewCell
        
        let vc: ProductDetailsViewController = ProductDetailsViewController.instantiate(appStoryboard: .shop)
       
        if cell.ratingBtn.accessibilityHint?.uppercased() == "Out of Stack".uppercased() {
            vc.isOutOfStock = true
        }else{
            vc.isOutOfStock = false
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FooterProductsCollectionReusableView.identifier, for: indexPath) as! FooterProductsCollectionReusableView

            footerView.addsImgView.image = UIImage(named: "ic_productsAdds")
            
              return footerView
            
          }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCell = collectionView.frame.size.width * 0.435
        
        return CGSize(width: widthCell, height: widthCell * 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        let lastSection = collectionView.numberOfSections - 1
        
        if section == lastSection {
            return CGSize(width: collectionView.frame.width * 0.088, height: 0)
        }else{
            return CGSize(width: collectionView.frame.width * 0.088, height: 174)
        }
    }
   
}
