//
//  OrderHistoryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/03/25.
//

import UIKit

class OrderHistoryViewController: CommonViewController, UITableViewDataSource, UITableViewDelegate{
  
    var orderList:[Any]? = []
    
    @IBOutlet weak var orderHistoryTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderHistoryTblView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
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
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.my_orders], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ProductsViewController.self, animated: true)
    }

    //---------------------TABLEVIEW DATASOURCE/ DELEGATE
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return setupRow(inputTable: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderTableViewCell = orderHistoryTblView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: MyOrderStatusViewController = MyOrderStatusViewController.instantiate(appStoryboard: .shop)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerV = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let headerSubVMBV = UIView()
        let headerLbltLbl = UILabel()
        let filterBtn = UIButton()
        
        headerV.backgroundColor = UIColor.clear
        headerSubVMBV.backgroundColor = UIColor.clear
        headerV.addSubview(headerSubVMBV)
        headerSubVMBV.addSubview(headerLbltLbl)
        headerSubVMBV.addSubview(filterBtn)
       
        
        headerSubVMBV.translatesAutoresizingMaskIntoConstraints = false
        headerLbltLbl.translatesAutoresizingMaskIntoConstraints = false
        filterBtn.translatesAutoresizingMaskIntoConstraints = false
        
        //----------make constraint
        NSLayoutConstraint.activate([
            headerSubVMBV.leadingAnchor.constraint(equalTo: headerV.leadingAnchor, constant: 20),
            headerSubVMBV.trailingAnchor.constraint(equalTo: headerV.trailingAnchor, constant: -20),
            headerSubVMBV.topAnchor.constraint(equalTo: headerV.topAnchor, constant: 2),
            headerSubVMBV.bottomAnchor.constraint(equalTo: headerV.bottomAnchor, constant: -2),
            headerLbltLbl.leadingAnchor.constraint(equalTo: headerSubVMBV.leadingAnchor, constant: 1),
            headerLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
            headerLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2),
            filterBtn.leadingAnchor.constraint(equalTo: headerLbltLbl.trailingAnchor, constant: 12.0),
            filterBtn.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
            filterBtn.heightAnchor.constraint(equalToConstant: 30),
            filterBtn.centerXAnchor.constraint(equalTo: headerLbltLbl.centerXAnchor)
            
            ])
        
        //------------------Input Data
        headerLbltLbl.text = "Last 6 Months"
        headerLbltLbl.textColor = UIColor.txtDarkGray
        headerLbltLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        filterBtn.setTitle("FILTER", for: .normal)
        filterBtn.setImage(UIImage(named: "ic_filter_MyOrder"), for: .normal)
        filterBtn.setTitleColor(UIColor.appWhite, for: .normal)
        filterBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        filterBtn.addTarget(self, action: #selector(filterBtnActn(sender: )), for: .touchUpInside)
        
        return headerV
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if orderList?.count != 0 {
            return 30
        }else{
            return 0
        }
    }
    
    @objc func filterBtnActn(sender: UIButton){
        self.orderList?.append(1)
        self.orderHistoryTblView.reloadData()
    }
    
    //MARK: ------------ SETUP NO DATA FOUND
    private func setupRow(inputTable:UITableView) -> Int {
        
        return inputTable.numberOfRows(count: self.orderList?.count ?? 0, title: AppStrings.your_Workout_Gear_is_Waiting, message: AppStrings.empty_MyOrders_Msg, messageImage: UIImage(named: "ic_emptyMyOrder"), messageImageHeight: 120.0, reloadBtnBgColor: UIColor.appWhite, reloadBtnTitleColor: UIColor.mainBg, reloadSetTitle: "START SHOPPING", target: self, action: #selector(startShoppingBtnActn(sender: )), fromCenter: -2, fromTop: nil)
    }
    
    @objc func startShoppingBtnActn(sender: UIButton){
        print("start shoppoing btn clicked..")
        self.navigationController?.popToViewController(ofClass: ProductsViewController.self, animated: true)
    }
}

