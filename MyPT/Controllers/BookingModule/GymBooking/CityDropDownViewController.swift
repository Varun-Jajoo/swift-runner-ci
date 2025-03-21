//
//  CityDropDownViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/03/25.
//

import UIKit

class CityDropDownViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    //-----------------VARIABLE
    var sentBackData: ((_ name: String?, _ id: Int?, _ countyName: String?, _ countryId: Int?) -> Void)?
    var countName: String?
    var countId: Int?
    var cityData:[CityModel]? = []
    
    //-----------------IBOUTLET
    @IBOutlet weak var dataListTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.dataListTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        self.getCityListApi()
    }
    
    //MARK: --------------------- DATASOURCE / DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: self.cityData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PointsTableViewCell = dataListTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
        cell.leftImgView.isHidden = true
        cell.leftImgView.image = nil
        
        cell.titleLbl.text = cityData?[indexPath.row].name
        cell.titleLbl.textAlignment = .center
        
//        cell.leftImgView.image = AppImages.filterUncheck
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.sentBackData?(cityData?[indexPath.row].name, cityData?[indexPath.row].id, self.countName, self.countId)
        self.dismiss(animated: true, completion: nil)
        
//        let selectedCell = tableView.cellForRow(at: indexPath) as? PointsTableViewCell
//        selectedCell?.leftImgView.image = UIImage(named: "ic_filterChecked")
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let deselectedCell = tableView.cellForRow(at: indexPath) as? PointsTableViewCell
//        deselectedCell?.leftImgView.image = UIImage(named: "ic_filterUncheck")
//    }
}

extension CityDropDownViewController{
   
    private func getCityListApi(){
        TrainerVM.getCityApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData)
            self.countName = getResultData.data?.name
            self.countId = getResultData.data?.id
            self.cityData?.removeAll()
            self.cityData?.append(contentsOf: getResultData.data?.cities ?? [])
            self.dataListTblView.reloadData()
        })
    }
}
