//
//  SupersetTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/09/25.
//

import UIKit

class SupersetTableViewCell: UITableViewCell {

    //MARK: ----------- VARIOABLE
    var setsData:[ExercisesDatailsModel]? = [] {
          didSet {
              setsLstTblView.reloadData()
//              updateInnerTableHeight()
          }
      }
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var cellMSTCKV: UIStackView!
    @IBOutlet weak var superSetLstMBV: UIView!
    @IBOutlet weak var supersetCountMBV: UIView!
    @IBOutlet weak var restMBV: UIView!
    @IBOutlet weak var restTimeMBV: UIView!
    @IBOutlet weak var supersetCountLbl: UILabel!
    @IBOutlet weak var restTitleLbl: UILabel!
    @IBOutlet weak var restTimeLbl: UILabel!
    @IBOutlet weak var restTimeEditImgView: UIImageView!
    @IBOutlet weak var setsLstTblView: UITableView!
    @IBOutlet weak var setsCountBtn: UIButton!
    @IBOutlet weak var restTimeEditBtn: UIButton!
    @IBOutlet weak var restDeleteBtn: UIButton!
    @IBOutlet weak var resrMenuBtn: UIButton!
    @IBOutlet weak var setsLstTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        self.setsLstTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        self.setsLstTblView.isScrollEnabled = false
        
        self.setupFont()
        self.setupUI()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateInnerTableHeight() {
        self.setsLstTblView.layoutIfNeeded()
        self.setsLstTblViewHeightConstrnt.constant = setsLstTblView.contentSize.height
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
        
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMSTCKV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 62.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 20.0)
            self.supersetCountMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
        }
    }
    
    private func setupFont(){
        self.supersetCountLbl.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.setsCountBtn.titleLabel?.font = AppFont.medium.size(15.0, familyName: familyManrope)
        self.restTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.restTimeLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
}


//MARK: ------------------- UITABLEVIEW DELEGATE/DATASOURCE
extension SupersetTableViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let exerciseCell:ExerciseTableViewCell = setsLstTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        
        return exerciseCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == setsLstTblView {
            DispatchQueue.main.async {
                self.updateInnerTableHeight()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == setsLstTblView {
            DispatchQueue.main.async {
                self.updateInnerTableHeight()
            }
        }
    }
    
}
