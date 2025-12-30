//
//  RestTableViewCell.swift
//  My-PT-Trainer
//
//  Created by Manik Goel on 02/08/25.
//

import UIKit

protocol RestTableViewCellDelegate: AnyObject {
    func onTapCancelRest(_ cell: RestTableViewCell)
}

protocol deleteRestProtocol: AnyObject {
    func onTapCross(_ cell: RestTableViewCell)
    func onTimeTap(_ cell: RestTableViewCell)
}


class RestTableViewCell: UITableViewCell {
    
    var onTimeTap: (() -> Void)?
    
    weak var delegate: RestTableViewCellDelegate?
    weak var deleteDelegate: deleteRestProtocol?
    
    @IBOutlet weak var viewReset: UIView!
    @IBOutlet weak var viewSeconds: UIView!
    @IBOutlet weak var lblReset: UILabel!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var btnRest: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        [
            self.lblReset,
            self.lblSeconds
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12, familyName: familyManrope)
        })
        
        self.setupUI()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.viewReset.addGradient(colors: [
                UIColor(red: 226.0/255.0, green: 188.0/255.0, blue: 160.0/255.0, alpha: 0.4),
                UIColor(red: 107.0/255.0, green: 83.0/255.0, blue: 66.0/255.0, alpha: 0.4)
            ], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 16.0)
            //rgba(226, 188, 160, 1)
            //rgba(107, 83, 66, 1)
            self.viewReset.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 226.0/255.0, green: 188.0/255.0, blue: 160.0/255.0, alpha: 1.0), cornerRadious: 16.0)
            self.viewSeconds.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    @IBAction func onTapCross(_ sender: UIButton) {
        self.delegate?.onTapCancelRest(self)
        self.deleteDelegate?.onTapCross(self)
    }
    
    @IBAction func onTapTwoLine(_ sender: UIButton) {
    }
    
    @IBAction func onTapSeconds(_ sender: UIButton) {
        self.deleteDelegate?.onTimeTap(self)
        self.onTimeTap?()
    }
}
