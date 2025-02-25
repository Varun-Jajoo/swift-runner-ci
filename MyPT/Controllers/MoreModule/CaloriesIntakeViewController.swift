//
//  CaloriesIntakeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/02/25.
//

import UIKit

enum CaloriesIntakeFlow {
    case caloriesBrun
    case addIntake
    case caloriesDefault
}

class CaloriesIntakeViewController: CommonViewController {

    //MARK: ----------VARIABLE
    var headerData:[String]?
    var intakeFlow:CaloriesIntakeFlow = .caloriesDefault
    
    
    //MARK: ----------IBOUTLET
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var addIntakeTblView: UITableView!
    @IBOutlet weak var chartBarMBV: UIView!
    @IBOutlet weak var addIntakeTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var headerCountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
//        headerData = ["","Breakfast","Lunch","Snack","Dinner"]
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Calorie Intake"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [UIImage(named: "ic_mostPopularchart")], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupUI(){
//        addIntakeTblView.register(UINib(nibName: "MyGoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGoalsTableViewCell")
//        addIntakeTblView.register(UINib(nibName: "AddIntakeTableViewCell", bundle: nil), forCellReuseIdentifier: "AddIntakeTableViewCell")
        
        //---------------------Flow setup
        switch intakeFlow {
        case .caloriesBrun:
            addIntakeTblView.register(UINib(nibName: "MyGoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGoalsTableViewCell")
            headerData = [""]
            self.addIntakeTblView.reloadData()
            
        case .addIntake:
            addIntakeTblView.register(UINib(nibName: "MyGoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGoalsTableViewCell")
            addIntakeTblView.register(UINib(nibName: "AddIntakeTableViewCell", bundle: nil), forCellReuseIdentifier: "AddIntakeTableViewCell")
            headerData = ["","Breakfast","Lunch","Snack","Dinner"]
            self.addIntakeTblView.reloadData()
        case .caloriesDefault:
            print("None of these..")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.addIntakeTblView.contentSize.height != 0 {
            self.addIntakeTblViewHeightConstrnt.constant = self.addIntakeTblView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
}

//MARK: -------------UITABLEVIEW DELEGATE/DATASOURCE
extension CaloriesIntakeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch intakeFlow {
            
        case .caloriesBrun:
            
            let cell: MyGoalsTableViewCell = addIntakeTblView.dequeueReusableCell(withIdentifier: "MyGoalsTableViewCell", for: indexPath) as! MyGoalsTableViewCell
            
            DispatchQueue.main.async {
                cell.cellMStckView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.progressMBV.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appRatingYellow, cornerRadius: 0.3)
            }
            
            cell.infoMBV.isHidden = false
            cell.caloriesQuantityLbl.isHidden = true
            cell.seeAllBtn.isHidden = true
            
            return cell
            
        case .addIntake:
            if indexPath.section == 0 {
                let cell: MyGoalsTableViewCell = addIntakeTblView.dequeueReusableCell(withIdentifier: "MyGoalsTableViewCell", for: indexPath) as! MyGoalsTableViewCell
               
                DispatchQueue.main.async {
                    cell.cellMStckView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                    cell.progressMBV.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor(red: 62.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadius: 0.3)
                }
                
                cell.infoMBV.isHidden = true
                cell.caloriesQuantityLbl.isHidden = true
                cell.seeAllBtn.isHidden = true
                
                
                return cell
            }else{
                let cell: AddIntakeTableViewCell = addIntakeTblView.dequeueReusableCell(withIdentifier: "AddIntakeTableViewCell", for: indexPath) as! AddIntakeTableViewCell
              
                cell.bgImgView.isHidden = true
                cell.mealBtn.isHidden = true
                cell.kcalBtn.isHidden = true
                
                cell.addBtn.tag = 201 + indexPath.row
                cell.addBtn.addTarget(self, action: #selector(addCaloriesBtnActn(sender: )), for: .touchUpInside)
                
                cell.bgImgView.image = UIImage(named: "ic_studioMembership")?.resized(to: CGSize(width: cell.bgImgView.frame.size.width, height: 80.0))
                
                return cell
            }

        case .caloriesDefault:
            print("None of these..")
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        switch intakeFlow {
        case .caloriesBrun:
            break
        case .addIntake:
            if indexPath.section == 1 {
                let popVC:AddIntakeViewController = AddIntakeViewController.instantiate(appStoryboard: .more)
                popVC.modalPresentationStyle = .automatic
                self.navigationController?.present(popVC, animated: true)
            }
        case .caloriesDefault:
            print("None of these..")
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerV = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let headerSubVMBV = UIView()
        let headerLbltLbl = UILabel()
        let kcalCountLbltLbl = UILabel()
        //0 of 230kcal
        
        headerV.backgroundColor = UIColor.clear
        headerSubVMBV.backgroundColor = UIColor.clear
        headerV.addSubview(headerSubVMBV)
        headerSubVMBV.addSubview(headerLbltLbl)
        headerSubVMBV.addSubview(kcalCountLbltLbl)
        
        headerSubVMBV.translatesAutoresizingMaskIntoConstraints = false
        headerLbltLbl.translatesAutoresizingMaskIntoConstraints = false
        kcalCountLbltLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //----------make constraint
        NSLayoutConstraint.activate([
            headerSubVMBV.leadingAnchor.constraint(equalTo: headerV.leadingAnchor, constant: 20),
            headerSubVMBV.trailingAnchor.constraint(equalTo: headerV.trailingAnchor, constant: -20),
            headerSubVMBV.topAnchor.constraint(equalTo: headerV.topAnchor, constant: 2),
            headerSubVMBV.bottomAnchor.constraint(equalTo: headerV.bottomAnchor, constant: -2),
            headerLbltLbl.leadingAnchor.constraint(equalTo: headerSubVMBV.leadingAnchor, constant: 1),
            headerLbltLbl.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
            headerLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
            headerLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2),
            
            kcalCountLbltLbl.leadingAnchor.constraint(equalTo: headerLbltLbl.trailingAnchor, constant: 1),
            kcalCountLbltLbl.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
            kcalCountLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
            kcalCountLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2)
            
            ])
        
        kcalCountLbltLbl.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        kcalCountLbltLbl.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        
        //------------------Input Data
        headerLbltLbl.text = headerData?[section] as? String 
        kcalCountLbltLbl.text = "0 of 230kcal"
        
        if section == 0 {
            kcalCountLbltLbl.text = ""
        }
        
        headerLbltLbl.textColor = UIColor.txtDarkGray
        kcalCountLbltLbl.textColor = UIColor.txtDarkGray
        headerLbltLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        kcalCountLbltLbl.font = AppFont.regular.size(12, familyName: familyManrope)
        
        
        return headerV
//        return headerMBV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 35 //UITableView.automaticDimension
    }
    
    
    //MARK: ---------------- Add Calories Btn Actn
    @objc func addCaloriesBtnActn(sender: UIButton){
        let popVC:AddIntakeViewController = AddIntakeViewController.instantiate(appStoryboard: .more)
        popVC.modalPresentationStyle = .automatic
        self.navigationController?.present(popVC, animated: true)
    }
}
