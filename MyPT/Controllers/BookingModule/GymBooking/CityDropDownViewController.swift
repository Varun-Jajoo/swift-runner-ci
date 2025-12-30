//
//  CityDropDownViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/03/25.
//

import UIKit

enum CustomPopupDataFlow {
    case filtersWorkout
    case cityDefault
}

class CityDropDownViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    //-----------------VARIABLE
    var sentBackData: ((_ name: String?, _ id: Int?, _ countyName: String?, _ countryId: Int?) -> Void)?
    var countName: String?
    var countId: Int?
    var getAlltCityData: CityDataModel?
    var cityData:[CityModel]? = []
    var workoutFilters:[WorkoutLevelModel]? = []
    var flowData: CustomPopupDataFlow = .cityDefault
    
    
    //-----------------IBOUTLET
    @IBOutlet weak var dataListTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.dataListTblView.showsVerticalScrollIndicator = false
        self.dataListTblView.showsHorizontalScrollIndicator = false
        self.dataListTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        self.inputData()
    }
    
    private func inputData(){

        switch flowData {
        case .filtersWorkout:
            print("filters workout data........")
        case .cityDefault:
            if let cityData = cityData, cityData.count < 0 || cityData.isEmpty {
                self.getCityListApi()
            }
        }
    }
    
   
    //MARK: --------------------- DATASOURCE / DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.cityData?.count ?? 0
        switch flowData {
        case .filtersWorkout:
            return workoutFilters?.count ?? 0
        case .cityDefault:
            return self.cityData?.count ?? 0
        }
        
//        return tableView.numberOfRows(count: self.cityData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PointsTableViewCell = dataListTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
        cell.leftImgView.isHidden = true
        cell.leftImgView.image = nil
                
        switch flowData {
        case .filtersWorkout:
            cell.titleLbl.text = workoutFilters?[indexPath.row].name
            cell.titleLbl.textAlignment = .center
        case .cityDefault:
            cell.titleLbl.text = cityData?[indexPath.row].name
            cell.titleLbl.textAlignment = .center
        }
        
        //        cell.titleLbl.text = cityData?[indexPath.row].name
        //        cell.titleLbl.textAlignment = .center
//        cell.leftImgView.image = AppImages.filterUncheck
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch flowData {
        case .filtersWorkout:
            self.sentBackData?(workoutFilters?[indexPath.row].name, Int(workoutFilters?[indexPath.row].id?.value ?? "0"), nil,nil)
            self.dismiss(animated: true, completion: nil)
        case .cityDefault:
            
            self.countName = getAlltCityData?.name
            self.countId = getAlltCityData?.id
            self.sentBackData?(cityData?[indexPath.row].name, cityData?[indexPath.row].id, self.countName, self.countId)
            self.dismiss(animated: true, completion: nil)
        }
        
//        self.countName = getAlltCityData?.name
//        self.countId = getAlltCityData?.id
//        self.sentBackData?(cityData?[indexPath.row].name, cityData?[indexPath.row].id, self.countName, self.countId)
//        self.dismiss(animated: true, completion: nil)
    
        
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
            self.getAlltCityData = nil
            self.getAlltCityData = getResultData.data
            self.countName = getResultData.data?.name
            self.countId = getResultData.data?.id
            self.cityData?.removeAll()
            self.cityData?.append(contentsOf: getResultData.data?.cities ?? [])
            self.dataListTblView.reloadData()
        })
    }
}
