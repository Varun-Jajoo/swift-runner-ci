//
//  MoreExploreCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 19/11/24.
//

import UIKit

class MoreExploreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var imgBgCover: UIView!
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
    }

    
    /*
    private let separatorLine: UIView = {
           let view = UIView()
           view.backgroundColor = .lightGray // Set the desired color of the line
           return view
       }()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           contentView.addSubview(separatorLine)
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           contentView.addSubview(separatorLine)
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           
           // Position the separator line at the bottom
           let lineHeight: CGFloat = 1.0 // Adjust thickness as needed
           separatorLine.frame = CGRect(
               x: 0,
               y: contentView.bounds.height - lineHeight,
               width: contentView.bounds.width,
               height: lineHeight
           )
       }
    
  */
    
    /*
     Visibility: If you want the line to be conditional (e.g., not shown for the last cell), you can implement logic in cellForItemAt to hide or show the line based on the cell's position.
     separatorLine.isHidden = indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1
     */

}
