//
//  ReturnRequestViewController.swift
//  MyPT
//
//  Created by techsaga corp on 10/03/25.
//

import UIKit

class ReturnRequestViewController: UIViewController {

    //MARK: ------------------IBOUTLET
    @IBOutlet weak var returnRequestMBV: UIView!
    @IBOutlet weak var pickupMBV: UIView!
    @IBOutlet weak var returnGuideLinesMBV: UIView!
    @IBOutlet weak var checkImgView: UIImageView!
    @IBOutlet weak var returnRequestTitleLbl: UILabel!
    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var pickupTitleLbl: UILabel!
    @IBOutlet weak var pickupDateLbl: UILabel!
    @IBOutlet weak var returnGuideLinesTitleLbl: UILabel!
    @IBOutlet weak var returnGuideLinesDescLbl: UILabel!
    @IBOutlet weak var backHomeBtn: UIButton!
    @IBOutlet weak var returnProductTblView: UITableView!
    @IBOutlet weak var returnProductTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
        self.setInputData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func backHomeBtnActn(_ sender: Any) {
        print("Back to home btn clicked...")
        self.navigationController?.popToViewController(ofClass: ProductsViewController.self, animated: true)
    }
    
    
    private func setInputData(){
        self.orderIdLbl.text = "Reference Number: 447895483248"
    }
    
    private func setupUI(){
        
        self.returnProductTblView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
        
        //-----------------***************
        DispatchQueue.main.async {
            self.returnGuideLinesMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.backHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.returnRequestTitleLbl.font = AppFont.semibold.size(24.0, familyName: familyClashDisplay)
        self.orderIdLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.pickupTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.pickupDateLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.returnGuideLinesTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.returnGuideLinesDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.backHomeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if self.returnProductTblView.contentSize.height != 0 {
            self.returnProductTblViewHeightConstrnt.constant = self.returnProductTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
}

//MARK: --------------------------UITABLEVIEW DATASOURCE/ DELEGATE
extension ReturnRequestViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderTableViewCell = returnProductTblView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
       
        cell.stutusTitleLbl.isHidden = true
        cell.estimatedDelDateLbl.isHidden = true
        cell.orderIdLbl.isHidden = true
        cell.stutusTitleLbl.text = nil
        cell.estimatedDelDateLbl.text = nil
        cell.orderIdLbl.text = nil
        
        cell.paymentModeLbl.text = "A refund amount of AED 220 will be initated after the iteam is picked up and quality check has passed"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
