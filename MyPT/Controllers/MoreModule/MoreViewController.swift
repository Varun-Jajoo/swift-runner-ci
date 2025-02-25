//
//  MoreViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit

class MoreViewController: UIViewController {
    
    //MARK: --------------VARIABLE
//    var sectionData:[String]?
    var moreSectionData:[HydrationModel]?
    

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var exploreCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        // Configure the collection view layout
//        DispatchQueue.main.async {
//            let layout = UICollectionViewFlowLayout()
//            layout.headerReferenceSize = CGSize(width: self.exploreCollView.frame.size.width-20, height: 50) // Set header size
//            self.exploreCollView.collectionViewLayout = layout
//        }
      
        
//        sectionData = [
//            "Fitness & Progress",
//            "My Network",
//            "Account Management",
//            "Support",
//            "E-commerce"
//        ]
        
        
        //---------------------*******************
        exploreCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        
        exploreCollView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomHeaderView.identifier)
        
        self.setupInputData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func setupInputData(){
        self.moreSectionData = [
            HydrationModel(title: "Fitness & Progress", items:[
                HydrationDataModel(subTitle: AppStrings.my_Goals, qnty: "ic_myGoals"),
                HydrationDataModel(subTitle: AppStrings.my_Bookings, qnty: "ic_myBookings_more"),
                 HydrationDataModel(subTitle: AppStrings.my_health_stats, qnty: "ic_MyHealth_Stats"),
                HydrationDataModel(subTitle: AppStrings.my_milestone, qnty: "ic_MyMilestone"),
                HydrationDataModel(subTitle: AppStrings.my_meals, qnty: "ic_meals_more"),
                HydrationDataModel(subTitle: AppStrings.workout_Library, qnty: "ic_WorkoutLibrary_more"),
                HydrationDataModel(subTitle: AppStrings.my_favourite_workouts, qnty: "ic_MyFavourite_Workouts")
            ]
            ),
            HydrationModel(title: "My Network", items:[
                HydrationDataModel(subTitle: AppStrings.my_trainers, qnty: "ic_trainer_more"),
                HydrationDataModel(subTitle: AppStrings.chats, qnty: "ic_chats"),
                HydrationDataModel(subTitle: AppStrings.find_gym, qnty: "ic_find_gym"),
                HydrationDataModel(subTitle: AppStrings.find_trainer, qnty: "ic_find_trainer")
            ]
            ),
            HydrationModel(title: "Account Management", items:[
                HydrationDataModel(subTitle: AppStrings.profile, qnty: "ic_profile_more"),
                HydrationDataModel(subTitle: AppStrings.settings, qnty: "ic_settings_more"),
                HydrationDataModel(subTitle: AppStrings.payment_history, qnty: "ic_Payment_History")
            ]
            ),
            HydrationModel(title: "Support", items:[
                HydrationDataModel(subTitle: AppStrings.help_support, qnty: "ic_help_support")
            ]
            ),
            HydrationModel(title: "E-commerce", items:[
                HydrationDataModel(subTitle: AppStrings.shop, qnty: "ic_shop_more"),
                HydrationDataModel(subTitle: AppStrings.my_orders, qnty: "ic_noSessions"),
                HydrationDataModel(subTitle: AppStrings.cart, qnty: "ic_cart_more")
            ]
            )
        ]
        
        self.exploreCollView.reloadData()
    }
}


extension MoreViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    // Number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return moreSectionData?.count ?? 0 //sectionData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreSectionData?[section].items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MoreExploreCollectionViewCell = exploreCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
        cell.titleLbl.text = moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String
        cell.categoryImgView.image = UIImage(named: moreSectionData?[indexPath.section].items[indexPath.row].qnty as? String ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.20, height: collectionView.frame.width*0.35)
        
//        return CGSize(width: collectionView.frame.width*0.20, height: collectionView.frame.width*0.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.my_Goals.uppercased() {
            let vc: MyGoalsViewController = MyGoalsViewController.instantiate(appStoryboard: .more)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.my_meals.uppercased() {
            
            let vc: MealsViewController = MealsViewController.instantiate(appStoryboard: .more)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (moreSectionData?[indexPath.section].items[indexPath.row].subTitle as? String)?.uppercased() == AppStrings.shop.uppercased() {
            
            let vc: ShopViewController = ShopViewController.instantiate(appStoryboard: .shop)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //        let vc: MyGoalsViewController = MyGoalsViewController.instantiate(appStoryboard: .more)
        //
        ////        let vc:HydrationViewViewController = HydrationViewViewController.instantiate(appStoryboard: .more)
        //
        ////        let vc:DummyRulerViewController = DummyRulerViewController.instantiate(appStoryboard: .more)
        //
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Header configuration
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomHeaderView.identifier, for: indexPath) as! CustomHeaderView
            
            header.configure(text: moreSectionData?[indexPath.section].title as? String ?? "")
//            header.configure(text: sectionData?[indexPath.section] as? String ?? "")
            
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
}




