//
//  CouponsOffersViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/12/24.
//

import UIKit

enum CouponSection: Int, CaseIterable {
    case offerFOrYou
    case bankOffer
    
    var title: String {
        switch self {
        case .offerFOrYou:
            return "Offers for you"
        case .bankOffer:
            return "Bank offers"
        }
    }
}

class CouponsOffersViewController: CommonViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: --------------VARIABLE
    var selectedIndx:IndexPath = IndexPath(row: -1, section: 0)
    var sentBackCoupon: ((CoupenData, UIViewController) -> Void)?

    private var offerForYou: [CoupenData] = []
    private var bankOffer: [CoupenData] = []
    var promoList: [CoupenData] = []
    private var promoCodes: [String] = []
    private var selectedCouponFromText: CoupenData?


    //MARK: --------------IBOUTLET
    @IBOutlet weak var checkCouponMBV: UIView!
    @IBOutlet weak var chechCouponTxtField: UITextField!
    @IBOutlet weak var couponListTbl: UITableView!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var viewCouponCode: UIView!
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var lblUperCouponCode: UILabel!
    @IBOutlet weak var lblInvalidCoupon: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpFont()
//        loadData()
        
        offerForYou = promoList
           bankOffer = []           //  no bank offers
           couponListTbl.reloadData()
        
        couponListTbl.delegate = self
        couponListTbl.dataSource = self
        couponListTbl.register(UINib(nibName: "CouponsOffersTableViewCell", bundle: nil), forCellReuseIdentifier: "CouponsOffersTableViewCell")
        viewCouponCode.isHidden = true
        
        chechCouponTxtField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        lblInvalidCoupon.isHidden = true
        applyBtn.isUserInteractionEnabled = false
        applyBtn.alpha = 0.5
        offerForYou = promoList
        promoCodes = promoList.map { $0.offerCode.lowercased() }

        chechCouponTxtField.autocapitalizationType = .allCharacters
        chechCouponTxtField.autocorrectionType = .no
        chechCouponTxtField.spellCheckingType = .no
        
        promoCodes = promoList.map {
               $0.offerCode
                   .trimmingCharacters(in: .whitespacesAndNewlines)
                   .lowercased()
           }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [AppStrings.coupons_Offers], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //------------------************Font
    func setUpFont(){
        self.lblUperCouponCode.font = AppFont.regular.size(10, familyName: familyFunnelSans)
        self.chechCouponTxtField.font = AppFont.semibold.size(14, familyName: familyFunnelSans)
        self.applyBtn.titleLabel?.font = AppFont.medium.size(12, familyName: familyFunnelSans)
        self.chechCouponTxtField.attributedPlaceholder = NSAttributedString(
            string: "Enter coupon code",
            attributes: [
                .foregroundColor: UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1),
                .font: AppFont.semibold.size(14, familyName: familyManrope)
            ]
        )
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            
            self.chechCouponTxtField.placeholderSet(placeHolder: "Enter coupon code", color: UIColor.txtDarkGray)
            
            self.checkCouponMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.1), cornerRadious: 12.0)
        }
    }
    

//    @objc private func textFieldDidChange() {
//
//        let enteredText = chechCouponTxtField.text?
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .lowercased() ?? ""
//
//        // floating label
//        viewCouponCode.isHidden = enteredText.isEmpty
//
//        // reset state
//        lblInvalidCoupon.isHidden = true
//        applyBtn.isUserInteractionEnabled = false
//        applyBtn.alpha = 0.5
//
//        guard !enteredText.isEmpty else { return }
//
//        let isValidCoupon = promoCodes.contains { $0 == enteredText }
//
//        if isValidCoupon {
//            //  VALID
//            lblInvalidCoupon.isHidden = true
//            applyBtn.isUserInteractionEnabled = true
//            applyBtn.alpha = 1.0
//        } else {
//            //  INVALID
//            lblInvalidCoupon.text = "Invalid coupon code"
//            lblInvalidCoupon.isHidden = false
//        }
//    }
    @objc private func textFieldDidChange() {

        let enteredText = chechCouponTxtField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        viewCouponCode.isHidden = enteredText.isEmpty

        lblInvalidCoupon.isHidden = true
        applyBtn.isUserInteractionEnabled = false
        applyBtn.alpha = 0.5
        selectedCouponFromText = nil   // 🔑 reset

        guard !enteredText.isEmpty else { return }

        // 🔍 find matching coupon
        if let matchedCoupon = promoList.first(
            where: { $0.offerCode.lowercased() == enteredText }
        ) {
            // ✅ VALID
            selectedCouponFromText = matchedCoupon
            lblInvalidCoupon.isHidden = true
            applyBtn.isUserInteractionEnabled = true
            applyBtn.alpha = 1.0
        } else {
            // ❌ INVALID
            lblInvalidCoupon.text = "Invalid coupon code"
            lblInvalidCoupon.isHidden = false
        }
    }

    
    
    @IBAction func applyBtnActn(_ sender: UIButton){
        print("apply btn clicked")
        guard let coupon = selectedCouponFromText else { return }

          // ✅ Send back selected coupon
          sentBackCoupon?(coupon, self)

          // ✅ Go back
//          navigationController?.popViewController(animated: false)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return CouponSection.allCases.count
        return offerForYou.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = CouponSection(rawValue: section) else { return 0 }
        
//        switch sectionType {
//        case .offerFOrYou:
//            return offerForYou.count
//        case .bankOffer:
//            return bankOffer.count
//        }
        return offerForYou.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        guard let sectionType = CouponSection(rawValue: indexPath.section) else {
//            return UITableViewCell()
//        }
//        
//        switch sectionType {
//        case .offerFOrYou:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "CouponsOffersTableViewCell", for: indexPath) as? CouponsOffersTableViewCell {
//                let trainer = offerForYou[indexPath.row]
//                //                cell.constCellWidth.constant = tableView.frame.width
//                return cell
//            }
//            
//        case .bankOffer:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "CouponsOffersTableViewCell", for: indexPath) as? CouponsOffersTableViewCell {
//                
//                let coupon = bankOffer[indexPath.row]
//                cell.lblCouonName.text = coupon.couponName
//                cell.lblExpireDate.text = coupon.expiryDate
//                cell.lblSavedAED.text = coupon.saveAED
//                return cell
//            }
//        }
//        
//        return UITableViewCell()
//    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CouponsOffersTableViewCell",
            for: indexPath
        ) as! CouponsOffersTableViewCell

        let coupon = offerForYou[indexPath.row]
        cell.lblCouonName.text = coupon.offerCode
        cell.lblExpireDate.text = coupon.expiryDate
//        cell.lblSavedAED.text = "SAVE AED " + coupon.description
        cell.lblSavedAED.text = coupon.description

        // ✅ Handle Apply button tap
          cell.applyAction = { [weak self] in
              guard let self = self else { return }

              self.sentBackCoupon?(coupon, self)
//              self.navigationController?.popViewController(animated: false)
          }

        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell index", indexPath.row)
        selectedIndx = indexPath
        tableView.reloadData()
        //        let cell:CouponsOffersTableViewCell = tableView.cellForRow(at: indexPath) as! CouponsOffersTableViewCell
        
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionType = CouponSection(rawValue: section) else { return nil }
        
        let header = UIView()
        header.backgroundColor = .clear
        
        let label = UILabel()
        label.text = sectionType.title
        label.textColor = .white
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 0.75)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12)
        ])
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //        print("Deselected cell index", indexPath.row)
        //        let cell:CouponsOffersTableViewCell = tableView.cellForRow(at: indexPath) as! CouponsOffersTableViewCell
        
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = CouponSection(rawValue: indexPath.section) else {
            return 95
        }
        
        switch section {
        case .offerFOrYou:
            //            return 114
            return 95
        case .bankOffer:
            return 95
        }
    }
    
}

struct CoupenData {
    let id: Int
    let offerCode: String
    let expiryDate: String
    let description: String
    let isOfferForYou: Bool
}
