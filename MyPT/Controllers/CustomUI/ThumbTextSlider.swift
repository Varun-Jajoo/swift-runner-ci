//
//  ThumbTextSlider.swift
//  MyPT
//
//  Created by techsaga corp on 13/01/25.
//

import UIKit

/* uses
 func setupCustomSlider(){
     self.customThumbSlider.leftThumbImamge = nil
     self.customThumbSlider.thumbBgColor = UIColor.appYellow
     self.customThumbSlider.borderSetup = (UIColor.appWhite, 2.5, 12.0)
     self.customThumbSlider.thumbTextLabel.textColor = UIColor.appWhite
     self.customThumbSlider.thumbTextLabel.font = AppFont.semibold.size(14.0, familyName: familyManrope)
     self.customThumbSlider.setMinimumValue = 1.0
     self.customThumbSlider.setMaximumValue = 5000
     self.customThumbSlider.setMinvalue = "\u{007E} 1"
     self.customThumbSlider.addTarget(self, action: #selector(sliderValueChanged(slider: )), for: .valueChanged)
 }
 
 //MARK: ------------------Slider action
 @objc func sliderValueChanged(slider:UISlider){
     print("slider is called..", slider.value)
     self.customThumbSlider.thumbTextLabel.text = "\u{007E}" + "\(Int(slider.value))"
     self.customThumbSlider.value = slider.value
 }

 */

class ThumbTextSlider: UISlider {
   
    private var needsThumbImageUpdate = true // Flag to track updates
    
   var setMinimumValue:Float = 0.0 {
       didSet {
           self.minimumValue = setMinimumValue
       }
   }
   
   var setMaximumValue:Float = 100.0 {
       didSet {
           self.maximumValue = setMaximumValue
       }
   }
   
   var leftThumbImamge:UIImage? = nil {
       didSet{
           if let image = leftThumbImamge {
               self.leftImageView.image = image
           }
       }
   }
   
   var borderSetup:(color: UIColor, width:CGFloat, thumbCorner:CGFloat )  = (UIColor.black , 1.0, 12.0) {
       didSet{
           thumbView.layer.borderColor = borderSetup.color.cgColor
           thumbView.layer.borderWidth = borderSetup.width
           thumbView.layer.cornerRadius = borderSetup.thumbCorner
           thumbView.layer.masksToBounds = true
       }
   }
   
   var thumbBgColor:UIColor = UIColor.red {
       didSet{
           thumbView.backgroundColor = thumbBgColor
           needsThumbImageUpdate = true
       }
   }
    
    var setMinvalue:String = "" {
        didSet{
            self.thumbTextLabel.text = setMinvalue
        }
    }
    
    override var value: Float {
        didSet {
            needsThumbImageUpdate = true
            setValue() // Ensure the text and image are updated
        }
    }
   
   var thumbTextLabel: UILabel = UILabel()
   
   private var thumbFrame: CGRect {
       return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
   }
   
   private lazy var thumbView: UIView = {
       let thumb = UIView()
       return thumb
   }()
   
   
   private var leftImageView: UIImageView = {
       let imageView = UIImageView()
       imageView.contentMode = .scaleAspectFit
       return imageView
   }()
   

   override func layoutSubviews() {
       super.layoutSubviews()
       self.updateUI()
   }
    
    private func updateUI(){
        // Position the left image view
        if leftImageView.image == nil {
            thumbTextLabel.backgroundColor = .clear
            thumbTextLabel.textAlignment = .center
            leftImageView.frame = CGRect(x: thumbFrame.origin.x, y: thumbFrame.origin.y, width: 1, height: thumbFrame.size.height)
        }else{
            leftImageView.frame = CGRect(x: thumbFrame.origin.x+5, y: thumbFrame.origin.y, width: 20, height: thumbFrame.size.height)
        }
        
        thumbTextLabel.frame = CGRect(x: (leftImageView.frame.origin.x+leftImageView.frame.size.width) + 2, y: thumbFrame.origin.y, width: thumbFrame.size.width - (leftImageView.frame.size.width+5), height: thumbFrame.size.height)
        
        if needsThumbImageUpdate {
              setValue() // Update only if necessary
          }
    }
   
   private func setValue() {
       
       if let text = thumbTextLabel.text, let font = thumbTextLabel.font {
           let textWidth = calculateExactTextWidth(text: text, font: font)
           print("Exact text width: \(textWidth)")
           
           DispatchQueue.main.async {
               let thumb = self.thumbImage(gWidth: textWidth + 35)
               
               self.setThumbImage(thumb, for: .normal)
               self.needsThumbImageUpdate = false // Reset the flag after updating
           }
       }
   }
   
   override func awakeFromNib() {
       super.awakeFromNib()
       self.setUI()
   }
    
    private func setUI(){
        self.thumbBgColor = UIColor.cyan
        self.borderSetup = (UIColor.white, 1.0, 12.0)
        self.minimumValue = setMinimumValue
        self.maximumValue = setMaximumValue
        leftImageView.image = nil
        addSubview(leftImageView)
        
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .left
        thumbTextLabel.textColor = .blue
        thumbTextLabel.adjustsFontSizeToFitWidth = true
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }
   
    
   private func thumbImage(gWidth:CGFloat) -> UIImage {
       thumbView.frame = CGRect(x: 0, y: 15, width: gWidth, height: 30)
       let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
       return renderer.image { rendererContext in
           rendererContext.cgContext.setShadow(offset: .zero, blur: 5, color: UIColor.clear.cgColor)
           thumbView.layer.render(in: rendererContext.cgContext)
       }
   }
    
    // MARK: - Improve Touch Responsiveness
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: self.trackRect(forBounds: bounds), value: value)
        let expandedRect = thumbRect.insetBy(dx: -20, dy: -20)
        return expandedRect.contains(point) || super.point(inside: point, with: event)
    }
       
   override func trackRect(forBounds bounds: CGRect) -> CGRect {
       return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5))
   }
   
   // Function to calculate the width of the text
   func calculateExactTextWidth(text: String, font: UIFont, constrainedHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
       let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: constrainedHeight)
       let boundingBox = text.boundingRect(
           with: constraintSize,
           options: .usesLineFragmentOrigin,
           attributes: [.font: font],
           context: nil
       )
       return ceil(boundingBox.width) // Round up to ensure the text fits
   }
   
}


// class ThumbTextSlider: UISlider {
//    
//     private var needsThumbImageUpdate = true // Flag to track updates
//     
//    var setMinimumValue:Float = 0.0 {
//        didSet {
//            self.minimumValue = setMinimumValue
//        }
//    }
//    
//    var setMaximumValue:Float = 100.0 {
//        didSet {
//            self.maximumValue = setMaximumValue
//        }
//    }
//    
//    var leftThumbImamge:UIImage? = nil {
//        didSet{
//            if let image = leftThumbImamge {
//                self.leftImageView.image = image
//            }
//        }
//    }
//    
//    var borderSetup:(color: UIColor, width:CGFloat, thumbCorner:CGFloat )  = (UIColor.black , 1.0, 12.0) {
//        didSet{
//            thumbView.layer.borderColor = borderSetup.color.cgColor
//            thumbView.layer.borderWidth = borderSetup.width
//            thumbView.layer.cornerRadius = borderSetup.thumbCorner
//            thumbView.layer.masksToBounds = true
//        }
//    }
//    
//    var thumbBgColor:UIColor = UIColor.red {
//        didSet{
//            thumbView.backgroundColor = thumbBgColor
//            needsThumbImageUpdate = true
//        }
//    }
//     
//     var setMinvalue:String = "" {
//         didSet{
//             self.thumbTextLabel.text = setMinvalue
//         }
//     }
//     
//     override var value: Float {
//         didSet {
//             needsThumbImageUpdate = true
//             setValue() // Ensure the text and image are updated
//         }
//     }
//    
//    var thumbTextLabel: UILabel = UILabel()
//    
//    private var thumbFrame: CGRect {
//        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
//    }
//    
//    private lazy var thumbView: UIView = {
//        let thumb = UIView()
//        return thumb
//    }()
//    
//    
//    private var leftImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//    
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Position the left image view
//        if leftImageView.image == nil {
//            thumbTextLabel.backgroundColor = .clear
//            thumbTextLabel.textAlignment = .center
//            leftImageView.frame = CGRect(x: thumbFrame.origin.x, y: thumbFrame.origin.y, width: 1, height: thumbFrame.size.height)
//        }else{
//            leftImageView.frame = CGRect(x: thumbFrame.origin.x+5, y: thumbFrame.origin.y, width: 20, height: thumbFrame.size.height)
//        }
//        
//        thumbTextLabel.frame = CGRect(x: (leftImageView.frame.origin.x+leftImageView.frame.size.width) + 2, y: thumbFrame.origin.y, width: thumbFrame.size.width - (leftImageView.frame.size.width+5), height: thumbFrame.size.height)
//        
////        leftImageView.frame = CGRect(x: thumbFrame.origin.x+5, y: thumbFrame.origin.y, width: 20, height: thumbFrame.size.height)
//        
////        thumbTextLabel.frame = CGRect(x: (leftImageView.frame.origin.x+leftImageView.frame.size.width) + 2, y: thumbFrame.origin.y, width: thumbFrame.size.width + 20, height: thumbFrame.size.height)
//        
////        thumbTextLabel.frame = CGRect(x: thumbFrame.origin.x, y: thumbFrame.origin.y, width: thumbFrame.size.width, height: thumbFrame.size.height)
//        
////        self.setValue()
//        
//        if needsThumbImageUpdate {
//              setValue() // Update only if necessary
//          }
//    }
//    
//    private func setValue() {
////        thumbTextLabel.text = self.value.description
////        thumbTextLabel.text = "\u{007E}" + "\(Int(self.value))"
//                
//        if let text = thumbTextLabel.text, let font = thumbTextLabel.font {
//            let textWidth = calculateExactTextWidth(text: text, font: font)
//            print("Exact text width: \(textWidth)")
//            
//            DispatchQueue.main.async {
//                let thumb = self.thumbImage(gWidth: textWidth + 35)
//                
//                self.setThumbImage(thumb, for: .normal)
//                self.needsThumbImageUpdate = false // Reset the flag after updating
//            }
//        }
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        self.thumbBgColor = UIColor.cyan
//        self.borderSetup = (UIColor.white, 1.0, 12.0)
//        self.minimumValue = setMinimumValue
//        self.maximumValue = setMaximumValue
//        // Configure the left image view
////        leftImageView.image = UIImage(named: "ic_workoutRangeThumb")
//        leftImageView.image = nil
//        addSubview(leftImageView)
//        
//        addSubview(thumbTextLabel)
//        thumbTextLabel.textAlignment = .left
//        thumbTextLabel.textColor = .blue
//        thumbTextLabel.adjustsFontSizeToFitWidth = true
//        thumbTextLabel.layer.zPosition = layer.zPosition + 1
//        
////        self.setValue()
//    }
//    
//    
//    private func thumbImage(gWidth:CGFloat) -> UIImage {
//        thumbView.frame = CGRect(x: 0, y: 15, width: gWidth, height: 30)
////        thumbView.layer.cornerRadius = 12
//        
//        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
//        return renderer.image { rendererContext in
//            rendererContext.cgContext.setShadow(offset: .zero, blur: 5, color: UIColor.clear.cgColor)
////            thumbView.backgroundColor = .cyan
//            thumbView.layer.render(in: rendererContext.cgContext)
//        }
//    }
//        
//    override func trackRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5))
//    }
//    
//    // Function to calculate the width of the text
//    
//    func calculateExactTextWidth(text: String, font: UIFont, constrainedHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
//        let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: constrainedHeight)
//        let boundingBox = text.boundingRect(
//            with: constraintSize,
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        )
//        return ceil(boundingBox.width) // Round up to ensure the text fits
//    }
//    
//}



/*
class ThumbTextSlider: UISlider {
    
    open weak var delegate: ThumbTextSliderDelegate?
    
    var setMinimumValue: Float = 0.0 {
        didSet {
            self.minimumValue = setMinimumValue
        }
    }
    
    var setMaximumValue: Float = 100.0 {
        didSet {
            self.maximumValue = setMaximumValue
        }
    }
    
    var leftThumbImamge: UIImage? = nil {
        didSet {
            if let image = leftThumbImamge {
                self.leftImageView.image = image
            }
        }
    }
    
    var borderSetup: (color: UIColor, width: CGFloat, thumbCorner: CGFloat) = (UIColor.black, 1.0, 12.0) {
        didSet {
            thumbView.layer.borderColor = borderSetup.color.cgColor
            thumbView.layer.borderWidth = borderSetup.width
            thumbView.layer.cornerRadius = borderSetup.thumbCorner
            thumbView.layer.masksToBounds = true
        }
    }
    
    var thumbBgColor: UIColor = UIColor.red {
        didSet {
            thumbView.backgroundColor = thumbBgColor
        }
    }
    
    var thumbTextLabel: UILabel = UILabel()
    
    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        return thumb
    }()
    
    private var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var previousValue: Float = -1.0
    
    // Override the set value to track changes
    override var value: Float {
        didSet {
            // Check if the value has actually changed to avoid continuous updates
            if value != previousValue {
                previousValue = value
                setValue()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position the left image view
        if leftImageView.image == nil {
            thumbTextLabel.backgroundColor = .clear
            thumbTextLabel.textAlignment = .center
            leftImageView.frame = CGRect(x: thumbFrame.origin.x, y: thumbFrame.origin.y, width: 1, height: thumbFrame.size.height)
        } else {
            leftImageView.frame = CGRect(x: thumbFrame.origin.x + 5, y: thumbFrame.origin.y, width: 20, height: thumbFrame.size.height)
        }
        
        thumbTextLabel.frame = CGRect(x: (leftImageView.frame.origin.x + leftImageView.frame.size.width) + 2, y: thumbFrame.origin.y, width: thumbFrame.size.width - (leftImageView.frame.size.width + 5), height: thumbFrame.size.height)
    }
    
    private func setValue() {
        // Set the thumb text label with the slider value
        thumbTextLabel.text = "\u{007E}" + "\(Int(self.value))"
        
        // Inform the delegate about the change in value
        delegate?.valueSlider(self, didChange: self.value, maxValue: self.maximumValue)
        
        if let text = thumbTextLabel.text, let font = thumbTextLabel.font {
            let textWidth = calculateExactTextWidth(text: text, font: font)
            print("Exact text width: \(textWidth)")
            
            DispatchQueue.main.async {
                let thumb = self.thumbImage(gWidth: textWidth + 35)
                self.setThumbImage(thumb, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.thumbBgColor = UIColor.cyan
        self.borderSetup = (UIColor.white, 1.0, 12.0)
        self.minimumValue = setMinimumValue
        self.maximumValue = setMaximumValue
        
        addSubview(leftImageView)
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .left
        thumbTextLabel.textColor = .blue
        thumbTextLabel.adjustsFontSizeToFitWidth = true
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
    }
    
    private func thumbImage(gWidth: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: 15, width: gWidth, height: 30)
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            rendererContext.cgContext.setShadow(offset: .zero, blur: 5, color: UIColor.clear.cgColor)
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5))
    }
    
    func calculateExactTextWidth(text: String, font: UIFont, constrainedHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: constrainedHeight)
        let boundingBox = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.width)
    }
}
*/



//------------------------------********************

/*
class ThumbTextSlider: UISlider {
    private var thumbTextLabel: UILabel = UILabel()
    
    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        return thumb
    }()
    
    
    private var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position the left image view
        leftImageView.frame = CGRect(x: thumbFrame.origin.x+5, y: thumbFrame.origin.y, width: 20, height: thumbFrame.size.height)
        
        thumbTextLabel.frame = CGRect(x: (leftImageView.frame.origin.x+leftImageView.frame.size.width) + 2, y: thumbFrame.origin.y, width: thumbFrame.size.width + 20, height: thumbFrame.size.height)
        
//        thumbTextLabel.frame = CGRect(x: thumbFrame.origin.x, y: thumbFrame.origin.y, width: thumbFrame.size.width, height: thumbFrame.size.height)
        self.setValue()
    }
    

    
    private func setValue() {
//        thumbTextLabel.text = self.value.description
        self.minimumValue = 1.0
        self.maximumValue = 50.0
        thumbTextLabel.text = "\(Int(self.value))"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the left image view
        leftImageView.image = UIImage(named: "ic_workoutRangeThumb")
        addSubview(leftImageView)
        
        addSubview(thumbTextLabel)
        thumbTextLabel.textAlignment = .left
        thumbTextLabel.textColor = .blue
        thumbTextLabel.adjustsFontSizeToFitWidth = true
        thumbTextLabel.layer.zPosition = layer.zPosition + 1
        
        let thumb = thumbImage()
        
        setThumbImage(thumb, for: .normal)
    }
    
    private func thumbImage() -> UIImage {
        let width = 60
        thumbView.frame = CGRect(x: 0, y: 15, width: width, height: 40)
        thumbView.layer.cornerRadius = 12
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            rendererContext.cgContext.setShadow(offset: .zero, blur: 5, color: UIColor.clear.cgColor)
            thumbView.backgroundColor = .cyan
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5))
    }
}
*/


