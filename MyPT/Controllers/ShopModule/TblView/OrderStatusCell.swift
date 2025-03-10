//
//  OrderStatusCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/03/25.
//

import UIKit

class OrderStatusCell: UITableViewCell {
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        label.textColor = UIColor.txtDarkGray
        return label
    }()
    
    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let dashedLineLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.txtDarkGray.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [4, 4] // 4-point dash, 4-point gap
        shapeLayer.fillColor = nil
        return shapeLayer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(statusIcon)
        contentView.addSubview(statusLabel)
        contentView.layer.addSublayer(dashedLineLayer)
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 10),
            statusLabel.centerYAnchor.constraint(equalTo: statusIcon.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded() // Ensures proper layout before drawing
        
        drawDashedLine()
    }
    
    private func drawDashedLine() {
        dashedLineLayer.frame = contentView.bounds
        dashedLineLayer.path = nil // Clear previous path
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: statusIcon.center.x, y: statusIcon.frame.maxY)
        let endPoint = CGPoint(x: statusIcon.center.x, y: contentView.bounds.height)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        dashedLineLayer.path = path.cgPath
    }
    
    func configure(with status: String, isActive: Bool, isLast: Bool) {
        statusLabel.text = status
        statusLabel.textColor = isActive ? UIColor.appWhite : UIColor.txtDarkGray
        statusIcon.image = isActive ? AppImages.filterChecked : AppImages.filterUncheck
        statusIcon.tintColor = isActive ? .white : .lightGray
        dashedLineLayer.isHidden = isLast
    }
}

