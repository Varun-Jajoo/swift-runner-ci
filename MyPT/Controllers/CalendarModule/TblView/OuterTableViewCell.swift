//
//  OuterTableViewCell.swift
//  Fitness_Screen
//
//  Created by Manik Goel on 26/07/25.
//

import UIKit

class SupersetOuterTableViewCell: UITableViewCell,  UITableViewDelegate, UITableViewDataSource {


//    var supersetData: GetSuperset?
    // in OuterTableViewCell
//    var onEditExercise: ((SupersetExerciseModel?, IndexPath) -> Void)?

//    var onDeleteExercise: ((SupersetExerciseModel?, IndexPath) -> Void)?

 
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var viewRest: UIView!
    @IBOutlet weak var viewExcercise: UIView!
    @IBOutlet weak var viewSeconds: UIView!
    @IBOutlet weak var lblRest: UILabel!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var viewNameOfSuperset: UIView!
    @IBOutlet weak var lblNameOfSuperset: UILabel!
    @IBOutlet weak var tfNumOfSets: UITextField!
    @IBOutlet weak var heightOfTableview: NSLayoutConstraint!
    
    var crossCallBack: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//       viewRest.isHidden = true
        uiSetup()
      
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    private func uiSetup() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "ChooseExcerciseTVCell", bundle: nil), forCellReuseIdentifier: "ChooseExcerciseTVCell")
        DispatchQueue.main.async {
//            self.viewExcercise.backgroundColor = .appColor(.supersetcolor)
//            self.viewExcercise.setCornerDiffrentRadius(topLeft: 24, topRight: 24, bottomLeft: 24, bottomRight: 24)
//            self.viewExcercise.setCornerRadius(borderWidth: 1, borderColor: UIColor.appColor(.supersetBorderColor), cornerRadious: 24)
            self.viewNameOfSuperset.layer.cornerRadius = 8
//            self.lblNameOfSuperset.textColor = .appColor(.blackColor)
            self.lblNameOfSuperset.font = AppFont.bold.size(14, familyName: familyManrope)
//            self.tfNumOfSets.textColor = .appColor(.whiteColor)
            self.tfNumOfSets.font = AppFont.bold.size(16, familyName: familyManrope)
            
//            self.viewRest.applyGradient(colors: UIColor.appMultiColor(.viewRestColor))
//            self.viewRest.setCornerRadius(borderWidth: 1, borderColor: UIColor.appColor(.restBorderColor), cornerRadious: 16)
//            self.viewRest.setCornerDiffrentRadius(topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 16)
            
//            [self.lblRest, self.lblSeconds].forEach {
//                $0?.font = AppFont.semibold.size(12, familyName: familyManrope)
//                $0?.textColor = .appColor(.whiteColor)
//            }
            
//            self.viewSeconds.backgroundColor = .appColor(.restSecondColor)
//            self.viewSeconds.setCornerRadius(borderWidth: 1, borderColor: UIColor.appColor(.strengthViewBorder), cornerRadious: 8)
        }
    }
    
    @IBAction func onTapCross(_ sender: UIButton) {
    }
    
    @IBAction func onTapTwoLine(_ sender: UIButton) {
    }
    
    @IBAction func onTapSeconds(_ sender: UIButton) {
//        onTimeTap?()
    }
    
    @IBAction func crossButtonAction(_ sender: UIButton) {
        self.crossCallBack?()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return supersetData?.exercises?.count ?? 0
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseExcerciseTVCell", for: indexPath) as? ChooseExcerciseTVCell else { return UITableViewCell() }
//        cell.btnCheckBox.isHidden = true
        /*
        cell.lblStrength.text = supersetData?.exercises?[indexPath.row].category
        cell.lblWorkoutName.text = supersetData?.exercises?[indexPath.row].name
        cell.lblNumOfReps.text = "\(supersetData?.exercises?[indexPath.row].reps ?? 0)"
        cell.lblNumOfKcl.text = "\(supersetData?.exercises?[indexPath.row].calories ?? 0)"
        cell.chooseWorkoutType = .isShowSuperset
        cell.onEditTapped = { [weak self] tappedCell in
            guard let indexPath = tableView.indexPath(for: tappedCell) else { return }
            let supersetExerciseModel = self?.supersetData?.exercises?[indexPath.row]
            // now pass both exercise data and indexPath
          
            self?.onEditExercise?(supersetExerciseModel, indexPath)
        }
         */

        /*
        cell.onSupersetDelete = { [weak self] tappedCell in
            guard let indexPath = tableView.indexPath(for: tappedCell) else { return }
            let supersetExerciseModel = self?.supersetData?.exercises?[indexPath.row]
            self?.onDeleteExercise?(supersetExerciseModel, indexPath)
        }
        */
        
        return UITableViewCell()
    }
}
