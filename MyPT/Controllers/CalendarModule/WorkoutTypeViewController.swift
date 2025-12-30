//
//  WorkoutTypeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/08/25.
//

import UIKit

class WorkoutTypeViewController: UIViewController {
    
    //MARK: -------------- VARIABLE
    var sentBackWorkoutId: ((String?) -> Void)?
    var deleteSupersetExercise: ((_ exerciseId: String?) -> Void)?
    var editSupersetExercise: ((_ exerciseId: String?) -> Void)?
    var supersetCout: Int?
    
    var workoutIdStr: String?
    var isSetNew: Bool = true
    var supersetExerciseData:[ExercisesDatailsModel]? = []
    var restTimeData: ExercisesDatailsModel?
    
    var countSet: Int = 1{
        didSet{
            groupCountLbl.text = "\(countSet)"
        }
    }
    
    var createSupersetWorkoutParam: RegularWorkoutModel? //= RegularWorkoutModel()
    
    //MARK: -------------- IBOUTLET
    @IBOutlet weak var workoutTypePopupMBV: UIView!
    @IBOutlet weak var selectWorkoutTypeTitleLbl: UILabel!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var workoutLstMBV: UIView!
    @IBOutlet weak var addExerciseMBV: UIView!
    @IBOutlet weak var setSuperSetMBV: UIView!
    @IBOutlet weak var createSupersetMBV: UIView!
    @IBOutlet weak var createGroupSubView: UIView!
    @IBOutlet weak var createGroupTitleLbl: UILabel!
    @IBOutlet weak var groupCountLbl: UILabel!
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var addExerciseBtn: UIButton!
    
    @IBOutlet weak var workoutCollView: UICollectionView!
    @IBOutlet weak var workoutCollViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        countSet = 3
        workoutCollView.register(UINib(nibName: "workTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "workTypeCollectionViewCell")
        self.setLstHeight()
        
        if let supersetCout = supersetCout {
            selectWorkoutTypeTitleLbl.text = "Superset \(supersetCout)"
        }else{
            selectWorkoutTypeTitleLbl.text = "Selected workout type"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    enum Btntag: Int {
        case topBar = 1101, deleteGroup, addExercise, minusCount, plusCount, createGroup
    }
    
    private func dismissPopup(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case Btntag.topBar.rawValue:
            print("Top bar btn clicked....")
            self.dismiss(animated: true, completion: nil)
            break
        case Btntag.deleteGroup.rawValue:
            print("del btn clicked")
            self.supersetExerciseData?.removeAll()
            self.workoutCollView.reloadData()
            self.dismiss(animated: true, completion: nil)
            break
        case Btntag.addExercise.rawValue:
            print("addExercise btn clicked....")
            self.dismiss(animated: true, completion: nil)
            
//            self.dismiss(animated: true, completion: {[weak self] in
//                guard self != nil else {
//                    return
//                }
//                
//                self?.sentBackData?(true)
//            })
            
            break
        case Btntag.minusCount.rawValue:
            print("minusCount btn clicked....")
            guard countSet > 1 else {
                return
            }
            countSet -= 1
            
            break
        case Btntag.plusCount.rawValue:
            print("plusCount btn clicked....")
            countSet += 1
            break
        case Btntag.createGroup.rawValue:
            print("createGroup btn clicked....")
            
            if let supersetExerciseData = supersetExerciseData, !supersetExerciseData.isEmpty, supersetExerciseData.count >= 2 {
                    self.makeSupersetGroup()
            }else{
                AlertHelper.shared.showCustomeAlert(message: "Please add at least two exercises to create a superset.")
            }
            
            break
        default:
            print("none....")
            break
        }
    }
    
    private func makeSupersetGroup(){
        
        /*
         if let restTimeData = restTimeData , restTimeData.type?.value == "rest"{
             let restItem = SupersetExerciseModel(
                 id: FlexibleValue(value: nil),
                 type: FlexibleValue(value: "rest"),
                 sets: FlexibleValue(value: nil),
                 reps: FlexibleValue(value: nil),
                 timeType: FlexibleValue(value: "2"),
                 duration: FlexibleValue(value: restTimeData.restDuration?.value)
             )
             supersetExercises?.insert(restItem, at: 0)
         }
         */
        
        let supersetExercises = supersetExerciseData?.map {
            SupersetExerciseModel(
                id: FlexibleValue(value: $0.id?.value),
                type: FlexibleValue(value: "exercise"),
                sets: FlexibleValue(value: "\(self.countSet)"),
                reps: FlexibleValue(value: "\($0.reps?.value ?? $0.raps?.value ?? " ")"),
                timeType: FlexibleValue(value: "2")
            )
        }
        
        /*
        let supersetGroup = SupersetModel(
            type:  FlexibleValue(value: "superset"),
            exercises: supersetExercises,
            duration: nil
        )
        */
        
        let supersetGroup: [SupersetModel] = [
            SupersetModel(
            type:  FlexibleValue(value: "superset"),
            exercises: supersetExercises,
            duration: nil
        )]
        
        /*
        if let restTimeData = restTimeData , restTimeData.type?.value == "rest"{
            let restItem = SupersetModel(
                type:  FlexibleValue(value: "rest"),
                exercises: nil,
                duration: FlexibleValue(value: restTimeData.restDuration?.value)
            )
            
            supersetGroup.insert(restItem, at: 0)
        }
        */
        
        if let workoutIdStr = workoutIdStr, !workoutIdStr.isEmpty {
            isSetNew = true
        }else{
            isSetNew = false
        }
        
        let makeSuperSet = SupersetWorkoutModel(
            id: FlexibleValue(value: workoutIdStr),
            name: createSupersetWorkoutParam?.name.map { FlexibleValue(value: $0) },
            description: FlexibleValue(value: ""),
            type: FlexibleValue(value: "superset"),
            isSetNew: self.isSetNew,
            categoryID: FlexibleValue(value: "1"),
            repeatDuration: createSupersetWorkoutParam?.repeat_duration.map { FlexibleValue(value: "\($0)") },
            repeatDays: createSupersetWorkoutParam?.repeat_days.map { FlexibleValue(value: $0) },
            startDate: createSupersetWorkoutParam?.start_date.map { FlexibleValue(value: $0) },
            endDate: createSupersetWorkoutParam?.end_date.map { FlexibleValue(value: $0) },
            time: createSupersetWorkoutParam?.time.map { FlexibleValue(value: $0) },
            remindMe: createSupersetWorkoutParam?.remind_me.map { FlexibleValue(value: $0) },
            supersets: supersetGroup //[supersetGroup]
        )
        
        print("Super sets: ", makeSuperSet)
        
        WorkoutLibraryVM.createSupersetWorkoutApi(inputWorkout: makeSuperSet, completion: {[weak self] getResultData in
            guard let self = self else { return  }
            print("getResultData: ", getResultData?.data?.workout_id?.value as Any)
            self.dismiss(animated: true, completion: {[weak self] in
                self?.sentBackWorkoutId?(getResultData?.data?.workout_id?.value)
            })
        })
    }
    
    
    /*
     @IBAction func onTapCraeteGroup(_ sender: UIButton) {
             //  Require at least 2 exercises
              if selectedSupersetExercises.count < 2 {
                  AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please add at least two exercises to create a superset.")
                  return
              }
             let remindMeString = supersetRemindMeId == 0 ? "" : "\(supersetRemindMeId)"
             
             let supersetExercises = selectedSupersetExercises.map {
                 SupersetExercise(
                     id: $0.id,
                     type: "exercise",
                     sets: Int(lblSetGroupNum.text ?? "") ?? 3,
                    reps: $0.raps,
                     timeType: 2
                 )
             }
             let supersetGroup = Superset(
                 type: "superset",
                 exercises: supersetExercises,
                 duration: nil
             )
             var iWantID = Int()
             if self.addNewSuperset == true {
                 if MyUserDefaults.instance.get(key: .workoutId) == 0 {
                     iWantID = self.isExistWorkoutId
                 } else {
                     iWantID = MyUserDefaults.instance.get(key: .workoutId) ?? 0
                 }
             }
             hitSupersetWorkoutApi(variables: SupersetVariable(id: self.addNewSuperset == true ? iWantID : nil, name: workoutName, description: "", type: "superset", isSetNew: addNewSuperset ? true : false, categoryID: 1, repeatDuration: superRepeatDurationInt, repeatDays: superRepeatDaysString, startDate: selectedDateString, endDate: superRepeatEndDate, time: selectedTimeString, remindMe: remindMeString, clientID: clienId, supersets: [supersetGroup]))
      
         }
      
     */
    
    
    private func setupFont(){
        self.delBtn.setImage(UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 25, height: 25)), for: .normal)
        
        self.selectWorkoutTypeTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.createGroupTitleLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.groupCountLbl.font = AppFont.bold.size(40.0, familyName: familyManrope)
        self.createBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addExerciseBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    private func setLstHeight(){
        let vcHeight = (self.view.frame.size.height*0.3)
        workoutCollViewHeightConstrnt.constant = vcHeight
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            //            self.workoutTypePopupMBV
            self.addExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            self.workoutTypePopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.workoutTypePopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.createGroupSubView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.createGroupSubView.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.createBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.workoutTypePopupMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            }else{
                print("tap at popup view.")
            }
        }
    }
}

extension WorkoutTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return supersetExerciseData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: workTypeCollectionViewCell = workoutCollView.dequeueReusableCell(withReuseIdentifier: "workTypeCollectionViewCell", for: indexPath) as! workTypeCollectionViewCell
        cell.setupCell(cellData: supersetExerciseData?[indexPath.row])
        // Connect the cell's button tap to the view controller
        cell.onMenuButtonTapped = { [weak self, weak cell] button in
            guard let self = self, let cell = cell else { return }
            self.presentCustomMenu(for: cell, at: indexPath, from: button)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthCell = collectionView.frame.width*0.48
        return CGSize(width: widthCell, height: 120.0)
    }
    
    private func presentCustomMenu(for cell: workTypeCollectionViewCell, at indexPath: IndexPath, from sourceView: UIView) {
                
        let menuVC = CustomMenuViewController()
        menuVC.menuItems = [
            MenuItem(title: "Edit", image: UIImage(named: "ic_edit_black")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: false, titleColor: UIColor.mainBg, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: .clear),
            MenuItem(title: "Delete", image: UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: true, titleColor: UIColor.appRed, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0))
        ]

        menuVC.onMenuItemSelected = { [weak self] actionTitle in
            guard let self = self else { return }
            
            if actionTitle == "Edit" {
                print("Edit is clicked")
                self.dismiss(animated: true) {
                    print("Editing....")
                    if let data = self.supersetExerciseData, data.indices.contains(indexPath.row) {
                       // edit current item
                       self.editSupersetExercise?(self.supersetExerciseData?[indexPath.row].id?.value)
                   }
                    self.dismissPopup()
                }
            }
            else if actionTitle == "Delete" {
                print("Delete is clicked")
                
                self.dismiss(animated: true) {   // dismiss popover first
                    let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
                    vc.modalPresentationStyle = .automatic
                    vc.delTilteStr = "Delete Exercise"
                    vc.altMsgStr = "You’re going to delete this exercise. Are you sure?"
                    vc.sentBackData = { isDelete in
                        if let isDelete = isDelete, isDelete,
                         let data = self.supersetExerciseData, data.indices.contains(indexPath.row) {
                            // Remove current item
                            self.deleteSupersetExercise?(self.supersetExerciseData?[indexPath.row].id?.value)
                            self.supersetExerciseData?.remove(at: indexPath.row)
                            self.workoutCollView.reloadData()
                        }
                    }
                    self.present(vc, animated: true)
                }
            }
        }
                
        // REQUIRED: Set the presentation style to popover
        menuVC.modalPresentationStyle = .popover
        menuVC.preferredContentSize = CGSize(width: 130, height: 80)
        
        // Configure the popover
        if let popover = menuVC.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = sourceView
            popover.permittedArrowDirections = [] // <-- Remove arrow
            popover.sourceRect = CGRect(
                x: -30,   // horizontally center ,sourceView.bounds.midX
                y: sourceView.bounds.maxY + 15.0,   // bottom edge of the button
                width: 0,
                height: 0
            )
           
            // You can even customize the popover's background
            popover.backgroundColor = UIColor.clear
        }
        
        present(menuVC, animated: true, completion: nil)
      
       }
}

extension WorkoutTypeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // This makes the popover appear correctly on iPhone
        return .none
    }
}

// MyCollectionViewController.swift (continued)
//extension WorkoutTypeViewController: UICollectionViewDataSource {
//    
//  
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCustomCell", for: indexPath) as? MyCustomCollectionViewCell else {
//            fatalError("Could not dequeue MyCustomCollectionViewCell")
//        }
//
//        // Configure your cell
//        cell.configure(with: "Item \(indexPath.item)")
//        
//        // Add the context menu interaction
//        let interaction = UIContextMenuInteraction(delegate: self)
//        cell.addInteraction(interaction)
//        
//        return cell
//    }
//}

//extension WorkoutTypeViewController: UIContextMenuInteractionDelegate {
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        
//        // Find the cell that the user long-pressed on.
//        // The `interaction.view` is the cell itself.
//        guard let cell = interaction.view as? DailyInsightCollectionViewCell,
//              let indexPath = workoutCollView.indexPath(for: cell) else {
//            return nil
//        }
//        
//        // You can use the indexPath to get data for the specific item
//        let itemTitle = "Item \(indexPath.item)"
//        
//        // Create the context menu configuration
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
//            
//            // Create the 'Edit' action
//            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { action in
//                print("Edit \(itemTitle)")
//                // Handle the 'Edit' action for the selected item
//                // e.g., navigate to an edit screen
//            }
//            
//            // Create the 'Delete' action
//            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
//                print("Delete \(itemTitle)")
//                // Handle the 'Delete' action for the selected item
//                // e.g., show an alert or delete the item from your data source
//            }
//            
//            // Return the menu with your actions
//            return UIMenu(title: "", children: [editAction, deleteAction])
//        }
//    }
//}
