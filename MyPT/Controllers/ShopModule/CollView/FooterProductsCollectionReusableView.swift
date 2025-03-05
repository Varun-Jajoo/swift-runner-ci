//
//  FooterProductsCollectionReusableView.swift
//  MyPT
//
//  Created by techsaga corp on 25/02/25.
//

import UIKit

class FooterProductsCollectionReusableView: UICollectionReusableView {
    static let identifier = "CustomFooterView"
    
    private let footerMBV: UIView = {
        let bckMBV = UIView()
        bckMBV.backgroundColor = UIColor.cyan
        return bckMBV
    }()
    
     let addsImgView: UIImageView = {
        let addsImg = UIImageView()
//        addsImg.image = UIImage(named: "ic_productsAdds")
        addsImg.contentMode = .scaleToFill
        return addsImg
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(footerMBV)
        footerMBV.addSubview(addsImgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        footerMBV.translatesAutoresizingMaskIntoConstraints = false
        addsImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            footerMBV.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            footerMBV.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            footerMBV.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            footerMBV.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            addsImgView.topAnchor.constraint(equalTo: footerMBV.topAnchor, constant: 0),
            addsImgView.bottomAnchor.constraint(equalTo: footerMBV.bottomAnchor, constant: 0),
            addsImgView.leadingAnchor.constraint(equalTo: footerMBV.leadingAnchor, constant: 0),
            addsImgView.trailingAnchor.constraint(equalTo: footerMBV.trailingAnchor, constant: 0)
        ])
        
        self.setupUI()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.footerMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.addsImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
}
