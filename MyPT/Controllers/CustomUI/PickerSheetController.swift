//
//  PickerSheetController.swift
//  MyPT
//
//  Created by techsaga corp on 06/09/25.
//

import UIKit

//class PickerSheetController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

class PickerSheetController<T: UIView>: UIViewController {
    
    private let pickerView: T
    private let titleText: String
    private let onDone: (() -> Void)?
    
    init(title: String,
         pickerView: T,
         onDone: (() -> Void)? = nil) {
        self.titleText = title
        self.pickerView = pickerView
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(pickerView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200),
            
            doneButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true) {
            self.onDone?()
        }
    }
}
