//
//  SupersetGroupTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 10/09/25.
//

import UIKit

protocol MenuActions {
    func deletedWorkoutExercise(_ workoutExerciseId: String?)
}

class SupersetGroupTableViewCell: UITableViewCell {
    
    //MARK: ----------- VARIOABLE
    var navCtrnl: UINavigationController?
    var workoutIdStr: String?
    var delegate: MenuActions?
    
    var setsData: [ExercisesDatailsModel]? = [] {
        didSet {
            let setsCount = setsData?.count
//            self.setsCountBtn.setTitle("\(setsCount ?? 0) Sets", for: .normal)
            let setValue = setsData?.first(where: { $0.sets?.value != nil })?.sets?.value ?? ""
            self.setsCountBtn.setTitle("\(setValue) Sets", for: .normal)
            setsLstTblView.reloadData()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateInnerTableHeightAndNotifyParent()
            }
        }
    }
    
    // MARK: - Helpers
      private var parentTableView: UITableView? {
          var v: UIView? = self.superview
          while v != nil {
              if let tv = v as? UITableView { return tv }
              v = v?.superview
          }
          return nil
      }
    
    //MARK: ---------------- IBOUTLET
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var supersetCountMBV: UIView!
    @IBOutlet weak var supersetCountLbl: UILabel!
    @IBOutlet weak var setsLstTblView: UITableView!
    @IBOutlet weak var setsCountBtn: UIButton!
    @IBOutlet weak var setsLstTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupUI()
        self.setupFont()
        self.setsLstTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        self.setsLstTblView.isScrollEnabled = false
        setsLstTblView.rowHeight = UITableView.automaticDimension
        setsLstTblView.estimatedRowHeight = 70
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(inputData: SupersetModelAPI?){
        guard let inputData = inputData else { return }
        self.setsCountBtn.setTitle("\(inputData.sets_position?.value ?? "") Sets", for: .normal)
        if let exercisesCount = inputData.exercises?.count {
            self.supersetCountLbl.text = "Superset " + "\(exercisesCount)"
        }
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
         // keep height constraint in sync if something changed layout-wise
         setsLstTblView.layoutIfNeeded()
         let contentH = setsLstTblView.contentSize.height
         if setsLstTblViewHeightConstrnt.constant != contentH {
             setsLstTblViewHeightConstrnt.constant = contentH
             contentView.layoutIfNeeded()
         }
     }

     override func prepareForReuse() {
         super.prepareForReuse()
         // Avoid stale height showing during reuse
         setsLstTblViewHeightConstrnt.constant = 0
     }

     // MARK: - Private
     private func updateInnerTableHeightAndNotifyParent() {
         setsLstTblView.layoutIfNeeded()
         let newHeight = setsLstTblView.contentSize.height
         setsLstTblViewHeightConstrnt.constant = newHeight
         contentView.layoutIfNeeded()

         // Force the parent table to recalc the cell height
         if let table = parentTableView {
             table.beginUpdates()
             table.endUpdates()
         }
     }
    
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 62.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 20.0)
            self.supersetCountMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
        }
    }
    
    private func setupFont(){
        self.supersetCountLbl.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.setsCountBtn.titleLabel?.font = AppFont.medium.size(15.0, familyName: familyManrope)
    }
    
}

//MARK: ------------------- UITABLEVIEW DELEGATE/DATASOURCE
extension SupersetGroupTableViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exerciseCell:ExerciseTableViewCell = setsLstTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        
        exerciseCell.setCellData(cellData: setsData?[indexPath.row])
        exerciseCell.editBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)

        exerciseCell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
        exerciseCell.setupMenuActn()
        exerciseCell.onMenuBtnTapped = { [weak self, weak exerciseCell] button in
            guard let self = self, let cell = exerciseCell else { return }
            self.presentCustomMenuCircuit(for: cell, at: indexPath, from: button)
        }
        
        DispatchQueue.main.async {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        return exerciseCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == setsLstTblView {
            DispatchQueue.main.async {
                self.updateInnerTableHeightAndNotifyParent()
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if tableView == setsLstTblView {
//            DispatchQueue.main.async {
//                self.updateInnerTableHeight()
//            }
//        }
//    }
    
    //MARK: ---------------CIRCUIT FLOW EDIT / DELETE
    private func presentCustomMenuCircuit(for cell: ExerciseTableViewCell, at indexPath: IndexPath, from sourceView: UIView) {
        
        let menuVC = CustomMenuViewController()
        menuVC.menuItems = [
            MenuItem(title: "Edit", image: UIImage(named: "ic_edit_black")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: false, titleColor: UIColor.mainBg, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: .clear),
            MenuItem(title: "Delete", image: UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: true, titleColor: UIColor.appRed, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0))
        ]

        menuVC.onMenuItemSelected = { [weak self] actionTitle in
            guard let self = self else { return }
            
            if actionTitle == "Edit" {
                print("Edit is clicked")
                let vc: EditRegularExerciseViewController = EditRegularExerciseViewController.instantiate(appStoryboard: .calendar)
                vc.createWorkoutFlow = .superCreateWorkout
                
                vc.setsPositionStr = setsData?[indexPath.row].sets_position?.value
                vc.workoutIdStr = self.workoutIdStr
                vc.workoutExerciseId = setsData?[indexPath.row].id?.value
                vc.exerciseName = setsData?[indexPath.row].name?.value
                vc.exerciseImgStr = setsData?[indexPath.row].image?.value
                vc.durationStr = setsData?[indexPath.row].duration?.value
                vc.restTimeStr = setsData?[indexPath.row].duration?.value
                vc.caloriesStr = setsData?[indexPath.row].calories?.value
                vc.inputSetsCont = Int(setsData?[indexPath.row].sets?.value ?? "1") // Int(exerciseData?[indexPath.row].category?.value ?? "1")
                vc.inputRepsCont = Int(setsData?[indexPath.row].reps?.value ?? "1")
                vc.sentEditedData = { (setsCount, repsCount, restTime, noteDesc) in
                    if let repsCount = repsCount {
                        self.setsData?[indexPath.row].reps?.value = "\(repsCount)"
                        self.setsLstTblView.reloadData()
                    }
                }
                self.navCtrnl?.pushViewController(vc, animated: true)
            }
            else if actionTitle == "Delete" {
                print("Delete is clicked")
                
                self.navCtrnl?.dismiss(animated: true) {   // dismiss popover first
//                    if let setsData = self.setsData, setsData.count > 2 {
                        let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
                        vc.modalPresentationStyle = .automatic
                        vc.delTilteStr = "Delete Exercise"
                        vc.altMsgStr = "You’re going to delete this exercise. Are you sure?"
                        vc.sentBackData = { isDelete in
                            if let isDelete = isDelete, isDelete,
                               let data = self.setsData, data.indices.contains(indexPath.row) {
                                // Remove current item
//                                self.setsData?.remove(at: indexPath.row)
//                                self.setsLstTblView.reloadData()
                                
                                if let _ = self.workoutIdStr {
                                    //---------------Delete workout from superset group
                                    WorkoutLibraryVM.deleteWorkoutExerciseApi(inputWorkoutExerciseId: self.setsData?[indexPath.row].workout_exercise_id?.value, completion: {[weak self] getResultData in
                                        guard let self = self else { return }
                                        
                                        if let delegate = self.delegate, let exerciseId = self.setsData?[indexPath.row].workout_exercise_id?.value {
                                            delegate.deletedWorkoutExercise(exerciseId)
                                        }
                                        
                                        self.setsData?.remove(at: indexPath.row)
                                        self.setsLstTblView.reloadData()

                                    })
                                }else{
                                    self.setsData?.remove(at: indexPath.row)
                                    self.setsLstTblView.reloadData()
                                }
                            }
                        }
                        self.navCtrnl?.present(vc, animated: true)
                        
//                    }else{
//                        AlertHelper.shared.showCustomeAlert(message: "Please at least two exercises to create a superset.")
//                    }
                }
            }
        }
        
        menuVC.modalPresentationStyle = .popover
        menuVC.preferredContentSize = CGSize(width: 130, height: 90)
        if let popover = menuVC.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = cell.checkBtn //sourceView
            popover.permittedArrowDirections = [] // <-- Remove arrow
            
            popover.sourceRect = CGRect(
                x: cell.checkBtn.bounds.minX - 50,   // horizontally center
                y: cell.checkBtn.bounds.maxY + 60.0,   // bottom edge of the button
                width: 0,
                height: 0
            )
            
            popover.backgroundColor = UIColor.clear
        }
        self.navCtrnl?.present(menuVC, animated: true, completion: nil)
       }
    
}

extension SupersetGroupTableViewCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // This makes the popover appear correctly on iPhone
        return .none
    }
}
