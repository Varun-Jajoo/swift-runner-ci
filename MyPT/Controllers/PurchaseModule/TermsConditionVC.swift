//
//  TermsConditionVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 07/04/26.
//

import UIKit
import WebKit

class TermsConditionVC: UIViewController {
    
    private var termsCondition: TermsConditionRsponse?
    private var isEnglishSelected: Bool = true
    var type = String()
    var onAgreeTap: (() -> Void)?
    
    @IBOutlet weak var lblTermsCondition: UILabel!
    @IBOutlet weak var onTapProceed: UIButton!
    @IBOutlet weak var btnEnglish: UIButton!
    @IBOutlet weak var btnArabic: UIButton!
    @IBOutlet weak var webviewEng: WKWebView!
    @IBOutlet weak var viewLanguageType: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        var baseParams: [String: String] =
            [
                "type": type
            ]
        getTermsApi(inputParams: baseParams) { response in
            DispatchQueue.main.async {
                self.termsCondition = response
                self.loadContent()
            }
        }
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.lblTermsCondition.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.btnEnglish.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.btnArabic.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.btnEnglish.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.btnArabic.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.webviewEng.isOpaque = false
            self.webviewEng.backgroundColor = .clear
            self.webviewEng.scrollView.backgroundColor = .clear
        
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        viewLanguageType.layer.cornerRadius = 24
        btnEnglish.layer.cornerRadius = 18
        btnArabic.layer.cornerRadius = 18
        btnEnglish.layer.masksToBounds = true
        btnArabic.layer.masksToBounds = true
        updateTrainerSelection(isEnglishSelected: true)
    }
    
    private func loadContent() {
        guard let data = termsCondition?.data else { return }
        
        let content = isEnglishSelected ? data.contentEn : data.contentAr
        let title = isEnglishSelected ? data.titleEn : data.titleAr
        
        lblTermsCondition.text = title
        
        if let htmlString = content {
            webviewEng.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    private func updateTrainerSelection(isEnglishSelected: Bool) {
        self.isEnglishSelected = isEnglishSelected
        let darkColor = UIColor(
            red: 24/255,
            green: 29/255,
            blue: 32/255,
            alpha: 1
        )
        
        if isEnglishSelected {
            // Best Plan Selected
            btnEnglish.backgroundColor = .white
            btnEnglish.setTitleColor(.black, for: .normal)
            
            btnArabic.backgroundColor = darkColor
            btnArabic.setTitleColor(.white, for: .normal)
        } else {
            // Customization Selected
            btnArabic.backgroundColor = .white
            btnArabic.setTitleColor(.black, for: .normal)
            
            btnEnglish.backgroundColor = darkColor
            btnEnglish.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func onTapEnglish(_ sender: UIButton) {
        updateTrainerSelection(isEnglishSelected: true)
        loadContent()
    }

    @IBAction func onTapArabic(_ sender: UIButton) {
        updateTrainerSelection(isEnglishSelected: false)
        loadContent()
    }
    
    @IBAction func onTapCross(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
        onAgreeTap?()   // send callback
            self.dismiss(animated: true)
    }
    
    private func getTermsApi(inputParams: [String: String], completion: @escaping (TermsConditionRsponse) -> Void) {
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .clientPtTerms, method: .get, queries: inputParams, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                if let responceData = getResponce {

                    let getResult = try JSONDecoder().decode(TermsConditionRsponse.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
//                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
//                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}
