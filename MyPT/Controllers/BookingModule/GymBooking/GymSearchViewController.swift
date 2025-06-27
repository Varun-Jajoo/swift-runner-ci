//
//  GymSearchViewController.swift
//  MyPT
//
//  Created by techsaga corp on 09/06/25.
//

import UIKit

class GymSearchViewController: UIViewController {

    //MARK: ---------------VARIABLE
    var inputType:String?
    var inputLat:String?
    var inputLong:String?
    var gymStudioFlow:calendarFlow = .defaultFlow
    var searchStr: String?
    var searchStudiosData:[TrainerModel]? = []
    var seacrhGymTrainerData:[GymTrainerModel]? = []
    private var localSearchStudiosData:[TrainerModel]? = []
    private var localhGymTrainerData:[GymTrainerModel]? = []
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var seachMBV: UIView!
    @IBOutlet weak var nearMeGymMBV: UIView!
    @IBOutlet weak var gymSearchbar: UISearchBar!
    @IBOutlet weak var gymListTblView: UITableView!
    @IBOutlet weak var gymNearLbl: UILabel!
    @IBOutlet weak var gynNearBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.localSearchStudiosData = self.searchStudiosData
        self.gymSearchbar.addDoneButtonOnKeyboard()
        self.setupUI()
        self.setUISearchbar()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func leftNavBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gynNearBtnActn(_ sender: Any) {
        print("near gym ")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setUISearchbar(){
        self.gymSearchbar.barTintColor = UIColor.clear
        self.gymSearchbar.isTranslucent = false
        self.gymSearchbar.backgroundColor = .clear
        self.gymSearchbar.searchTextField.backgroundColor = .clear
//        self.gymSearchbar.layer.borderWidth = 1.0
//        self.gymSearchbar.layer.borderColor = UIColor.txtDarkGray.cgColor
                
        self.gymSearchbar.setImage(UIImage(named: "ic_search_normal"), for: .search, state: .normal)
        
         if let searchTextField = self.gymSearchbar.value(forKey: "searchField") as? UITextField {
             searchTextField.backgroundColor = UIColor.clear
             searchTextField.textColor = UIColor.appWhite
             searchTextField.setMultiColorPlaceholder(firstStr: "Search Gym", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: "", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
         }
    }
    
    private func setupUI(){
        gymNearLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.seachMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
        }
        
        gymListTblView.register(UINib(nibName: "GymSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "GymSearchTableViewCell")
        
    }
    
}

extension GymSearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: self.searchStudiosData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GymSearchTableViewCell = gymListTblView.dequeueReusableCell(withIdentifier: "GymSearchTableViewCell", for: indexPath) as! GymSearchTableViewCell
        cell.studioNameLbl.text = self.searchStudiosData?[indexPath.row].name
        cell.addrLbl.text = self.searchStudiosData?[indexPath.row].location
        cell.distanceLbl.text = self.searchStudiosData?[indexPath.row].distance
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        vc.inputStudioId = String(self.searchStudiosData?[indexPath.row].id ?? 0)
        vc.inputLat = self.inputLat
        vc.inputLong = self.inputLong
        vc.inputType = self.inputType
        vc.gymDetailsFlow = gymStudioFlow
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: ---------------- SEARCHBAR DELEAGTE
extension GymSearchViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
//        searchBar.showsCancelButton = false
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform search action with the search text
        print("Search text: \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
    }
    
    // SearchBar Delegate
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText.isEmpty {
              self.searchStudiosData?.removeAll()
              self.searchStudiosData = self.localSearchStudiosData
              print("in empty localSearchStudiosData: ", self.localSearchStudiosData?.count as Any)
          } else {
              if let trainerData = self.localSearchStudiosData {
                  self.searchStudiosData = trainerData.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
                  print("in filter trainerData: ", self.localSearchStudiosData?.count as Any)
              }else{
                  print("in outer trainerData: ", self.searchStudiosData?.count as Any)
              }
          }
          
          self.gymListTblView.reloadData()
      }
    
 
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         print(searchBar.text as Any)
         }
    
     
         func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
                searchBar.resignFirstResponder()
         }
}
