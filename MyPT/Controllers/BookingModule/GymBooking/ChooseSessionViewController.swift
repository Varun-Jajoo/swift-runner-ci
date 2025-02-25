//
//  ChooseSessionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/12/24.
//

import UIKit

class ChooseSessionViewController: CommonViewController {
        
    //MARK: -------------VARIABLE
    private let tooltipView: UIView = {
        let vv = UIView()
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1)
        label.textAlignment = .center
        label.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        label.text = "Save 0%"
        label.tag = 100
        label.layer.masksToBounds = true
        label.frame.size = CGSize(width: 90, height: 35)
        label.setCornerRadius(borderWidth: 2.0, borderColor: UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1), cornerRadious: 17.5)
        vv.frame = CGRect(x: 5, y: 5, width: label.frame.width, height: label.frame.height - 10)
        
        vv.addSubview(label)
        return vv
    }()

    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    var categoryData:[String]?
    
    let noteStrings = ["Increase session count for lower per session cost", "The validity of the package also determines the access period for the trainer"]
    var noteStringsCount:Int = -1
   
    //MARK: -----------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var sliderTopMBV: UIView!
    @IBOutlet weak var trainerProfileImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var sessionSliderMBV: UIView!
    @IBOutlet weak var perSessionCostLbl: UILabel!
    @IBOutlet weak var totalCostLbl: UILabel!
    @IBOutlet weak var totalCostAmtPicker: CustomPickerView!
    @IBOutlet weak var totalCostAmtPickerWidthConstrnt: NSLayoutConstraint!
    @IBOutlet weak var sessionToggleBtn: UIButton!
    @IBOutlet weak var costSlider: UISlider!
    @IBOutlet weak var startMonthLbl: UILabel!
    @IBOutlet weak var sessionCostLbl: UILabel!
    @IBOutlet weak var sessionNoteMBV: UIView!
    @IBOutlet weak var sessionNote: UILabel!
    @IBOutlet weak var consultExpertMBV: UIView!
    @IBOutlet weak var consultExpertBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryData = ["Cardio","Pilates","+3"]
        
        setupUI()
        setUpFont()
        setUpTotalCost()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sessionNoteMBV.animTopBottom(duration: 0.4, delay: 0.1) {
            print("animted done..")
        }
        scrollText(indx: 0)
    }
    
    //MARK: -------------------MAKE SCROLLABLE TEXT
    func scrollText(indx:Int){
        
        guard indx != self.noteStringsCount else { return }
        
        self.noteStringsCount = indx > 0 ? indx : 0
        
        self.sessionNote.animateTextScroll(strings: self.noteStrings, selectedIndex:  self.noteStringsCount, animationDuration: 0.4) {
            print("Text scrolling completed!")
        }
    }
   
    
    func setNavUI(){
        
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setUpTotalCost(){
        // Define items for the picker
        let items = ["50", "80", "100", "150", "200", "250", "300"]
        // Set the items for the picker
        totalCostAmtPicker.items = items
        costSlider.minimumValue = 0
        costSlider.maximumValue = Float(items.count - 1)
        // Initially center the picker at the first item
        totalCostAmtPicker.scrollToRow(0)
    }
    
    func updateContainerWidth() {
        let widestLabelWidth = totalCostAmtPicker.labelWidth
        print("Widest label width: \(widestLabelWidth)")
          totalCostAmtPickerWidthConstrnt?.constant = widestLabelWidth  // Adding padding (8 + 8)
          view.layoutIfNeeded() // Apply the constraint changes
      }
    
    //MARK: -----------SETUI
    func setupUI(){
        
        categoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.consultExpertBtn.titleLabel?.numberOfLines = 2
        
        DispatchQueue.main.async {
            
            self.sliderTopMBV.addSubview(self.tooltipView)
            self.updateTooltipPosition()
                        
            //--------Apply Gradient color
            self.costSlider.setSlider(gradientColors: [
                UIColor(red: 61.0/255.0, green: 215.0/255.0, blue: 114.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 171/255.0, blue: 152/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 114/255.0, blue: 211/255.0, alpha: 1.0).cgColor,
                UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1.0).cgColor
            ]
            )
                 
            //----------------Gradient view
            
//            self.sessionSliderMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
           
            self.sessionSliderMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.sessionSliderMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor, UIColor.mainBg.cgColor], type: .conic)
            
            self.sessionSliderMBV.setGradientBorder(cornerRadious:12,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            self.sessionNoteMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.consultExpertMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.consultExpertBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
        }
    }
    
    //MARK: ------------FONT SETUP
    //------------------************Font
    func setUpFont(){
        self.perSessionCostLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.trainerNameLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.perSessionCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.totalCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.startMonthLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.startMonthLbl.font = AppFont.regular.size(14.0, familyName: familyOverpass)
        self.consultExpertBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
//        self.sessionCostLbl.font = AppFont.semibold.size(44.0, familyName: familyClashDisplay)
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.semibold.size(25.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.semibold.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "",
            "400".strikeThrough(with: AppFont.medium.size(20.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray),
            NSAttributedString(string: "AED / Session",
                               attributes: makeAttributes),
        ] as [AttributedStringComponent]
        
        self.sessionCostLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    
    //MARK: -----------COST SLIDER ACTN
    
    @IBAction func costSliderActn(_ sender: UISlider) {
        let row = Int(sender.value)
        totalCostAmtPicker.scrollToRow(row, animated: true)

        self.updateContainerWidth()
        
        //---------------------*************
        // Update tooltip text
        let percentage = Int(sender.value / sender.maximumValue * 100)
        //        tooltipLabel.text = "Save \(percentage)%"
        
        if let label = tooltipView.viewWithTag(100) as? UILabel {
            label.text = "Save \(percentage)%"
        }
        
        if percentage > 60 {
            self.startMonthLbl.text = "12 month"
            self.startMonthLbl.textAlignment = .right
            self.startScrolling()
            
            if 1 <= noteStrings.count {
                scrollText(indx: 1)
            }
            
        }else{
            self.startMonthLbl.text = "3 month"
            self.startMonthLbl.textAlignment = .left
            self.startScrolling()
            
            if 1 <= noteStrings.count {
                scrollText(indx: 0)
            }
        }
        
        updateTooltipPosition()
    }
    
    //MARK: --------------ANIMATED MONTH LABEL
    func startScrolling() {
         let totalHeight = startMonthLbl.frame.height
        let visibleHeight = 10.0
        self.startMonthLbl.alpha = 0
        
         // Calculate the time it takes to scroll through the entire text
         let duration = Double(totalHeight + visibleHeight) / 30.0 // Adjust speed (30 points per second)

         UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
             self.startMonthLbl.alpha = 1.0
         }, completion: nil)
     }
    
    //MARK: -----------ENUM  BTN TAG
    enum btnTag:Int {
        case edit = 301, sessionToggle, consultExpert, continueBtn
    }
    
    //MARK: -----------EDIT BTN ACTN
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("common btn clicked....")
        
        switch sender.tag {
        case btnTag.edit.rawValue:
            print("edit btn clicked.")
        case btnTag.sessionToggle.rawValue:
            print("sessionToggle btn clicked.")
        case btnTag.consultExpert.rawValue:
            print("consultExpert btn clicked.")
        case btnTag.continueBtn.rawValue:
            print("continueBtn btn clicked.")
            let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
            vc.slotBookFlow = .createPackage
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("non...........")
        }
        
    }
    
    //MARK: -----------SESSION SELECTION BTN ACTN
    private func updateTooltipPosition() {
        
        self.costSlider.maximumTrackTintColor = UIColor.appWhite
        let thumbRect = self.costSlider.thumbRect(forBounds: self.costSlider.bounds, trackRect: self.costSlider.trackRect(forBounds: self.costSlider.bounds), value: self.costSlider.value)
        let thumbX = thumbRect.origin.x + thumbRect.width / 2
        
        // Update tooltip position
        tooltipView.center = CGPoint(x: thumbX , y: self.costSlider.frame.origin.y - (self.costSlider.frame.height + 62))
        
        drawTringle()

        //        tooltipView.center = CGPoint(x: thumbX + self.costSlider.frame.origin.x, y: self.costSlider.frame.origin.y - (self.costSlider.frame.height + 70))
        //sliderTopMBV
            
    }
    
    
    func drawTringle(){
        
        let tooltipHeight = tooltipView.frame.size.height + 13
        let triangleHeight: CGFloat = 7
        
        let heightWidth = tooltipView.frame.size.width
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: heightWidth/2 - 7, y: tooltipHeight))
        path.addLine(to: CGPoint(x:heightWidth/2, y: tooltipHeight + triangleHeight))
        path.addLine(to: CGPoint(x:heightWidth-(heightWidth/2 - 7), y:tooltipHeight))
        path.closeSubpath()
                
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1).cgColor
        
        tooltipView.layer.insertSublayer(shape, at: 0)
    }
    
}


extension ChooseSessionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        cell.titleLbl.text = categoryData?[indexPath.row] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        return !restrictedRange.contains { $0.contains(indexPath.item) }
    }
}


