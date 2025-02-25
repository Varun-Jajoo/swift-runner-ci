//
//  HydrationViewViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/02/25.
//

import UIKit

class HydrationViewViewController: CommonViewController {

    //MARK: ---------------VARIABLE
//    var sectionData:[SectionModel]?  = []
    var sectionData:[HydrationModel]?  = []
    var changedGlassSize:Double?
    
    
    var totalGoals:Int? = 2500{
        didSet{
            if let goalsAmt = goalsAmt, let totalGoals = totalGoals {
                addAmountBtn.isUserInteractionEnabled = false
                if goalsAmt <= totalGoals {
                    addAmountBtn.isUserInteractionEnabled = true
                    self.getPercent()
                }
                self.showAmountBtn.setTitle("\(goalsAmt) / \(totalGoals)ml", for: .normal)
            }
        }
    }

    var goalsAmt:Int? = 0 {
        didSet{
            if let goalsAmt = goalsAmt, let totalGoals = totalGoals {
                addAmountBtn.isUserInteractionEnabled = false
                if goalsAmt <= totalGoals {
                    addAmountBtn.isUserInteractionEnabled = true
                }
                
                self.showAmountBtn.setTitle("\(goalsAmt) / \(totalGoals)ml", for: .normal)
            }
        }
    }
    
    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var addAmountMBV: UIView!
    @IBOutlet weak var percentLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addAmountBtn: UIButton!
    @IBOutlet weak var showAmountBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var showDataTblView: UITableView!
    @IBOutlet weak var showDataTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setUIFont()
        self.inputSectionData()
//        self.goalsAmt = 500
        self.changedGlassSize = 500
        self.totalGoals = 2500
        self.getPercent()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Hydration"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func addAmountBtnActn(_ sender: UIButton) {
        guard var addGoalsAmt = self.goalsAmt, let changedGlassSize = self.changedGlassSize, let totalGoals = self.totalGoals, addGoalsAmt <= totalGoals else { return  }
        
        addGoalsAmt += Int(changedGlassSize)
        
        addAmountBtn.isUserInteractionEnabled = true
        if addGoalsAmt <= totalGoals {
            self.goalsAmt = addGoalsAmt
            self.getPercent()
        }else{
            addAmountBtn.isUserInteractionEnabled = false
        }
        
        print("Add btn clecked.")
    }
    
    func getPercent(){
        if let totalGoals = self.totalGoals, let goalsAmt = self.goalsAmt {
            let percent = (goalsAmt*100) / totalGoals
            self.percentLbl.text = "\(percent)%"
        }
    }
    
    func inputSectionData(){
        
        self.sectionData = [
            HydrationModel(title: "Today’s Intake", items: [HydrationDataModel(subTitle: "250ml", qnty: "2:30PM"),HydrationDataModel(subTitle: "250ml", qnty: "1:20PM"),HydrationDataModel(subTitle: "250ml", qnty: "12:00PM")]),
            HydrationModel(title: "Weekly Chart", items: [HydrationDataModel(subTitle: "", qnty: "")]),
            HydrationModel(title: "My Report", items: [HydrationDataModel(subTitle: "Monthly Average", qnty: "2:30PM"),HydrationDataModel(subTitle: "Weekly Average", qnty: "1:20PM"),HydrationDataModel(subTitle: "Avg Completion", qnty: "12:00PM"),HydrationDataModel(subTitle: "Drink Frequency", qnty: "12:00PM")]),
            HydrationModel(title: "Settings", items: [HydrationDataModel(subTitle: " Unit", qnty: "ml"),HydrationDataModel(subTitle: "Glass Size", qnty: "500ml"),HydrationDataModel(subTitle: "Goal", qnty: "\(self.totalGoals ?? 0)ml")])
        ]
        
        self.showDataTblView.reloadData()
        
        
//        self.sectionData = [
//            SectionModel(title: "Today’s Intake", items: [""]),
//            SectionModel(title: "Weekly Chart", items: [""]),
//            SectionModel(title: "My Report", items: [""]),
//            SectionModel(title: "Settings", items: [""]),
//            SectionModel(title: "Unit", items: [""]),
//            SectionModel(title: "Glass Size", items: [""]),
//            SectionModel(title: "Goal", items: [""])
//        ]
//        self.showDataTblView.reloadData()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.showDataTblView.contentSize.height != 0 {
            self.showDataTblViewHeightConstrnt.constant = self.showDataTblView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
    
    func setupUI(){
        
        self.showDataTblView.register(UINib(nibName: "HydrationDataTableViewCell", bundle: nil), forCellReuseIdentifier: "HydrationDataTableViewCell")
        
        //------------------************
        DispatchQueue.main.async {
            self.addAmountMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
            self.addAmountMBV.setGradientBorder(cornerRadious: 24, width: 2, colors: [UIColor(red: 91.0/255.0, green: 93.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 55.0/255.0, green: 57.0/255.0, blue: 60.0/255.0, alpha: 0)], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            self.showAmountBtn.addGradient(colors: UIColor.appMultiColor(.blueGradient), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24)
            
            self.addAmountBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.6)
            self.infoBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    func setUIFont(){
        self.percentLbl.font = AppFont.medium.size(48.0, familyName: familyClashDisplay)
        self.statusLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.addAmountBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.infoBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyOverpass)
        
        //------------------------********* Attributed text
        let defaultAttributes = [
            .font: AppFont.medium.size(48, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appYellow
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = ["\(goalsAmt ?? 0)" ,
                                  NSAttributedString(string: "/\(totalGoals ?? 0)ml",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.showAmountBtn.titleLabel?.numberOfLines = 0
        self.showAmountBtn.titleLabel?.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
}

//MARK: ------------------UIBALEVIEW DELEGATE / DATASOURCE
extension HydrationViewViewController: UITableViewDelegate, UITableViewDataSource{
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return sectionData?.count ?? 0
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HydrationDataTableViewCell = showDataTblView.dequeueReusableCell(withIdentifier: "HydrationDataTableViewCell", for: indexPath) as! HydrationDataTableViewCell
    
//        cell.innerDataTblViewHeightConstrnt.constant = 200
        cell.innerDataTblViewHeightConstrnt.constant = CGFloat((sectionData?[indexPath.row].items.count ?? 0) * 55)
        cell.sectionInnerData = sectionData?[indexPath.row]
        cell.delegate = self
        cell.navCtrntl = self.navigationController
        
        cell.dateMBV.isHidden = true
        cell.topTitleLbl.text = sectionData?[indexPath.row].title as? String
        cell.innerData = sectionData?[indexPath.row].items
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.updateViewConstraints()
//        }
//        
//        let deSelectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    //     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //         let headerV = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
    //         let headerSubVMBV = UIView()
    //         let headerLbltLbl = UILabel()
    //
    //         headerV.backgroundColor = UIColor.clear
    //         headerSubVMBV.backgroundColor = UIColor.clear
    //         headerV.addSubview(headerSubVMBV)
    //         headerSubVMBV.addSubview(headerLbltLbl)
    //
    //         headerSubVMBV.translatesAutoresizingMaskIntoConstraints = false
    //         headerLbltLbl.translatesAutoresizingMaskIntoConstraints = false
    //         //----------make constraint
    //         NSLayoutConstraint.activate([
    //             headerSubVMBV.leadingAnchor.constraint(equalTo: headerV.leadingAnchor, constant: 20),
    //             headerSubVMBV.trailingAnchor.constraint(equalTo: headerV.trailingAnchor, constant: -20),
    //             headerSubVMBV.topAnchor.constraint(equalTo: headerV.topAnchor, constant: 2),
    //             headerSubVMBV.bottomAnchor.constraint(equalTo: headerV.bottomAnchor, constant: -2),
    //             headerLbltLbl.leadingAnchor.constraint(equalTo: headerSubVMBV.leadingAnchor, constant: 1),
    //             headerLbltLbl.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
    //             headerLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
    //             headerLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2)
    //             ])
    //
    //         //------------------Input Data
    //         headerLbltLbl.text = sectionData?[section].title as? String
    //         headerLbltLbl.textColor = UIColor.appWhite
    //         headerLbltLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
    //
    //         return headerV //headerMBV
    //     }
    
    //    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 30
    //    }
    //
    
}

 
extension HydrationViewViewController: sendBackHydrationData{
    func sendTargetGoalsData(data: String?) {
        if let data = data{
            self.totalGoals = Int(data)
        }
    }
    
    func sendGlassDizeData(data: String?) {
        if let data = data, let getDoubleData = Double(data) {
            self.changedGlassSize = getDoubleData
            self.addAmountBtn.setTitle("\(Int(getDoubleData))ml", for: .normal)
            
            if let totalGoals = self.totalGoals{
                self.totalGoals = totalGoals
            }
            
//            if let goalsAmt = goalsAmt, let totalGoals = totalGoals {
//                addAmountBtn.isUserInteractionEnabled = false
//                if goalsAmt <= totalGoals {
//                    addAmountBtn.isUserInteractionEnabled = true
//                    self.getPercent()
//                }
//            }
        }
    }
    
}
