//
//  TrainerScheduleVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 28/03/26.
//

import UIKit

class TrainerScheduleVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var restOfTheslots: [SelectedSlot]?
    var callBack: ((SelectedSlot) -> Void)?
    var selectedSlot: SelectedSlot?
    var selectedDate: String?
    var fromHome: Bool = false
    var forFullSchedule: Bool = false
    
    @IBOutlet var viewMain: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var btnContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        lblDate.text = formatDate(selectedDate ?? "")
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
    }

    private func uiSetup() {
        collectionDate.delegate = self
        collectionDate.dataSource = self
        collectionDate.register(
            UINib(nibName: "UnavailableTimeCVCell", bundle: nil),
            forCellWithReuseIdentifier: "UnavailableTimeCVCell"
        )
        btnContinue.isHidden = forFullSchedule
       DispatchQueue.main.async {
            self.lblDate.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
//            self.btnContinue.setTitle("CONTINUE ", for: .normal)
//            self.btnContinue.setImage(UIImage(named: "whiteRightArrow"), for: .normal)
//            self.btnContinue.semanticContentAttribute = .forceRightToLeft
            self.btnContinue.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//            self.btnContinue.tintColor = .mainBg   // arrow color
//            self.btnContinue.backgroundColor = .appWhite
//            self.btnContinue.setTitleColor(.mainBg, for: .normal)
            self.btnContinue.cornersWithBorder(radius: 8, corners: .allCorners)
       }
    }
    
    func formatDate(_ dateStr: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        
        let output = DateFormatter()
        output.dateFormat = "d MMM"
        
        guard let date = input.date(from: dateStr) else { return "" }
        
        let day = Calendar.current.component(.day, from: date)
        
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        
        let formatted = output.string(from: date) // "31 Mar"
        return formatted.replacingOccurrences(of: "\(day)", with: "\(day)\(suffix)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if restOfTheslots?.count == 0 {
            collectionView.showEmptyView(
                title: "No Result Found",
                image: AppImages.search_NoResult,
                centerOffset: -30   // adjust if needed
            )
        } else {
            collectionView.restoreEmptyView()
        }
        return restOfTheslots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UnavailableTimeCVCell", for: indexPath
        ) as? UnavailableTimeCVCell else { return UICollectionViewCell() }
        cell.lblTime.text = restOfTheslots?[indexPath.row].startTime
        // Apply selected/unselected UI
        cell.setSelected(restOfTheslots?[indexPath.row].isSelected ?? false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !forFullSchedule {
            let isAlreadySelected = restOfTheslots?[indexPath.row].isSelected ?? false
            
            // Deselect ALL cells first
            for i in 0..<(restOfTheslots?.count ?? 0) {
                restOfTheslots?[i].isSelected = false
            }
            
            // If it was NOT selected before → select it
            // If it WAS selected before → leave it deselected (toggle off)
            if !isAlreadySelected {
                restOfTheslots?[indexPath.row].isSelected = true
                selectedSlot = restOfTheslots?[indexPath.row]
                updateContinueButton(isEnabled: true)
            }
            collectionDate.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 4 items per row with 8pt spacing between them
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3  // 3 gaps for 4 columns
        let cellWidth = (collectionView.frame.size.width - totalSpacing) / 4
        return CGSize(width: cellWidth, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func updateContinueButton(isEnabled: Bool) {
        btnContinue.isEnabled = isEnabled
        btnContinue.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.btnContinue.tintColor = .mainBg   // arrow color
                self.btnContinue.backgroundColor = .appWhite
                self.btnContinue.setTitleColor(.mainBg, for: .normal)
            } else {
                self.btnContinue.tintColor = .appWhite
                self.btnContinue.backgroundColor = .appDarkGray
                self.btnContinue.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
            let image = UIImage(named: "ButtonContinue")?
                .withRenderingMode(.alwaysOriginal)

            btnContinue.setImage(image, for: .normal)
            btnContinue.setTitle("", for: .normal)

            btnContinue.backgroundColor = .clear
            btnContinue.tintColor = .clear

            btnContinue.imageEdgeInsets = .zero
            btnContinue.titleEdgeInsets = .zero
            btnContinue.contentEdgeInsets = .zero
            btnContinue.semanticContentAttribute = .forceLeftToRight
            btnContinue.adjustsImageWhenHighlighted = false
            btnContinue.adjustsImageWhenDisabled = false

        } else {
            // 🔴 DISABLED → TEXT + ARROW
            btnContinue.setTitle("CONTINUE", for: .normal)
            btnContinue.setTitleColor(.appWhite, for: .normal)

            let arrowImage = UIImage(named: "whiteRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            btnContinue.setImage(arrowImage, for: .normal)

            btnContinue.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            btnContinue.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnContinue.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnContinue.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBAction func onTapContinue(_ sender: UIButton) {
        self.dismiss(animated: false, completion: {
            if let data = self.selectedSlot {
                self.callBack?(data)
            }
        })
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
