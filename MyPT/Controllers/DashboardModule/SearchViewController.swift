//
//  SearchViewController.swift
//  MyPT
//
//  Created by techsaga corp on 11/03/25.
//

import UIKit

class SearchViewController: UIViewController {

    //MARK: ---------------VARIABLE
    var searchStr: String?
    var searchTrainerData:[TrainerModel]? = []
    var seacrhGymTrainerData:[GymTrainerModel]? = []
    private var localTrainerData:[TrainerModel]? = []
    private var loaclhGymTrainerData:[GymTrainerModel]? = []
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var topSearchMBV: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var seachbar: UISearchBar!
    @IBOutlet weak var recordTblView: UITableView!
    @IBOutlet weak var shortcutCollView: UICollectionView!
    @IBOutlet weak var recentSearchLbl: UILabel!
    @IBOutlet weak var quickShortcutsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func leftBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setUISearchbar(){
        self.seachbar.barTintColor = UIColor.clear
        self.seachbar.isTranslucent = false
        self.seachbar.backgroundColor = .clear
        self.seachbar.searchTextField.backgroundColor = .clear
//        self.seachbar.layer.borderWidth = 1.0
//        self.seachbar.layer.borderColor = UIColor.txtDarkGray.cgColor
                
        self.seachbar.setImage(UIImage(named: "ic_search_normal"), for: .search, state: .normal)
        
         if let searchTextField = self.seachbar.value(forKey: "searchField") as? UITextField {
             searchTextField.backgroundColor = UIColor.clear
             searchTextField.textColor = UIColor.appWhite
             searchTextField.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: searchStr ?? "", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
         }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.topSearchMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
        }
        
        //------------------Font setup
        self.recentSearchLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.quickShortcutsLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        //-----------------------Register Tableviw/Collectionview
        recordTblView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        shortcutCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        
    }

}

//MARK: ---------------UITABLEVIEW DATASOURCE/ DELEGATE
extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return tableView.numberOfRows(count: self.searchTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        
//        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = recordTblView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        cell.searchTitleLbl.text = self.searchTrainerData?[indexPath.row].name
        cell.subTitleLbl.text = self.searchTrainerData?[indexPath.row].description
        
        return cell
    }
    
    
}

//MARK: ---------------UICOLLECTIONVIEW DATASOURCE/ DELEGATE

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoreExploreCollectionViewCell = shortcutCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
        cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        cell.titleLbl.textColor = UIColor.appWhite
        
        return cell
    }
    
    
}
