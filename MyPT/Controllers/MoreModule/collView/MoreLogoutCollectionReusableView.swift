//
//  MoreLogoutCollectionReusableView.swift
//  MyPT
//
//  Created by techsaga corp on 05/05/25.
//

import UIKit

//class MoreLogoutCollectionReusableView: UICollectionReusableView {
//   
//    static let reuseIdentifier = "MoreLogoutCollectionReusableView"
//    
//    let button: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("  Logout", for: .normal)
//        button.setImage(UIImage(named: "ic_logout"), for: .normal)
////        button.setTitle("  " + (titleStr.element ?? ""), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor.clear
//        button.setTitleColor(UIColor.appWhite, for: .normal)
//        button.layer.cornerRadius = 12
//        return button
//    }()
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            backgroundColor = UIColor.clear
//
//            addSubview(button)
//            button.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
//            
//            NSLayoutConstraint.activate([
////                button.centerXAnchor.constraint(equalTo: centerXAnchor),
//                button.centerYAnchor.constraint(equalTo: centerYAnchor),
////                button.widthAnchor.constraint(equalToConstant: 120),
//                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1.0),
//                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0),
//                button.heightAnchor.constraint(equalToConstant: 56)
//            ])
//        }
//
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//}


class MoreLogoutCollectionReusableView: UICollectionReusableView {

    static let reuseIdentifier = "MoreLogoutCollectionReusableView"

    private let deleteLbl: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1.0)
        label.font = AppFont.semibold.size(11.0, familyName: familyManrope)
        label.text = "To delete your data permanently,"
        return label
    }()

    let deleteAccBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = AppFont.semibold.size(11.0, familyName: familyManrope)
        
        //--------------------
         let fullText = "close your account"
         let attributedString = NSMutableAttributedString(string: fullText)

         // Example: underline and change color
         attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, fullText.count))
         attributedString.addAttribute(.foregroundColor, value: UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1.0), range: NSMakeRange(0, fullText.count))
         attributedString.addAttribute(.font, value: AppFont.semibold.size(11.0, familyName: familyManrope), range: NSMakeRange(0, fullText.count))
         button.setAttributedTitle(attributedString, for: .normal)
         
        return button
    }()

    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  Logout", for: .normal)
        button.setImage(UIImage(named: "ic_logout"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.appWhite, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        // Add subviews
        addSubview(deleteLbl)
        addSubview(deleteAccBtn)
        addSubview(button)

        // Apply corner radius and border
        button.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)

        // Constraints
        NSLayoutConstraint.activate([
            deleteLbl.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            deleteLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19),

            deleteAccBtn.centerYAnchor.constraint(equalTo: deleteLbl.centerYAnchor),
            deleteAccBtn.leadingAnchor.constraint(equalTo: deleteLbl.trailingAnchor, constant: 6),
            deleteAccBtn.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -19),

            button.topAnchor.constraint(equalTo: deleteLbl.bottomAnchor, constant: 25),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -19),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
