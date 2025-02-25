//
//  AddSetsTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 02/01/25.
//

import UIKit

class AddSetsTableViewCell: UITableViewCell {

    //MARK: ---------------------- VARIABLE
    var setData:[Any]?
    
    //MARK: ---------------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var setIndxMBV: UIView!
    @IBOutlet weak var setIndxLbl: UILabel!
    @IBOutlet weak var setsTitleLbl: UILabel!
    @IBOutlet weak var respsLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var expendingImgView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var innnerTblView: UITableView!
    
    @IBOutlet weak var innnerTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setData = ["Minimum  Reps","Maximum  Reps","Rest Time"]
        
        self.setupFont()
        self.innnerTblView.register(UINib(nibName: "InnerTableViewCell", bundle: nil), forCellReuseIdentifier: "InnerTableViewCell")
        DispatchQueue.main.async {
            self.setIndxMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
            self.lineView.backgroundColor = UIColor.clear
            self.lineView.addGradient(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0), UIColor(red: 52.0/255.0, green: 55.0/255.0, blue: 57.0/255.0, alpha: 1),UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0)], locations: [0.2,1], startPoint: CGPoint(x: 1.0, y: 1.0), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 2.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFont(){
        self.setIndxLbl.font  = AppFont.bold.size(20.0, familyName: familyManrope)
        self.setsTitleLbl.font  = AppFont.bold.size(20.0, familyName: familyManrope)
        self.respsLbl.font  = AppFont.bold.size(14.0, familyName: familyManrope)
        self.restLbl.font  = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
}

extension AddSetsTableViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:InnerTableViewCell = innnerTblView.dequeueReusableCell(withIdentifier: "InnerTableViewCell", for: indexPath) as! InnerTableViewCell
        
        cell.levelTitleLbl.text = setData?[indexPath.row] as? String
        
        if cell.levelTitleLbl.text == "Rest Time" {
            cell.setsCount.setTitle("1:00", for: .normal)
        }else{
            cell.setsCount.setTitle("1", for: .normal)
        }
        
        // Set the button action
        cell.buttonAction = { [weak self] in
            guard self != nil else {
                return
            }
            if cell.levelTitleLbl.text == "Rest Time" {
                cell.setsCount.setTitle("\(cell.levelCounts) :00", for: .normal)
            }else{
                cell.setsCount.setTitle("\(cell.levelCounts   )", for: .normal)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        footerView.backgroundColor = UIColor.clear
        
        let addSetBtn = UIButton()
//        addSetBtn.setTitle("Apply to all sets", for: .normal)
        addSetBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        addSetBtn.setTitleColor(UIColor.appWhite, for: .normal)
        addSetBtn.addTarget(self, action: #selector(applyAllSetsBtnActn(sneder: )), for: .touchUpInside)
        footerView.addSubview(addSetBtn)
        
        addSetBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            addSetBtn.centerXAnchor.constraint(equalTo: footerView.centerXAnchor, constant: 0),
            addSetBtn.centerYAnchor.constraint(equalTo: footerView.centerYAnchor, constant: 0)
        ])
        
        let title = "Apply to all sets"
        let attributedString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                         .underlineColor: UIColor.txtDarkGray, .foregroundColor: UIColor.appWhite,
                         .font: AppFont.bold.size(16.0, familyName: familyManrope)
            ]
        )
        addSetBtn.setAttributedTitle(attributedString, for: .normal)
        
        
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc func applyAllSetsBtnActn(sneder: UIButton){
        print("Apply to all sets btn clicked....")
    }
}
