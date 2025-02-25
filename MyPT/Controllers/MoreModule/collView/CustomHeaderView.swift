//
//  CustomHeaderView.swift
//  MyPT
//
//  Created by techsaga corp on 19/11/24.
//

import UIKit

class CustomHeaderView: UICollectionReusableView {
    static let identifier = "CustomHeaderView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Header"
        label.textColor = UIColor.txtDarkGray
        label.textAlignment = .left
        label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        label.frame = bounds
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
//            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 30),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
        
    }
    
    func configure(text: String) {
        
        label.text = text
    }
}


