//
//  ExerciseFilterPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/12/24.
//

import UIKit

enum ExerciseFilterPopupFlow {
    case muscles
    case equipment
    case filterDefault
}

class ExerciseFilterPopupViewController: UIViewController {

    //MARK: --------------VARIABLE
    var sectionData:[String]?
    var setupExerciseFilterFlow:ExerciseFilterPopupFlow = .filterDefault
    
    var sentBackFilterData:((_ bodyPartsFilter: [WorkoutAllcategoryModel]?, _ equipmentFilter: [WorkoutAllcategoryModel]?) -> Void)?
    var localBodyPartsData: [WorkoutAllcategoryModel]? = []
    var localWorkoutsCategory: [WorkoutAllcategoryModel]? = []
    var bodyPartsData:[WorkoutAllcategoryModel]? = []
    var workoutsCategory: [WorkoutAllcategoryModel]? = []
    var selectedItems: [Int] = []
    
    
    //MARK: ------------IBOIUTLET
    @IBOutlet weak var exerciseFilterpopupMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var filterCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupFont()
        self.setupInputData()
        self.filterCollView.allowsMultipleSelection = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
   
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    func setupUI(){
        
        DispatchQueue.main.async {
            self.exerciseFilterpopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.exerciseFilterpopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.filterCollView.applyShadow(fillColor: UIColor.clear, shadowColor: UIColor.black, shadowRadius: 4.0, opacity: 0.7, offset: .zero, cornerRadius: 0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.clearBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.applyBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
    func setupInputData(){
      
    
        //---------------------*******************
        filterCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        filterCollView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomHeaderView.identifier)
        
        
        //---------------****************** Flow setup
        switch setupExerciseFilterFlow {
        case .muscles:
            //Muscles
            //Equipment
            self.topTitleLbl.text = "Muscles"
//            sectionData = [
//                "Upper Body",
//                "Lower Body"
//            ]
            self.filterCollView.reloadData()
            self.getBodypartsApi()
            
        case .equipment:
            self.topTitleLbl.text = "Equipment"
//            sectionData = [""]
            self.filterCollView.reloadData()
            self.getAllEquipmentApi()
            
        case .filterDefault:
            print("default is callled...")
        }
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton){
        print("common btn clicked..")
        if sender.tag == 201 {
            print("top bar clicked..")
        }
        else if sender.tag == 202 {
            print("clear btn clicked...")
            switch setupExerciseFilterFlow {
            case .muscles:
                self.localBodyPartsData?.removeAll()
                self.dismiss(animated: true, completion: {[weak self] in
                print("dismiss popup view....")
                    self?.sentBackFilterData?(self?.localBodyPartsData, self?.localWorkoutsCategory)
                })
                break
            case .equipment:
                self.localWorkoutsCategory?.removeAll()
                self.dismiss(animated: true, completion: {[weak self] in
                print("dismiss popup view....")
                    self?.sentBackFilterData?(self?.localBodyPartsData, self?.localWorkoutsCategory)
                })
                break
            case .filterDefault:
                print("default is callled...")
                break
            }
        }
        else if sender.tag == 203 {
            print("apply btn clicked...")
            self.dismiss(animated: true, completion: {[weak self] in
            print("dismiss popup view....")
                self?.sentBackFilterData?(self?.localBodyPartsData, self?.localWorkoutsCategory)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.exerciseFilterpopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }

}

//MARK: ----------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension ExerciseFilterPopupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /*
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionData?.count ?? 0
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        
        switch setupExerciseFilterFlow {
        case .muscles:
            return bodyPartsData?.count ?? 0
        case .equipment:
            return workoutsCategory?.count ?? 0
        case .filterDefault:
            print("default is callled...")
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MoreExploreCollectionViewCell = filterCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
        
        DispatchQueue.main.async {
            cell.backgroundColor = UIColor.clear
            cell.titleLbl.backgroundColor = UIColor.clear
            cell.categoryImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 96.0/255.0, green: 96.0/255.0, blue: 96.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            cell.categoryImgView.contentMode = .scaleToFill
        }
        
        cell.titleLbl.textColor = UIColor.appWhite
//        cell.categoryImgView.loadImage(urlString: bodyPartsData?[indexPath.row].image?.value, placeholder: UIImage(named: "ic_userBck"))
//        cell.titleLbl.text = bodyPartsData?[indexPath.row].name?.value
        
        switch setupExerciseFilterFlow {
        case .muscles:
            cell.categoryImgView.loadImage(urlString: bodyPartsData?[indexPath.row].image?.value, placeholder: UIImage(named: "ic_userBck"))
            cell.titleLbl.text = bodyPartsData?[indexPath.row].name?.value
            
            //---------------for make already selected cell
            let alreadySelectedDodyParts = bodyPartsData?[indexPath.row]
            if let alreadySelectedDodyPartsData = alreadySelectedDodyParts {
                let alreadySelected = localBodyPartsData?.contains(where: { $0.id?.value == alreadySelectedDodyPartsData.id?.value }) ?? false
                
                if alreadySelected {
                    DispatchQueue.main.async {
                        cell.categoryImgView.setCornerRadius(
                            borderWidth: 1.0,
                            borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                            cornerRadious: 12.0
                        )
                    }
                   
                }else{
                    DispatchQueue.main.async {
                        cell.categoryImgView.setCornerRadius(
                            borderWidth: 1.0,
                            borderColor: UIColor.appBorder,
                            cornerRadious: 12.0
                        )
                    }
                }
            }
            
        case .equipment:
            cell.categoryImgView.loadImage(urlString: workoutsCategory?[indexPath.row].image?.value, placeholder: UIImage(named: "ic_userBck"))
            cell.titleLbl.text = workoutsCategory?[indexPath.row].name?.value
            
            //---------------for make already selected cell
            let alreadySelecteEquipments = workoutsCategory?[indexPath.row]
            if let alreadySelecteEquipmentsData = alreadySelecteEquipments {
                let alreadySelected = localWorkoutsCategory?.contains(where: { $0.id?.value == alreadySelecteEquipmentsData.id?.value }) ?? false
                
                if alreadySelected {
                    DispatchQueue.main.async {
                        cell.categoryImgView.setCornerRadius(
                            borderWidth: 1.0,
                            borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                            cornerRadious: 12.0
                        )
                    }
                   
                }else{
                    DispatchQueue.main.async {
                        cell.categoryImgView.setCornerRadius(
                            borderWidth: 1.0,
                            borderColor: UIColor.appBorder,
                            cornerRadious: 12.0
                        )
                    }
                }
            }
            
        case .filterDefault:
            print("default is callled...")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.3, height: collectionView.frame.width*0.33)
        
//        return CGSize(width: collectionView.frame.width*0.25, height: collectionView.frame.width*0.25)
    }
    
    /*
    // Header configuration
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomHeaderView.identifier, for: indexPath) as! CustomHeaderView
            header.configure(text: sectionData?[indexPath.section] as? String ?? "")
            
            return header
        }
        return UICollectionReusableView()
    }
    */
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 60)
        
        if let sectionCount = sectionData?.count, sectionCount == 1 {
            return CGSize(width: collectionView.frame.width, height: 19)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: 60)
        }
        
        
        /*
        //---------------****************** Flow setup
        switch setupExerciseFilterFlow {
        case .muscles:
            //Muscles
            //Equipment
            self.topTitleLbl.text = "Muscles"
            sectionData = [
                "Upper Body",
                "Lower Body"
            ]
            self.filterCollView.reloadData()
            
        case .equipment:
            self.topTitleLbl.text = "Equipment"
            sectionData = []
            self.filterCollView.reloadData()
            
        case .filterDefault:
            print("default is callled...")
        }
        */
        
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           if !selectedItems.contains(indexPath.row) {
               selectedItems.append(indexPath.row)
           }
           
           if let selectedCell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell {
               selectedCell.categoryImgView.setCornerRadius(
                   borderWidth: 1.0,
                   borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                   cornerRadious: 12.0
               )
               
               //--------------*************
               switch setupExerciseFilterFlow {
               case .muscles:
                   let selectedBodyParts = bodyPartsData?[indexPath.row]

                   if let selectedBodyPartsData = selectedBodyParts {
                       // Check if it's already in selectedBodyParts
                       let alreadySelected = localBodyPartsData?.contains(where: { $0.id?.value == selectedBodyPartsData.id?.value }) ?? false
                       
                       if !alreadySelected {
                           self.localBodyPartsData?.append(selectedBodyPartsData)
                       }else{
                           //----------- deselectedCell It's use when already selected cell
                           selectedCell.categoryImgView.setCornerRadius(
                               borderWidth: 1.0,
                               borderColor: UIColor.appBorder,
                               cornerRadious: 12.0
                           )

                               if let index = localBodyPartsData?.firstIndex(where: { $0.id?.value == selectedBodyPartsData.id?.value}) {
                                   localBodyPartsData?.remove(at: index)
                               }
                       }
                   }
                   
               case .equipment:
                   let selectedEquipment = workoutsCategory?[indexPath.row]
                   if let selectedEquipmentData = selectedEquipment {
                       // Check if it's already in selectedBodyParts
                       let alreadySelected = localWorkoutsCategory?.contains(where: { $0.id?.value == selectedEquipmentData.id?.value }) ?? false
                       
                       if !alreadySelected {
                           self.localWorkoutsCategory?.append(selectedEquipmentData)
                       }else{
                           //----------- deselectedCell It's use when already selected cell
                           selectedCell.categoryImgView.setCornerRadius(
                            borderWidth: 1.0,
                            borderColor: UIColor.appBorder,
                            cornerRadious: 12.0
                           )
                           if let index = localWorkoutsCategory?.firstIndex(where: { $0.id?.value == selectedEquipmentData.id?.value}) {
                               self.localWorkoutsCategory?.remove(at: index)
                           }
                       }
                   }
                   
               case .filterDefault:
                   print("default is callled...")
               }
           }
       
           print("Selected items:", selectedItems)
       }

       func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
           if let index = selectedItems.firstIndex(of: indexPath.row) {
               selectedItems.remove(at: index)
           }
           
           if let deselectedCell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell {
               deselectedCell.categoryImgView.setCornerRadius(
                   borderWidth: 1.0,
                   borderColor: UIColor.appBorder,
                   cornerRadious: 12.0
               )
               
               //--------------*************
               switch setupExerciseFilterFlow {
               case .muscles:
                   let deselectedBodyParts = bodyPartsData?[indexPath.row]
                   if let deselectedBodyPartsData = deselectedBodyParts {
                       if let index = localBodyPartsData?.firstIndex(where: { $0.id?.value == deselectedBodyPartsData.id?.value}) {
                           localBodyPartsData?.remove(at: index)
                       }else{
                           //--------- Selected For Handle already selected/deselected
                           deselectedCell.categoryImgView.setCornerRadius(
                               borderWidth: 1.0,
                               borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                               cornerRadious: 12.0
                           )
                           localBodyPartsData?.append(deselectedBodyPartsData)
                       }
                   }
                   
               case .equipment:
                   let deselectedEquipment = workoutsCategory?[indexPath.row]
                   if let deselectedEquipmentData = deselectedEquipment {
                       if let index = localBodyPartsData?.firstIndex(where: { $0.id?.value == deselectedEquipmentData.id?.value}) {
                           self.localWorkoutsCategory?.remove(at: index)
                       }else{
                           //--------- Selected For Handle already selected/deselected
                           deselectedCell.categoryImgView.setCornerRadius(
                               borderWidth: 1.0,
                               borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                               cornerRadious: 12.0
                           )
                           self.localWorkoutsCategory?.append(deselectedEquipmentData)
                       }
                   }
                   
               case .filterDefault:
                   print("default is callled...")
               }
           }

           print("Selected items:", selectedItems)
       }
    
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell
        guard let selectedCell = selectedCell else { return }
        print("selected indexpath row= ", indexPath.row)
        selectedCell.categoryImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
        
//        self.dismiss(animated: true, completion: {
//            print("done....")
//            self.sentBackFilterData?(["Dumbbells","Cardio"])
//        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedcell = collectionView.cellForItem(at: indexPath) as? MoreExploreCollectionViewCell
        print("deselected indexpath row= ", indexPath.row)
        guard let deselectedcell = deselectedcell else { return }
        deselectedcell.categoryImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        
    }
    */
    
   
}

extension ExerciseFilterPopupViewController {
    
    private func getBodypartsApi(){
        WorkoutLibraryVM.getBodyPartsApi(completion: {[weak self] getResultData in
            guard let self = self else { return  }
            
            self.bodyPartsData?.removeAll()
            self.bodyPartsData?.append(contentsOf: getResultData?.data ?? [])
            self.filterCollView.reloadData()
        })
    }
    
    private func getAllEquipmentApi(){
        WorkoutLibraryVM.workoutTypeApi(completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            self.workoutsCategory?.removeAll()
            self.workoutsCategory?.append(contentsOf: getResultData.data?.allcategory ?? [])
            self.filterCollView.reloadData()
        })
    }
    
}
