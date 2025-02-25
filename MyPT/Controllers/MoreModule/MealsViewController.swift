//
//  MealsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/02/25.
//

import UIKit

class MealsViewController: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var showDateCollView: UICollectionView!
    @IBOutlet weak var mealsLstTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showDateCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        mealsLstTblView.register(UINib(nibName: "MealsTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "MealsTypeTableViewCell")
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["My Meals"], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [UIImage(named: "ic_mostPopularchart")], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.showDateCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.showDateCollView.delegate?.collectionView?(self.showDateCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: ------------------UICOLLECTIONVIEW DELEGATE/ DATASOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = showDateCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.titleLbl.text = "03 Sep, Wed"
        cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        cell.titleLbl.textColor = UIColor.appWhite
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    //MARK: ------------------UITABLEVIEW DELEGATE/ DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MealsTypeTableViewCell = mealsLstTblView.dequeueReusableCell(withIdentifier: "MealsTypeTableViewCell", for: indexPath) as! MealsTypeTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc:HydrationViewViewController = HydrationViewViewController.instantiate(appStoryboard: .more)
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


