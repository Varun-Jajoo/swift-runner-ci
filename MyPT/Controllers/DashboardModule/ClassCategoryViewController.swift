//
//  ClassCategoryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/05/25.
//

import UIKit

class ClassCategoryViewController: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
//    var getLat: String?
//    var getLong: String?
    var classesWithCategoryData: [ClassesWithCategoryModel]? = []
    
    @IBOutlet weak var classCategoryCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        classCategoryCollView.register(UINib(nibName: "ClassCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClassCategoryCollectionViewCell")
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Classes Category"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //-------------******** Delegate/ Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.numberOfRows(count: self.classesWithCategoryData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 210, height: 210)), fromCenter: -100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell: ClassCategoryCollectionViewCell = classCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ClassCategoryCollectionViewCell", for: indexPath) as! ClassCategoryCollectionViewCell
        categoryCell.setCellData(cellData: classesWithCategoryData?[indexPath.row])
        
        return categoryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: CategoryWiseClassesViewController = CategoryWiseClassesViewController.instantiate(appStoryboard: .dashboard)
        vc.categoryIdStr = "\(self.classesWithCategoryData?[indexPath.row].categoryID ?? 0)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width*0.44, height: 190)
    }
    
}
