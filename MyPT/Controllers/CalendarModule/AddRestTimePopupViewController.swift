//
//  AddRestTimePopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 28/08/25.
//

import UIKit

class AddRestTimePopupViewController: UIViewController {
    
    //MARK: --------------VARIABLE
    var senBacktTime: ((_ timeStr: String?, _ IsDismiss: Bool?) -> Void)?
    var selectedTime: String? = nil
    var currentSelectedTime: String? = nil
    
    
    let restTimePckr = RestTimePickerView()
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var timeScaleContainerMBV: UIView!
    @IBOutlet weak var timeShowMBV: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.setTimeSelect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func topBarBtnActn(_ sender: Any) {
        print("Top bar btn clicked......")
    }
    
    @IBAction func confirmBtnActn(_ sender: Any) {
        print("Confirm btn clicked.....")
        self.dismiss(animated: true, completion: {[weak self] in
            self?.senBacktTime?(self?.currentSelectedTime, false)
        })
    }
    
    private func setTimeSelect(){
        restTimePckr.translatesAutoresizingMaskIntoConstraints = false
        timeShowMBV.addSubview(restTimePckr)
              
              NSLayoutConstraint.activate([
                restTimePckr.topAnchor.constraint(equalTo: timeShowMBV.topAnchor),
                restTimePckr.bottomAnchor.constraint(equalTo: timeShowMBV.bottomAnchor),
                restTimePckr.leadingAnchor.constraint(equalTo: timeShowMBV.leadingAnchor),
                restTimePckr.trailingAnchor.constraint(equalTo: timeShowMBV.trailingAnchor),
              ])
        
        restTimePckr.isShowScale = true
        restTimePckr.isShowTopIndicator = true
        
        restTimePckr.selectedValue = {[weak self] value in
            guard self != nil else {
                return
            }
            self?.currentSelectedTime = "\(value)"
            print("Selected Rest Time: \(value) seconds")
        }
        
        
        //-----------------------********************SETUP REPS
        if let restTime = self.selectedTime,
           var getRestTimeVal = Int(restTime),
           let collectionView = self.restTimePckr.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            getRestTimeVal -= 1 //bcz of satrt from 0
            
            self.currentSelectedTime = self.selectedTime
            
            DispatchQueue.main.async {
                let itemCount = collectionView.numberOfItems(inSection: 0)
                if getRestTimeVal >= 0 && getRestTimeVal < itemCount {
                    let indexPath = IndexPath(item: getRestTimeVal, section: 0)
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }

    }
    
//    private func setTimerUI(){
//        restTimePicker.translatesAutoresizingMaskIntoConstraints = false
//        restTimeScaleMBV.addSubview(restTimePicker)
//              
//              NSLayoutConstraint.activate([
//                  restTimePicker.topAnchor.constraint(equalTo: restTimeScaleMBV.topAnchor),
//                  restTimePicker.bottomAnchor.constraint(equalTo: restTimeScaleMBV.bottomAnchor),
//                  restTimePicker.leadingAnchor.constraint(equalTo: restTimeScaleMBV.leadingAnchor),
//                  restTimePicker.trailingAnchor.constraint(equalTo: restTimeScaleMBV.trailingAnchor),
//              ])
//              
//              restTimePicker.selectedValue = { value in
//                  print("Selected Rest Time: \(value) seconds")
//              }
//
//    }
    
    
    private func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.confirmBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.confirmBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            //------------
            self.timeScaleContainerMBV.addGradient(colors: [ UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1.0) , UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.2)], locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            
            /*
             addGradient(colors: [ UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1.0) , UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.2)], locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 16.0)
             */
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.popupMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: {[weak self] in
                    guard self != nil else {
                        return
                    }
                    if let selectedTime = self?.selectedTime {
                        self?.senBacktTime?(selectedTime, false)
                    }else{
                        self?.senBacktTime?(nil, true)
                    }
                })
            }else{
                print("tap at popup view.")
            }
        }
    }
}
