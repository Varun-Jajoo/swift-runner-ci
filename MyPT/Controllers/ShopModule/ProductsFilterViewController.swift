//
//  ProductsFilterViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/02/25.
//

import UIKit

class ProductsFilterViewController: CommonViewController {

    //MARK: ------------------ VARIABLE
    var sideMenu:[String]?
    var filterList:[String]?
    var sendBackCount:((Int?) -> Void)?
    
    private var filterCount:Int = 0{
        didSet{
            if filterCount != 0{
                applyFilterBtn.setTitle("APPLY FILTER(\(filterCount))", for: .normal)
            }else{
                applyFilterBtn.setTitle("APPLY FILTER", for: .normal)
            }
        }
    }
    
    
    //MARK: ------------------- IBOUTLET
    @IBOutlet weak var sideLeftTblView: UITableView!
    @IBOutlet weak var filterListTblView: UITableView!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var applyFilterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.sideMenu = [
            "\n Categories \n",
            "\n Price \n",
            "\n Brand \n",
            "\n Ratings \n"
        ]
        
        self.filterList = [
            "Fitness Equipment",
            "Apparel & Accessories",
            "Supplements & Nutrition",
            "Personal Care & Wellness",
            "Healthy Food & Snacks",
            "Home Gym Essentials",
            "Sports Nutrition"
        ]
        self.sideLeftTblView.reloadData()
        self.filterListTblView.reloadData()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let firstIndexPath = IndexPath(row: 0, section: 0)
        sideLeftTblView.selectRow(at: firstIndexPath, animated: true, scrollPosition: .none)
        // Optionally, trigger delegate method manually
        sideLeftTblView.delegate?.tableView?(sideLeftTblView, didSelectRowAt: firstIndexPath)
    }
    
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.shop], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func resetBtnActn(_ sender: Any) {
        print("reset btn clicked.")
        filterCount = 0
        self.filterListTblView.reloadData()
    }
    
    @IBAction func applyFilterBtnActn(_ sender: Any) {
        print("apply filter btn clicked.")
        self.sendBackCount?(filterCount)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI(){
        self.filterListTblView.allowsMultipleSelection = true
        
        self.sideLeftTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        self.filterListTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        self.resetBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.applyFilterBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        //-------------********
        DispatchQueue.main.async {
            self.resetBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.applyFilterBtn.setCornerRadius(borderWidth: 0.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
}

extension ProductsFilterViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == sideLeftTblView {
            return sideMenu?.count ?? 0
        }else{
            return filterList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sideLeftTblView {
            let sideLeftCell: PointsTableViewCell = sideLeftTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            
            sideLeftCell.leftImgView.isHidden = true
            sideLeftCell.titleLbl.text = sideMenu?[indexPath.row] as? String
            sideLeftCell.titleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
            sideLeftCell.titleLbl.textAlignment = .left
            
            return sideLeftCell
        }else{
            let filterCell: PointsTableViewCell = sideLeftTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            
            filterCell.leftImgView.isHidden = false
            filterCell.leftImgView.image = AppImages.filterUncheck
            filterCell.titleLbl.text = (filterList?[indexPath.row] as? String ?? "") + "\n "
            filterCell.titleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
            
            return filterCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sideLeftTblView {
            let selectedCell: PointsTableViewCell = sideLeftTblView.cellForRow(at: indexPath) as! PointsTableViewCell
            DispatchQueue.main.async {
                    selectedCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appOuterProgress, cornerRadious: 8.0)
            }
        }else{
            let filterSelectedCell: PointsTableViewCell = filterListTblView.cellForRow(at: indexPath) as! PointsTableViewCell
            filterSelectedCell.leftImgView.isHidden = false
            filterSelectedCell.leftImgView.image = AppImages.filterChecked

            self.filterCount += 1
        }

    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == sideLeftTblView {
            let selectedCell: PointsTableViewCell = sideLeftTblView.cellForRow(at: indexPath) as! PointsTableViewCell
            
            DispatchQueue.main.async {
                selectedCell.cellMBV.setCornerRadius(borderWidth: 0.0, borderColor: UIColor.appOuterProgress, cornerRadious: 0.0)
            }
        }else{
            let filterSelectedCell: PointsTableViewCell = filterListTblView.cellForRow(at: indexPath) as! PointsTableViewCell
            filterSelectedCell.leftImgView.isHidden = false
            filterSelectedCell.leftImgView.image = AppImages.filterUncheck
            
            guard filterCount > 0 else { return
            }
            
            self.filterCount -= 1
        }
    }
    
}
