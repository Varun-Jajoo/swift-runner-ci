//
//  CreateTrainerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class CreateTrainerViewController: CommonViewController {

    //MARK: --------------VARIABLE
    var trainerData:[[String:Any]]?
    let locManager = GetLocationManager()
    var getLat:Double?
    var getLong:Double?
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var trainerListTblView: UITableView!
    
    @IBOutlet weak var continueBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFont()
        setupUI()
        self.getLocation()
        
//        trainerData = [["title":"Home Workout","trainerImg":AppImages.homeWorkout as Any],
//                       ["title":"Gym Workout","trainerImg":AppImages.gymWorkout as Any]
//        ]
        
        trainerData = [["title":"Home Workout","trainerImg":AppImages.Home_workout as Any, "trainerImg_selected":AppImages.Home_workout_selected as Any],
                       ["title":"Gym Workout","trainerImg":AppImages.gym_workout as Any, "trainerImg_selected":AppImages.gym_workout_selected as Any]
        ]
        
        trainerListTblView.register(UINib(nibName: "TrainerTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerTypeTableViewCell")
        
        self.continueBtn.isUserInteractionEnabled = false
        
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
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: -------------GET Lat long
    private func getLocation(){
        locManager.requestLocation(completion: { [weak self] getLocation in
            guard let self = self, let getLocation = getLocation else { return  }

            self.getLat = getLocation.coordinate.latitude
            self.getLong = getLocation.coordinate.longitude
        })
    }
    
    //MARK: ---------- SET UI
    private func setupUI(){
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    private func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn actn.....")

        NotificationCenter.default.post(name: NSNotification.Name("reloadTab"), object: false)
        
        if let getLat = getLat, let getLong = getLong {
            if let titleStr = trainerData?.first?["title"] as? String , self.continueBtn.accessibilityHint == titleStr {
                let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                vc.flowSlot = calendarFlow.bookTrainer
                vc.inputType = "home"
                vc.inputLat = "\(getLat)"
                vc.inputLong = "\(getLong)"
                vc.isFromHome = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                //        vc.flowSlot = calendarFlow.bookTrainer
                vc.inputType = "gym"
                vc.inputLat = "\(getLat)"
                vc.inputLong = "\(getLong)"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            self.getLocation()
        }
                
        /*
        if let titleStr = trainerData?.first?["title"] as? String , self.continueBtn.accessibilityHint == titleStr {
            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.flowSlot = calendarFlow.bookTrainer
            vc.inputType = "home"
            vc.inputLat = "75.39102"
            vc.inputLong = "28.535517"
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
            //        vc.flowSlot = calendarFlow.bookTrainer
            self.navigationController?.pushViewController(vc, animated: true)
        }
        */
        
    }
    
        
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
}


extension CreateTrainerViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainerData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerTypeTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerTypeTableViewCell", for: indexPath) as! TrainerTypeTableViewCell
      
        cell.titleLbl.isHidden = true
        cell.trainerImgView.isHidden = true
       
        cell.setSelectdBGCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
        
        /*
        cell.titleLbl.text = trainerData?[indexPath.row]["title"] as? String
//        cell.trainerImgView.image = trainerData?[indexPath.row]["trainerImg"] as? UIImage
        
        cell.setSelectdCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg"] as? UIImage, isSelectedCell: false)
        */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        selectedCell.setSelectdBGCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: true)
        
        self.continueBtn.accessibilityHint = trainerData?[indexPath.row]["title"] as? String
        
//        if indexPath.row == 0 {
//            self.continueBtn.accessibilityHint = trainerData?[indexPath.row]["title"] as? String
//        }
        
        self.enableContinueBtn(isSelected: true)
        
        
        
//        if indexPath.row != 0 {
//            self.enableContinueBtn(isSelected: false)
//            AlertHelper.shared.showCustomeAlert(message: "work in progress.")
//          
//        }else{
//            self.enableContinueBtn(isSelected: true)
//        }
//        selectedCell.setSelectdCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg"] as? UIImage, isSelectedCell: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deSelected index", indexPath.row)
  
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        deSelectedCell.setSelectdBGCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
        
//        deSelectedCell.setSelectdCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg"] as? UIImage, isSelectedCell: false)
    }
    
    
}
