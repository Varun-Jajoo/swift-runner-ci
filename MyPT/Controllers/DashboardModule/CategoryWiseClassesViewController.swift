//
//  CategoryWiseClassesViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/05/25.
//

import UIKit

class CategoryWiseClassesViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
        
    var categoryIdStr: String?
    var classesData: [UpcomingClassModel]? = []
    
    @IBOutlet weak var classesTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classesTblView.isHidden = true
        classesTblView.register(UINib(nibName: "ClassesNearControllerTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassesNearControllerTableViewCell")
        
        self.classesCategoryWiseApi()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Classes"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }

    //-------------------UITableview Delegate / Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: self.classesData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 210, height: 210)), fromCenter: -100)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ClassesNearControllerTableViewCell = classesTblView.dequeueReusableCell(withIdentifier: "ClassesNearControllerTableViewCell", for: indexPath) as! ClassesNearControllerTableViewCell
        
        cell.setCell(cellData: classesData?[indexPath.row])
        
//        cell.classesBckImgView.image = UIImage(named: "ic_trainer")?.resized(to: CGSize(width: cell.frame.size.width, height: 250))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
        vc.scheludeIdStr = "\(classesData?[indexPath.row].scheduleID ?? 0)"
        vc.inputLat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first
        vc.inputLong = appUserDefaults.getLatLong()?.components(separatedBy: ",").last
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryWiseClassesViewController{
    
    private func classesCategoryWiseApi(){
         let params:[String:String] = [
            "long": appUserDefaults.getLatLong()?.components(separatedBy: ",").last ?? "",
            "lat": appUserDefaults.getLatLong()?.components(separatedBy: ",").first ?? "",
            "category_id": self.categoryIdStr ?? ""
         ]
       
        UpcomingClassVM.categoryWiseClassesApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.classesTblView.isHidden = false
            self.classesData?.removeAll()
            self.classesData?.append(contentsOf: getResultData.data ?? [])
            self.classesTblView.reloadData()
        })
    }
}
