//
//  StepCountViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/02/25.
//

import UIKit

class StepCountViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var stepCountTblView: UITableView!
    @IBOutlet weak var hourMBV: UIView!
    @IBOutlet weak var kcalMBV: UIView!
    @IBOutlet weak var exercisesMBV: UIView!
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var hourTitleLbl: UILabel!
    @IBOutlet weak var kcalLbl: UILabel!
    @IBOutlet weak var kcalTitleLbl: UILabel!
    @IBOutlet weak var exercisesLbl: UILabel!
    @IBOutlet weak var exercisesTitleLbl: UILabel!
    @IBOutlet weak var hourImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var exerciosesImgView: UIImageView!
    @IBOutlet weak var stepCountTblViewHeighConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupFont()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Steps Count"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [UIImage(named: "ic_mostPopularchart")], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupUI(){
        
        self.stepCountTblView.register(UINib(nibName: "MyGoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGoalsTableViewCell")
        
        DispatchQueue.main.async {
            [self.hourMBV, self.kcalMBV, self.exercisesMBV].forEach({
//                $0.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                //------------------Gradient
                $0?.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8), cornerRadius: 12.0)
            })
//            //------------------Gradient
//            [self.hourMBV,self.kcalMBV,self.exercisesMBV].forEach({
//                $0?.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8), cornerRadius: 12.0)
//            })
        }
    }
    
    func setupFont(){
        
        [self.hourLbl,
         self.kcalLbl,
         self.exercisesLbl].forEach({
            $0?.font = AppFont.medium.size(20.0, familyName: familyManrope)
        })
        
        [self.hourTitleLbl,
         self.kcalTitleLbl,
         self.exercisesTitleLbl].forEach({
            $0?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        })
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.stepCountTblView.contentSize.height != 0 {
            self.stepCountTblViewHeighConstrnt.constant = self.stepCountTblView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
}

//MARK: --------------------UITABLEVIEW DATASOURCE/ DELEGATE
extension StepCountViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyGoalsTableViewCell = stepCountTblView.dequeueReusableCell(withIdentifier: "MyGoalsTableViewCell", for: indexPath) as! MyGoalsTableViewCell
       
        DispatchQueue.main.async {
            cell.cellMStckView.addGradient(colors: UIColor.appMultiColor(.stepsConnect), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12)
            cell.progressMBV.backgroundColor = UIColor.appWhite
            cell.progressMBV.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appYellow, cornerRadius: 3.0)
        }
        
        cell.infoMBV.isHidden = true
        cell.caloriesQuantityLbl.isHidden = true
        cell.seeAllBtn.isHidden = true
        
        cell.remainingTitleLbl.textColor = UIColor.appWhite
        cell.caloriesBurnTitleLbl.textColor = UIColor.appWhite
        cell.caloriesQuantityLbl.textColor = UIColor.appWhite
        cell.burnProgressTitleLbl.textColor = UIColor.appWhite
        cell.outOffTitleLbl.textColor = UIColor.appWhite
        cell.targetInfoTitleLbl.textColor = UIColor.appWhite
        
        cell.caloriesBurnTitleLbl.text = "Step Count".uppercased()
        cell.burnProgressTitleLbl.text = "Target 3000 Steps"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
}
