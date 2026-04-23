//
//  TrainerGymAddressVC.swift
//  MyPT
//
//  Created by Manik Goel on 05/04/26.
//

import UIKit

class TrainerGymAddressVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var inputParam: DetailsParam?
    var trainerData: GymTrainerModel?
    var studiosData: [StudioModel]?
    var callBack: ((StudioModel) -> Void)?
    
    @IBOutlet weak var viewPresent: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var collectionWorkout: UICollectionView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblTrainingAt: UILabel!
    @IBOutlet weak var tableGym: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        getTrainerStudiosList()
    }
    
    private func uiSetup() {
        self.collectionWorkout.delegate = self
        self.collectionWorkout.dataSource = self
        self.tableGym.delegate = self
        self.tableGym.dataSource = self
        self.collectionWorkout.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
//        self.collectionWorkout.register(UINib(nibName: "UnavailableTimeCVCell", bundle: nil), forCellWithReuseIdentifier: "UnavailableTimeCVCell")
        self.tableGym.register(UINib(nibName: "TraiinerGymAddressTVCell", bundle: nil),
                               forCellReuseIdentifier: "TraiinerGymAddressTVCell")
        DispatchQueue.main.async {
            self.lblTrainerName.font = AppFont.medium.size(22.0, familyName: familyFunnelSans)
            self.lblRating.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblTrainingAt.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        }
    }
    
    func setData() {
        lblTrainerName.text = trainerData?.name ?? ""
        lblRating.text = trainerData?.noOfRating ?? ""
        imgTrainer.loadImage(urlString: trainerData?.profile, placeholder: UIImage())
    }
    
    @IBAction func onTapContinue(_ sender: UIButton) {
        if let selectedStudio = studiosData?.first(where: { $0.isSelected ?? false }) {
            self.dismiss(animated: true, completion: {
                self.callBack?(selectedStudio)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studiosData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TraiinerGymAddressTVCell", for: indexPath) as? TraiinerGymAddressTVCell else { return UITableViewCell() }
        if let data = studiosData?[indexPath.row] {
            cell.setStudioData(data: data)
            cell.btnRadio.setImage(UIImage(named: data.isSelected ?? false ? "Radio" : "Unradio"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        for i in 0..<studiosData!.count {
            studiosData?[i].isSelected = false
        }
        studiosData?[indexPath.row].isSelected = true
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerData?.tags?.count, totalCount > 2 {
            return 3
        } else {
            return trainerData?.tags?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = collectionWorkout.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        DispatchQueue.main.async {
            cell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1), cornerRadious: 8)
            cell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
        
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerData?.tags?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
        }else{
            cell.titleLbl.text = trainerData?.tags?[indexPath.row].name?.uppercased() as? String
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let value = trainerData?.tags?[indexPath.item].name

           // Use the same font as NumberCell label
        let font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
           
           // Measure text width
        let textWidth = (value)?.size(withAttributes: [.font: font]).width ?? 20.0
           
           return CGSize(width: textWidth + 50, height: collectionView.frame.height)
        
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    //            // Check if any range contains the index
    //            return !restrictedRange.contains { $0.contains(indexPath.item) }
    //        }
    
    
    //    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        return trainerData?.tags?.count ?? 0
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        guard let cell = collectionView.dequeueReusableCell(
    //            withReuseIdentifier: "UnavailableTimeCVCell", for: indexPath
    //        ) as? UnavailableTimeCVCell else { return UICollectionViewCell() }
    //        return cell
    //    }
    
    private func getTrainerStudiosList() {
        let params: [String: String] = [
            "long": inputParam?.long ?? "0.0",
            "lat": inputParam?.lat ?? "0.0",
            "trainer_id": inputParam?.trainer_id ?? ""
        ]
        
        HomepageViewModel.getTrainerStudiosList(params: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print(getResultData)
            trainerData = getResultData.data?.trainer
            studiosData = getResultData.data?.studios?.enumerated().map { index, item in
                return StudioModel(
                    id: item.id,
                    address: item.address,
                    distance: item.distance,
                    image: item.image,
                    name: item.name,
                    isSelected: index == 0
                )
            }
            setData()
            self.tableGym.reloadData()
            self.collectionWorkout.reloadData()
        })
    }
}
