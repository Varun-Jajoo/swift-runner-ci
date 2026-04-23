//
//  WithoutGymBestPlanCVCell.swift
//  MyPT
//
//  Created by Manik Goel on 21/02/26.
//

import UIKit

class WithoutGymBestPlanCVCell: UICollectionViewCell, UITableViewDelegate,UITableViewDataSource{
    
    private var features: [String] = []
    
    @IBOutlet weak var viewBckGRnd: UIView!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblStar: UILabel!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblAED: UILabel!
    @IBOutlet weak var viewSaveAED: UIView!
    @IBOutlet weak var lblSaveAED: UILabel!
    @IBOutlet weak var tableviewTag: UITableView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
        tableviewTag.delegate = self
        tableviewTag.dataSource = self
        tableviewTag.register(UINib(nibName: "BestPlanPointsTVCell", bundle: nil),
                                         forCellReuseIdentifier: "BestPlanPointsTVCell")
        }

        private func uiSetup() {
            self.lblStar.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.lblDays.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            // font family dalni hai
            self.lblAED.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
//            self.lblRupees.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
//            self.lblValidDays.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.lblSaveAED.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//            self.lblPriorities.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
//            self.lblEarlySessions.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.viewSaveAED.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 56/255, green: 118/255, blue: 45/255, alpha: 1), cornerRadious: 8)
            viewBckGRnd.applyCornerRadius(12)
//            self.viewCircle.transform = CGAffineTransform(rotationAngle: .pi / 4)

        }
    
    func configure(with model: BestPlanData) {
        lblStar.text = model.title ?? ""
        lblDays.text = model.validityText

        lblAED.text = (model.currency ?? "") + " " + (model.price ?? "")
//        lblRupees.text = (model.currency ?? "") + " " + (model.pricePerSession ?? "") + "/session"
//        lblValidDays.text = model.validityText
        lblSaveAED.text = model.badgeText
        viewSaveAED.isHidden = model.badgeText == nil
//        if let features = model.features {
//            lblPriorities.text = features.joined(separator: ", ")
//        } else {
//            lblPriorities.text = ""
//        }

        if let bgImage = model.backgroundImage {
            imgCard.loadImage(urlString: bgImage, placeholder: nil)
        }
        
        //  SET FEATURES
              self.features = model.features ?? []
              tableviewTag.reloadData()
    }
    

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return features.count
        }

        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BestPlanPointsTVCell",
                for: indexPath
            ) as! BestPlanPointsTVCell

            cell.lblPriorities.text = features[indexPath.row]
            return cell
        }
    }



