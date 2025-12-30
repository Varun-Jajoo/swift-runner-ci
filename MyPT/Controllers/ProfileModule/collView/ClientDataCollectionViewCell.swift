//
//  ClientDataCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 26/06/25.
//

import UIKit

class ClientDataCollectionViewCell: UICollectionViewCell {

    var timer: Timer?
    
    @IBOutlet weak var cellMainGrdImgView: UIImageView!
    @IBOutlet weak var cellMStckView: UIStackView!
    @IBOutlet weak var clientDataDescMBV: UIView!
    @IBOutlet weak var noDataMBV: UIView!
    @IBOutlet weak var noDataSubV: UIView!
    @IBOutlet weak var clientDataProgressMBV: UIView!
    @IBOutlet weak var subviewProgress: UIView!
    @IBOutlet weak var topTitleBtn: UIButton!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var doDataDescLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        self.setupUI()
    
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////            self.gaugeViewSet()
////            self.progressVSet(progressTitle: "DESIRABLE")
//        }
    }

    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMainGrdImgView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor(red: 46.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), cornerRadious: 18.0)
            self.cellMStckView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor(red: 46.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), cornerRadious: 18.0)
            
            self.noDataSubV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
//        self.unitLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        
        topTitleBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        unitLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        doDataDescLbl.font = AppFont.bold.size(11.0, familyName: familyManrope)
    }
    
    
 func progressVSet(progressValue: CGFloat? = 0.1, progressTitle: String?, progressTitleColor: UIColor? = UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0), progressColor: [CGColor]? = [
        UIColor(red: 63.0/255.0, green: 216.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 167.0/255.0, green: 224.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 250.0/255.0, green: 206.0/255.0, blue: 52.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0).cgColor
    ]){
        let container = GaugeContainerView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.clear
        subviewProgress.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: subviewProgress.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: subviewProgress.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: subviewProgress.bottomAnchor),
            container.heightAnchor.constraint(equalTo: subviewProgress.heightAnchor, multiplier: 1)
        ])
        
        container.progressStr = progressTitle 
        container.progressStrColor = progressTitleColor //UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        container.progressStrFont = AppFont.semibold.size(12.0, familyName: familyManrope)
        container.progersColor = progressColor ?? [UIColor(red: 229.0/255.0, green: 184.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor]
       
        if let progressValue = progressValue {
            container.setGaugeProgress(progressValue)
        }
    }
    
    /*v only make for test data
    private func gaugeViewSet(){
        
       /*
        let gauge = GaugeView()
        gauge.backgroundColor = UIColor.cyan
        gauge.translatesAutoresizingMaskIntoConstraints = false
        subviewProgress.addSubview(gauge)

        NSLayoutConstraint.activate([
            gauge.topAnchor.constraint(equalTo: subviewProgress.topAnchor, constant: 1),
            gauge.bottomAnchor.constraint(equalTo: subviewProgress.bottomAnchor, constant: 0),
            gauge.widthAnchor.constraint(equalTo: subviewProgress.widthAnchor, multiplier: 1.0),
            gauge.heightAnchor.constraint(equalTo: gauge.heightAnchor, multiplier: 0.9)
//            gauge.heightAnchor.constraint(equalTo: gauge.widthAnchor, multiplier: 1.0)
        ])

        gauge.progress = 1.0 // 60%
        */
     
        
        let container = GaugeContainerView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.clear
        subviewProgress.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: subviewProgress.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: subviewProgress.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: subviewProgress.bottomAnchor),
            container.heightAnchor.constraint(equalTo: subviewProgress.heightAnchor, multiplier: 1)
        ])
        
        container.progressStr = "DESIRABLE"
        container.progressStrColor = UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0) 
        container.progressStrFont = AppFont.semibold.size(12.0, familyName: familyManrope)
    
        var progressInPercents = 0.1
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
          
            if progressInPercents >= 1.0 {
                timer.invalidate()
                self.timer = nil
            }
            
            progressInPercents = progressInPercents + 0.2
            container.setGaugeProgress(progressInPercents)
        }
    }
    */
    
}
