//
//  CancellationPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 06/03/25.
//

import UIKit


class ProductCancelPopupViewController: UIViewController {

    //MARK: ------------VARIABLE
    var reasonData:[String]?
    var navCntrl:UINavigationController?
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var productCancelPopupMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var reasonTblView: UITableView!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var reasonTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reasonData = [
            "Found a Better Price Elsewhere",
            "Changed Mind About the Purchase",
            "Expected Delivery Date Too Late",
            "Incorrect Product Ordered"
        ]

        self.titleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.cancelOrderBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        self.reasonTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        self.enableContinueBtn(isSelected: false, btn: self.cancelOrderBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }

    @IBAction func cancelOrderBtnActn(_ sender: Any) {
        print("Cancel Order .......")
        self.dismiss(animated: true, completion: {
            let vc: OrderConfirmedViewController = OrderConfirmedViewController.instantiate(appStoryboard: .shop)
            vc.flowOrder = .cancelOrder
            self.navCntrl?.pushViewController(vc, animated: true)
        })
    
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.productCancelPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.cancelOrderBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if self.reasonTblView.contentSize.height != 0 {
            self.reasonTblViewHeightConstrnt.constant = self.reasonTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.productCancelPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

extension ProductCancelPopupViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasonData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PointsTableViewCell = reasonTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
        
        cell.titleLbl.text =  reasonData?[indexPath.row] as? String
        cell.leftImgView.image = UIImage(named: "ic_filterUncheck")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            selectedCell.leftImgView.image = UIImage(named: "ic_filterChecked")
        
        self.enableContinueBtn(isSelected: true, btn: self.cancelOrderBtn)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let deselectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            deselectedCell.leftImgView.image = UIImage(named: "ic_filterUncheck")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
}
