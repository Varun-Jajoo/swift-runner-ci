//
//  HydrationDataTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 17/02/25.
//

import UIKit

protocol sendBackHydrationData {
    func sendGlassDizeData(data: String?)
    func sendTargetGoalsData(data: String?)
}

class HydrationDataTableViewCell: UITableViewCell {

    //MARK: -------------- VARIABLE
    var navCtrntl:UINavigationController?
    var delegate:sendBackHydrationData?
    
    var innerData:[HydrationDataModel]? = []
    var sectionInnerData:HydrationModel?
    
    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var dateMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var innerDataTblView: UITableView!
    @IBOutlet weak var innerDataTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.innerDataTblView.register(UINib(nibName: "HydrationDataInnerTableViewCell", bundle: nil), forCellReuseIdentifier: "HydrationDataInnerTableViewCell")
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.dateMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.dateLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
    
//    func reloadInnerTableView() -> CGFloat {
//        DispatchQueue.main.async {
////            self.innerDataTblView.reloadData()
//            self.innerDataTblViewHeightConstrnt.constant = self.innerDataTblView.contentSize.height
//            self.innerDataTblView.layoutIfNeeded()
//            self.layoutIfNeeded()
//        }
////        self.innerDataTblView.reloadData()
//        
//        return self.innerDataTblView.contentSize.height
//    }
    
//    override func updateConstraints() {
//        super.updateConstraints()
//        DispatchQueue.main.async {
//            self.innerDataTblViewHeightConstrnt.constant = self.innerDataTblView.contentSize.height
//        }
//        
//        self.layoutIfNeeded()
//    }
    
}


extension HydrationDataTableViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return innerData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HydrationDataInnerTableViewCell = innerDataTblView.dequeueReusableCell(withIdentifier: "HydrationDataInnerTableViewCell", for: indexPath) as! HydrationDataInnerTableViewCell
        cell.lineVLbl.isHidden = false
        
        cell.subTitleLbl.text = innerData?[indexPath.row].subTitle as? String
        cell.qntyBtn.setTitle(innerData?[indexPath.row].qnty as? String, for: .normal)
        
        if sectionInnerData?.title.uppercased() == "Settings".uppercased() {
            cell.qntyBtn.setImage(AppImages.forward, for: .normal)
            cell.qntyBtn.tag = 101 + indexPath.row
            cell.qntyBtn.accessibilityHint = innerData?[indexPath.row].subTitle as? String
            cell.qntyBtn.addTarget(self, action: #selector(settingsBtnActn(sender: )), for: .touchUpInside)
        }else{
            cell.qntyBtn.setImage(nil, for: .normal)
        }
        
        if tableView.isLastRow() == indexPath.row {
            cell.lineVLbl.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        DispatchQueue.main.async {
//            self.updateConstraints()
//        }
    }
    
    @objc func settingsBtnActn(sender: UIButton){
        print(sender.tag, sender.accessibilityHint ?? "")
        
        if sender.accessibilityHint?.uppercased() == "Glass Size".uppercased() {
            let vc:GlassSizeViewController = GlassSizeViewController.instantiate(appStoryboard: .more)
            vc.sendGlassGoals = { [weak self] getData in
                guard let self = self, let getData = getData else { return  }
                
                print("glass size: ",getData)
                self.sectionInnerData?.updateQuantity(for: "Glass Size", newQuantity: "\(getData)ml")
                
                let point : CGPoint = (sender as AnyObject).convert(CGPoint.zero, to:self.innerDataTblView)
                var indexPath =  self.innerDataTblView!.indexPathForRow(at: point)
                
                if let qntBtn = sender as? UIButton {
                    qntBtn.setTitle( "\(Int(getData))ml", for: .normal)
                }
                
                if let delegate = delegate {
                    delegate.sendGlassDizeData(data: "\(getData)")
                }
            }
            
            self.navCtrntl?.pushViewController(vc, animated: true)
            
        }else if sender.accessibilityHint?.uppercased() == "Goal".uppercased(){
            let vc:DailyGoalsPopupViewController = DailyGoalsPopupViewController.instantiate(appStoryboard: .more)
            vc.modalPresentationStyle = .automatic
            
            vc.sendDailyGoals = {[weak self] getData in
                guard let self = self else { return  }
                print(getData as Any)
                
                let point : CGPoint = (sender as AnyObject).convert(CGPoint.zero, to:self.innerDataTblView)
//                var indexPath =  self.innerDataTblView!.indexPathForRow(at: point)
                
                if let qntBtn = sender as? UIButton {
                    qntBtn.setTitle(getData, for: .normal)
                }
                
                if let delegate = delegate {
                    delegate.sendTargetGoalsData(data: getData)
                }
               
                
//                if let qntBtn = sender as? UIButton {
//                    if let cell = qntBtn.superview?.superview as? UITableViewCell,
//                       let indexPath = self.innerDataTblView?.indexPath(for: cell) {
//                        qntBtn.setTitle(getData, for: .normal)
//                    }
//                }
            }
            
            self.navCtrntl?.present(vc, animated: true)
        }
        else{
            let vc:UnitPopupViewController = UnitPopupViewController.instantiate(appStoryboard: .more)
            vc.modalPresentationStyle = .automatic
            vc.sendUnit = {[weak self] getData in
                guard let self = self else { return  }
                print(getData ?? "")
                
//                if let qntBtn = sender as? UIButton {
//                    if let cell = qntBtn.superview?.superview as? UITableViewCell,
//                       let indexPath = self.innerDataTblView?.indexPath(for: cell) {
//                        qntBtn.setTitle(getData, for: .normal)
//                    }
//                }
                
                //-----------***********
              
                let point : CGPoint = (sender as AnyObject).convert(CGPoint.zero, to:self.innerDataTblView)
                var indexPath =  self.innerDataTblView!.indexPathForRow(at: point)
                
                if let qntBtn = sender as? UIButton {
                    qntBtn.setTitle( getData, for: .normal)
                }
         
                //------------------**********
                
            }
            self.navCtrntl?.present(vc, animated: true)
        }
    }
        
}
