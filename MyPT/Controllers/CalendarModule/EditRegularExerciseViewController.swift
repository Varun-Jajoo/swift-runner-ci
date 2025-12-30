//
//  EditRegularExerciseViewController.swift
//  MyPT
//
//  Created by techsaga corp on 03/09/25.
//

import UIKit

class EditRegularExerciseViewController: CommonViewController {

    //MARK: ----------------- VARIABLE
    var createWorkoutFlow: CreateWorkoutFlow = .defaultWorkout
    var sentEditedData: ((_ setsCount: Int?, _ repsCount: Int?, _ restTime: String?, _ noteDesc: String?) -> Void)?
    
    private var setsCont: Int = 1{
        didSet{
            self.countSetsLbl.text = "\(setsCont)"
        }
    }
    
    private var repsCont: Int = 1{
        didSet{
            self.countRepsLbl.text = "\(repsCont)"
        }
    }
    let restTimePicker = RestTimePickerView()
    var workoutIdStr: String?
    var workoutExerciseId: String?
    var setsPositionStr: String?
    var exerciseName: String?
    var exerciseImgStr: String?
    var durationStr: String?
    var caloriesStr: String?
    var restTimeStr: String?
    var inputSetsCont: Int?
    var inputRepsCont: Int?
    
    
    //MARK: ------------------ IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var exerciseImgView: UIImageView!
    @IBOutlet weak var durationCaloriesMSTCK: UIStackView!
    @IBOutlet weak var circuitDurationMSTCK: UIStackView!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var circuitDurationMBV: UIView!
    @IBOutlet weak var circuitCaloriesMBV: UIView!
    @IBOutlet weak var durationGraghMBV: UIView!
    @IBOutlet weak var caloriesGraghMBV: UIView!
    @IBOutlet weak var setsMBV: UIView!
    @IBOutlet weak var setsSubMBV: UIView!
    @IBOutlet weak var restMBV: UIView!
    @IBOutlet weak var repsMBV: UIView!
    @IBOutlet weak var restScaleMBV: UIView!
    @IBOutlet weak var setsTitleMBV: UIView!
    @IBOutlet weak var notesMBV: UIView!
    @IBOutlet weak var saveMBV: UIView!
    @IBOutlet weak var timeDurationsLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var caloriesCountLbl: UILabel!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var scaleImgView: UIImageView!
    @IBOutlet weak var durationImgView: UIImageView!
    @IBOutlet weak var caloriesImgView: UIImageView!
    @IBOutlet weak var setsTitleLbl: UILabel!
    @IBOutlet weak var countSetsLbl: UILabel!
    @IBOutlet weak var restTimeLbl: UILabel!
    @IBOutlet weak var repsTitleLbl: UILabel!
    @IBOutlet weak var countRepsLbl: UILabel!
    @IBOutlet weak var notesTitleLbl: UILabel!
    @IBOutlet weak var notesDescTxtView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var setsIndexBtn: UIButton!
    @IBOutlet weak var setsIndexTitleLbl: UILabel!
    @IBOutlet weak var setsIndexExpandBtn: UIButton!
    @IBOutlet weak var circuitTimeDurationsLbl: UILabel!
    @IBOutlet weak var circuitDurationLbl: UILabel!
    @IBOutlet weak var circuitCaloriesCountLbl: UILabel!
    @IBOutlet weak var circuitCaloriesLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notesMBV.isHidden = true
        self.circuitDurationMSTCK.isHidden = true
        self.setupUI()
        self.setupFont()
        self.setTimerScaleUI()
        self.setInputData()
        self.setupFlow()
        self.gaugeProgressV()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
//        self.circuitDurationMSTCK.isHidden = true
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.edit_Exercise], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("notification", notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    private func setupFlow(){
        self.notesMBV.isHidden = true
        self.setsTitleMBV.isHidden = true
        self.setsMBV.isHidden = false
        self.restMBV.isHidden = false
        self.repsMBV.isHidden = false
        self.durationCaloriesMSTCK.isHidden = false
        self.circuitDurationMSTCK.isHidden = true
        
        //-------------**********
        switch createWorkoutFlow {
        case .regularCreateWorkout:
            self.repsTitleLbl.text = "Choose No of Reps"
            break
            
        case .superCreateWorkout:
            print("superCreateWorkout")
            self.notesMBV.isHidden = false
            self.setsTitleMBV.isHidden = true
            self.setsMBV.isHidden = false
            self.restMBV.isHidden = false
            self.repsMBV.isHidden = false
            
            break
            
        case .circuitCreateWorkout:
            self.setsTitleMBV.isHidden = false
            self.setsMBV.isHidden = true
            self.restMBV.isHidden = true
            self.durationCaloriesMSTCK.isHidden = true
            self.circuitDurationMSTCK.isHidden = false
            
            self.repsTitleLbl.text = "Number of reps for \(exerciseName ?? "")"
            
            break
        case .defaultWorkout:
            print("None of these..")
            break
        }
    }
    
    private func setInputData(){
        
        self.topTitleLbl.text = self.exerciseName
        
        if let inputSetsCont = inputSetsCont {
            self.setsCont = inputSetsCont
        }
        if let inputRepsCont = inputRepsCont {
            self.repsCont = inputRepsCont
        }
        
        //--------------Gradient label
        self.timeDurationsLbl.text = " "
        self.caloriesCountLbl.text = ""
        self.circuitTimeDurationsLbl.text = " "
        self.circuitCaloriesCountLbl.text = " "
        
        if let durationStr = durationStr {
            self.timeDurationsLbl.attributedText = gradientAttr(labl: self.timeDurationsLbl, txtStr: durationStr + "s")
        }else{
            self.timeDurationsLbl.attributedText = gradientAttr(labl: self.timeDurationsLbl, txtStr: "0s")
        }
        
        if let caloriesStr = caloriesStr {
            self.caloriesCountLbl.attributedText = gradientAttr(labl: self.caloriesCountLbl, txtStr: caloriesStr)
        }else{
            self.caloriesCountLbl.attributedText = gradientAttr(labl: self.caloriesCountLbl, txtStr: "0")
        }
        
        
        //------------*************
        if let durationStr = durationStr {
            self.circuitTimeDurationsLbl.attributedText = gradientAttr(labl: self.circuitTimeDurationsLbl, txtStr: durationStr)
        }
        if let caloriesStr = caloriesStr {
            self.circuitCaloriesCountLbl.attributedText = gradientAttr(labl: self.circuitCaloriesCountLbl, txtStr: caloriesStr)
        }
      
        self.exerciseImgView.loadImage(urlString: self.exerciseImgStr, placeholder: nil)
        
        //---------------------Rest time
        if let restTimeStr = restTimeStr,
           var getRepsCountVal = Int(restTimeStr),
           let collectionView = self.restTimePicker.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            
            let itemCount = collectionView.numberOfItems(inSection: 0)
            print("Item Count: ", itemCount)
            
            getRepsCountVal -= 1 //bcz of start form 0
            
            DispatchQueue.main.async {
                let itemCount = collectionView.numberOfItems(inSection: 0)
                if getRepsCountVal >= 0 && getRepsCountVal < itemCount {
                    let indexPath = IndexPath(item: getRepsCountVal, section: 0)
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
            
        }
                
    }
    
    enum EditExrBtnTag: Int {
    case setsMinus = 1101, setsAdd, repsMinus, repsAdd, saveEdit
    }
    
    @IBAction func editWorkoutBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case EditExrBtnTag.setsMinus.rawValue:
            print("setsMinus clicked.")
            guard setsCont > 1 else {
                return
            }
            setsCont -= 1
            
            break
            
        case EditExrBtnTag.setsAdd.rawValue:
            print("setsAdd clicked.")
            setsCont += 1
            break
            
        case EditExrBtnTag.repsMinus.rawValue:
            print("repsMinus clicked.")
            guard repsCont > 1 else {
                return
            }
            repsCont -= 1
            break
            
        case EditExrBtnTag.repsAdd.rawValue:
            print("repsAdd clicked.")
            repsCont += 1
            break
            
        case EditExrBtnTag.saveEdit.rawValue:
            print("saveEdit clicked.")

            if let _ = workoutIdStr {
                self.editExercise()
            }else{
                self.sentEditedData?(setsCont, repsCont, self.restTimeStr, notesDescTxtView.text)
                
                self.navigationController?.popViewController(animated: true)
            }
            
            //sentEditedData
            /*
             self.countSetsLbl.text
             self.countRepsLbl.text
             */
//            self.sentEditedData?(setsCont, repsCont, self.restTimeStr, notesDescTxtView.text)
//            self.navigationController?.popViewController(animated: true)
            
            break
            
        default:
            print("None of these....")
            break
        }
    }
    
    private func setTimerScaleUI(){
        restTimePicker.translatesAutoresizingMaskIntoConstraints = false
        restScaleMBV.addSubview(restTimePicker)
        restTimePicker.isShowTopIndicator = true
        restTimePicker.values = Array(1...60)
        
        NSLayoutConstraint.activate([
            restTimePicker.topAnchor.constraint(equalTo: restScaleMBV.topAnchor),
            restTimePicker.bottomAnchor.constraint(equalTo: restScaleMBV.bottomAnchor),
            restTimePicker.leadingAnchor.constraint(equalTo: restScaleMBV.leadingAnchor),
            restTimePicker.trailingAnchor.constraint(equalTo: restScaleMBV.trailingAnchor),
        ])
        
        restTimePicker.selectedValue = {[weak self] value in
            print("Selected Rest Time: \(value) seconds")
            self?.restTimeStr = "\(value)"
        }
    }
        
    private func setupFont(){
        topTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
//        durationLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
//        caloriesLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        
        countSetsLbl.font = AppFont.bold.size(50.0, familyName: familyManrope)
        countRepsLbl.font = AppFont.bold.size(50.0, familyName: familyManrope)
        
        [
            durationLbl,
            caloriesLbl,
            circuitDurationLbl,
            circuitCaloriesLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        })
        
        [
            setsTitleLbl,
            restTimeLbl,
            repsTitleLbl,
            notesTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        })
        
        notesDescTxtView.font = AppFont.bold.size(15.0, familyName: familyManrope)
        saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.setsIndexTitleLbl.font = AppFont.bold.size(20.0, familyName: familyManrope)
        
        self.notesDescTxtView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    
private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.medium.size(20.0, familyName: familyClashDisplay)) -> NSAttributedString {
    let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
    
    return attStr
}
    
    private func gaugeProgressV(){

        let outerProgerssGradient: [CGColor] = [
            UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0).cgColor
        ]
        
        let container = GaugeContainerView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.clear
        durationGraghMBV.addSubview(container)
        container.gaugeThickness = 20.0
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: durationGraghMBV.leadingAnchor, constant: -30),
            container.trailingAnchor.constraint(equalTo: durationGraghMBV.trailingAnchor, constant: 30),
            container.bottomAnchor.constraint(equalTo: durationGraghMBV.bottomAnchor),
            container.heightAnchor.constraint(equalTo: durationGraghMBV.heightAnchor, multiplier: 1.7)
        ])
        
        container.progersColor = outerProgerssGradient
//        activityProgressImgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 5 / 180)
        container.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)
        container.setGaugeProgress(0.4)
       
        let caloriesProgV = GaugeContainerView()
        caloriesProgV.translatesAutoresizingMaskIntoConstraints = false
        caloriesProgV.backgroundColor = UIColor.clear
        caloriesGraghMBV.addSubview(caloriesProgV)
        
        caloriesProgV.showTicks = true
        caloriesProgV.gaugeThickness = 20.0

        NSLayoutConstraint.activate([
            caloriesProgV.leadingAnchor.constraint(equalTo: caloriesGraghMBV.leadingAnchor, constant: -30),
            caloriesProgV.trailingAnchor.constraint(equalTo: caloriesGraghMBV.trailingAnchor, constant: 30),
            caloriesProgV.bottomAnchor.constraint(equalTo: caloriesGraghMBV.bottomAnchor),
            caloriesProgV.heightAnchor.constraint(equalTo: caloriesGraghMBV.heightAnchor, multiplier: 1.7)
        ])
        
        caloriesProgV.progersColor = outerProgerssGradient
        caloriesProgV.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)
        caloriesProgV.setGaugeProgress(0.4)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.exerciseImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.exerciseImgView.addCellImgGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.5), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
            self.exerciseImgView.setGradientBorder(cornerRadious: 24.0, width: 1.0, colors: [ UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0) ], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
          
            self.notesDescTxtView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite.withAlphaComponent(0.68), cornerRadious: 12.0)
           
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            //------------****************
            [
                self.durationMBV,
                self.caloriesMBV,
                self.circuitDurationMBV,
                self.circuitCaloriesMBV,
                self.setsSubMBV,
                self.restMBV,
                self.repsMBV,
            ].forEach({
                $0.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
            
            self.setsIndexBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
}

//MARK: ------------------EXTENSION FOR API
extension EditRegularExerciseViewController{
   
    private func editExercise(){
        var params:[String:Any] = [:]
        params["id"] = workoutIdStr ?? "" //workout id
        params["exercise_id"] = workoutExerciseId ?? "" //exercise_id
        params["reps"] = self.repsCont //reps
        params["sets"] = self.setsCont //sets
        params["rest"] = self.restTimeStr ?? "" //rest in seconds
        params["note"] = self.notesDescTxtView.text //note
        params["sets_position"] = self.setsPositionStr ?? "" //0, if editing superset exercise
        print("params: ", params as Any)

        WorkoutLibraryVM.editWorkoutExerciseApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self else { return }
            print("getResultData: ", getResultData as Any)
            self.sentEditedData?(setsCont, repsCont, self.restTimeStr, notesDescTxtView.text)
            
            self.navigationController?.popViewController(animated: true)
        })
    }
}

/*
extension EditRegularExerciseViewController: UITextViewDelegate{
    
    // MARK: - UITextViewDelegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("TextView began editing")
        
        if textView == notesDescTxtView {
            // Remove placeholder text on focus
            if textView.text == "Type here" || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  {
                textView.text = ""
                textView.textColor = UIColor.appWhite
//                textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) // adjust as needed
            }else{
                textView.textColor = UIColor.appWhite
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        print("Text changed: \(textView.text ?? "")")
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("TextView ended editing")
        if textView == notesDescTxtView {
            // Restore placeholder if text is empty
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = "Type here"
                textView.textColor = UIColor.txtDarkGray
//                textView.textContainerInset = UIEdgeInsets(top: (textView.bounds.height - 20) / 2, left: 16, bottom: 0, right: 16)
            } else {
                textView.textColor = UIColor.appWhite
//                textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            }
        }
    }
}
*/
