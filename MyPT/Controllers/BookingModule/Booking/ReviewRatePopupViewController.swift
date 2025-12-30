//
//  ReviewRateViewController.swift
//  MyPT
//
//  Created by techsaga corp on 21/12/24.
//

import UIKit
import Cosmos
import IQTextView

class ReviewRatePopupViewController: UIViewController {
    
    //MARK: -------------VARIABLE
    var navCtrl:UINavigationController?
    var starPadding: CGFloat = 10.0
    var numberOfStars: CGFloat = 5.0
    var inputTrainerId: String?
    var inputBookingId: String?
    
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var reviewMBV: UIView!
    @IBOutlet weak var rateTitleLbl: UILabel!
    @IBOutlet weak var rateTopDescLbl: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var fineLbl: UILabel!
    @IBOutlet weak var feedbackTitleLbl: UILabel!
    @IBOutlet weak var feedDescTxtView: IQTextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedDescTxtView.delegate = self
        self.setupFont()
        self.setupRating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }

    @IBAction func submitBtnAct(_ sender: UIButton) {
        guard let inputBookingId = inputBookingId, let inputTrainerId = inputTrainerId else { return }
        let feedbackTxtSend = (feedDescTxtView.text == "Type here") ? "" : feedDescTxtView.text
        let ratingInput = String(format: "%0.1f", rateView.rating)
        if Float(ratingInput) == 0.0 {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please give rating!")
        }else{
            let params:[String:Any] = [
            "trainer_id": inputTrainerId,
            "booking_id": inputBookingId,
            "message": feedbackTxtSend ?? "",
            "rating": ratingInput
            ]
            print("params: ", params)
            TrainerVM.trainerReviewApi(inputParams: params, completion: {[weak self] getResultData in
                guard self != nil else {
                    return
                }
                self?.dismiss(animated: false, completion: {
                    print("completion is called....")
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshApiNotification"), object: getResultData)
                   
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getRatingData"), object: getResultData)
                    
                    let vc:SuccessfullyPopupViewController = SuccessfullyPopupViewController.instantiate(appStoryboard: .booking)
                    vc.modalPresentationStyle = .automatic
                    vc.navCtrl = self?.navCtrl
                    self?.navCtrl?.present(vc, animated: true)
                })
            })
        }
        
    }
    
    private func setupRating(){
        // Calculate star size so they never go out of bounds
        let totalSpacing = CGFloat(numberOfStars - 1) * starPadding
        let availableWidth = (UIScreen.main.bounds.width - 50) - (starPadding * 2) - totalSpacing
        let starSize = availableWidth / CGFloat(numberOfStars)
        
        rateView.settings.starSize = starSize
        rateView.settings.starMargin = starPadding
        rateView.rating = 0.0
        
        rateView.settings.fillMode = .precise
        // Option 1: Live update while user changes the rating
        rateView.didTouchCosmos = { [weak self] rating in
            guard self != nil else {
                return
            }
            print("User is changing rating: \(rating)")
        }
        
        // Option 2: Final rating after user finishes interaction
        rateView.didFinishTouchingCosmos = { [weak self] rating in
            guard self != nil else {
                return
            }
            print("User selected final rating: \(rating)")
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.reviewMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.reviewMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.feedDescTxtView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.feedDescTxtView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
            self.submitBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
//            self.submitBtn.addGradient(colors: [.red,.yellow, .blue], locations: [0,0.5,1.0], startPoint: CGPoint(x: 0.0, y: 1.0), endPoint: CGPoint(x: 1.0, y: 1.0))
        }
    }
    
    private func setupFont(){
        self.rateTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.rateTopDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fineLbl.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.feedbackTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.feedDescTxtView.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.submitBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        //----------------
        self.feedDescTxtView.text = "Type here"
        self.feedDescTxtView.textColor = UIColor.txtDarkGray
//        self.feedDescTxtView.textContainerInset = UIEdgeInsets(top: (self.feedDescTxtView.bounds.height - 20) / 2, left: 16, bottom: 0, right: 16)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.reviewMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

extension ReviewRatePopupViewController: UITextViewDelegate{
    
    // MARK: - UITextViewDelegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("TextView began editing")
        
        if textView == feedDescTxtView {
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
        if textView == feedDescTxtView {
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
