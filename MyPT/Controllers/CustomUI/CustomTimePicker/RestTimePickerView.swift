//
//  RestTimePickerView.swift
//  MyPT
//
//  Created by techsaga corp on 28/08/25.
//

import UIKit

class RestTimePickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GetBackSelectedValueDelegate {
    
    private var collectionView: UICollectionView!
    var values: [Int] = Array(1...60) {
        didSet{
            collectionView.reloadData()
        }
    }
    
    
    var selectedValue: ((Int) -> Void)?
    var defaultValue: Int = 1
    var padding: CGFloat = 6
 
    private var didSetInitialValue = false
    var isShowTopIndicator:Bool = false {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var isShowScale:Bool = false {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var majorInterval: Int = 1
      var tickSpacing: CGFloat = 10
      var majorTickColor: UIColor = UIColor(red: 15/255, green: 20/255, blue: 17/255, alpha: 0.8)
      var minorTickColor: UIColor = .clear
      var lineWidth: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
//    override func draw(_ rect: CGRect) {
//           guard let context = UIGraphicsGetCurrentContext() else { return }
//           drawScale(in: rect, context: context)
//       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.removeAll(where: { $0 is CAShapeLayer }) // Prevent duplicates
        
        if isShowTopIndicator {
            addTopPointer()
        }
        
        if isShowScale {
            self.addScaleImg()
        }
 
        if !didSetInitialValue {
               didSetInitialValue = true
               DispatchQueue.main.async {
                   if let index = self.values.firstIndex(of: self.defaultValue) {
                       let indexPath = IndexPath(item: index, section: 0)
                       self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                   }
               }
           }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
       
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = .fast
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
        
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
    }
    
    private func addScaleImg(){
        // Create an image view
        let bottomImageView = UIImageView()
        bottomImageView.image = UIImage(named: "ic_rulerScale")
        bottomImageView.contentMode = .scaleAspectFill
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add imageView to main view
        self.addSubview(bottomImageView)
        
        // Add constraints
        NSLayoutConstraint.activate([
            bottomImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomImageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            bottomImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2) // half height
            //                 bottomImageView.heightAnchor.constraint(equalToConstant: 100) // adjust height as needed
        ])
    }
    
    // MARK: - Separate Function
//        private func drawScale(in rect: CGRect, context: CGContext) {
//            let totalTicks = Int(rect.width / tickSpacing)
//            
//            for i in 0...totalTicks {
//                let x = CGFloat(i) * tickSpacing
//                let isMajor = i % majorInterval == 0
//                
//                let tickLength: CGFloat = rect.height * 0.2
//                let tickColor = isMajor ? majorTickColor : minorTickColor
//                
//                context.setStrokeColor(tickColor.cgColor)
//                context.setLineWidth(lineWidth)
//                
//                let centerY = rect.height / 2
//                context.move(to: CGPoint(x: x, y: centerY - tickLength / 2))
//                context.addLine(to: CGPoint(x: x, y: centerY + tickLength / 2))
//                context.strokePath()
//            }
//        }
    
    private func addTopPointer() {
        let triangle = CAShapeLayer()
        let width: CGFloat = 22 //20
        let height: CGFloat = 15 //8
        let centerX = self.bounds.width / 2

        let path = UIBezierPath()
        // Tip pointing down, inside the view
        path.move(to: CGPoint(x: centerX, y: height))
        // Top-left corner
        path.addLine(to: CGPoint(x: centerX - width / 2, y: 0))
        // Top-right corner
        path.addLine(to: CGPoint(x: centerX + width / 2, y: 0))
        path.close()

        triangle.path = path.cgPath
        triangle.fillColor = UIColor(red: 61.0/255.0, green: 61.0/255.0, blue: 61.0/255.0, alpha: 1.0).cgColor 
        self.layer.addSublayer(triangle)
    }
     
 
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    }
    
    // Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as! NumberCell
        cell.delegate = self
        /*
        let centerX = collectionView.bounds.width / 2
        let cellCenter = collectionView.layoutAttributesForItem(at: indexPath)?.center.x ?? 0
        let offset = cellCenter - collectionView.contentOffset.x
        let isCentered = abs(centerX - offset) < 30 // ~tolerance
        */
        
        let centerX = collectionView.bounds.width / 2 + collectionView.contentOffset.x
       
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        guard let cellCenterX = attributes?.center.x else { return UICollectionViewCell() }
        let distance = abs(cellCenterX - centerX)

        // Adaptive threshold based on cell width
        let isCentered = distance < cell.bounds.width / 2
        
        cell.configure(value: values[indexPath.item], isSelected: isCentered)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 60, height: collectionView.frame.height)
        
        let value = "\(values[indexPath.item])"

           // Use the same font as NumberCell label
        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
           
           // Measure text width
           let textWidth = (value as NSString).size(withAttributes: [.font: font]).width
           
           return CGSize(width: textWidth + padding, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if values.isEmpty { return .zero }
        
        // Use average or first item’s width
        let sampleValue = "\(values.first!)"
        let font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let sampleWidth = (sampleValue as NSString).size(withAttributes: [.font: font]).width + padding
        
        let sideInset = (collectionView.bounds.width - sampleWidth) / 2
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
      /*
        let sideInset = (collectionView.bounds.width - 60) / 2  // 60 = item width
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        */
    }
    
 
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        collectionView.visibleCells.forEach { cell in
//            if let cell = cell as? NumberCell, let indexPath = collectionView.indexPath(for: cell) {
//                let centerX = collectionView.bounds.width / 2
//                let cellCenter = collectionView.layoutAttributesForItem(at: indexPath)?.center.x ?? 0
//                let offset = cellCenter - collectionView.contentOffset.x
////                let isCentered = abs(centerX - offset) < 30
//                let isCentered = abs(centerX - offset) < 15
//                cell.configure(value: values[indexPath.item], isSelected: isCentered)
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the center of the visible area in content coordinates
        let centerX = collectionView.bounds.width / 2 + collectionView.contentOffset.x

        collectionView.visibleCells.forEach { cell in
            guard let cell = cell as? NumberCell,
                  let indexPath = collectionView.indexPath(for: cell),
                  let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }

            let cellCenterX = attributes.center.x
            let distance = abs(cellCenterX - centerX)

            // Adaptive threshold based on cell width
            let isCentered = distance < cell.bounds.width / 2

            // Configure the cell with selection state
            cell.configure(value: values[indexPath.item], isSelected: isCentered)
        }
    }

    
    func getSelectedValue(value: String?) {
        if let value = value , let val = Int(value) {
            print("Selected value ", val)
            selectedValue?(val)
        }
    }
}
 
protocol GetBackSelectedValueDelegate: AnyObject {
    func getSelectedValue(value: String?)
}
 
class NumberCell: UICollectionViewCell {
    var delegate: GetBackSelectedValueDelegate?
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(value: Int, isSelected: Bool) {
        label.text = "\(value)"
        label.font = isSelected ? UIFont.boldSystemFont(ofSize: 28) : UIFont.systemFont(ofSize: 14)
        label.textColor = isSelected ? .white : .lightGray
        if let delegate = delegate {
            let valueStr = isSelected ? "\(value)" : ""
            delegate.getSelectedValue(value: valueStr)
        }
    }
}

