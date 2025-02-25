//
//  InnerTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 02/01/25.
//

import UIKit

class InnerTableViewCell: UITableViewCell {

    //MARK: -------------VARIABLE
    var levelCounts:Int = 1 {
        didSet{
//            setsCount.setTitle("\(levelCounts)", for: .normal)
        }
    }
    
    var buttonAction: (() -> Void)?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var levelTitleLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var setsCount: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        self.addBtn.addTarget(self, action: #selector(addBtnActn(sender: )), for: .touchUpInside)
        self.minusBtn.addTarget(self, action: #selector(minusBtnActn(sender: )), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func addBtnActn(sender:UIButton){
        guard levelCounts != 0 else {
            return
        }
         levelCounts += 1
        buttonAction?()
    }
    
    @objc func minusBtnActn(sender:UIButton){
        guard levelCounts > 1 else {
            return
        }
        
        levelCounts -= 1
        buttonAction?()
    }
    
    func setupFont(){
        levelTitleLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        setsCount.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
//    func handleButtonTap(at indexPath: IndexPath) {
//           // Update the data for the tapped row
////           data[indexPath.row] = "Updated \(indexPath.row + 1)"
//           
//           // Reload the specific row
//           self.reloadRows(at: [indexPath], with: .automatic)
//       }
    
//    func setTimeLbl(_ inputTitle:String? = nil){
//        guard let inputTitle = inputTitle else { return }
//        if inputTitle == "Rest Time" {
//            self.setsCount.setTitle("\(levelCounts) :00", for: .normal)
//        }else{
//            self.setsCount.setTitle("\(levelCounts)", for: .normal)
//        }
//    }
    
}
