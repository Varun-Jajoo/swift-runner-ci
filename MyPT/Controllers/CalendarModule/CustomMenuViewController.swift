//
//  CustomMenuViewController.swift
//  MyPT
//
//  Created by techsaga corp on 29/08/25.
//

import UIKit

// MARK: - Menu Item Model
struct MenuItem {
    let title: String
    let image: UIImage?           // Custom image
    let isDestructive: Bool
    let titleColor: UIColor?
    let backgroundColor: UIColor?
    let font: UIFont?
    let separatorColor: UIColor?   // <-- New property
}

class CustomMenuViewController: UIViewController {
    
    var onMenuItemSelected: ((_ actionTitle: String) -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var menuItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMenuOptions()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMenuOptions() {
        for (index, item) in menuItems.enumerated() {
            let menuView = createMenuItem(item: item, showSeparator: index != 0)
            stackView.addArrangedSubview(menuView)
        }
    }
    
    private func createMenuItem(item: MenuItem, showSeparator: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Separator
        if showSeparator {
            let separator = UIView()
            separator.backgroundColor = item.separatorColor ?? UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: 1)
            separator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: container.topAnchor),
                separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        // Button
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(item.title, for: .normal)
        if let image = item.image {
            button.setImage(image, for: .normal)
        }

        button.setTitleColor(item.titleColor, for: .normal)
        button.backgroundColor = item.backgroundColor ?? .clear
        button.titleLabel?.font = item.font ?? UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        container.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: showSeparator ? 1 : 0),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
//            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        button.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
        
        return container
    }
    
    @objc private func menuItemTapped(_ sender: UIButton) {
        guard let actionTitle = sender.title(for: .normal) else { return }
        onMenuItemSelected?(actionTitle)
        dismiss(animated: true, completion: nil)
    }
}

/* ------------- usese
 let menuVC = CustomMenuViewController()
 menuVC.menuItems = [
     MenuItem(title: "Edit", image: UIImage(named: "ic_edit_black")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: false, titleColor: UIColor.mainBg, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: .clear),
     MenuItem(title: "Delete", image: UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: true, titleColor: UIColor.appRed, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0))
 ]

 menuVC.onMenuItemSelected = { title in
     print("Selected: \(title)")
 }
 
 // REQUIRED: Set the presentation style to popover
 menuVC.modalPresentationStyle = .popover
 menuVC.preferredContentSize = CGSize(width: 150, height: 90)
 
 // Configure the popover
 if let popover = menuVC.popoverPresentationController {
     popover.delegate = self
     popover.sourceView = sourceView // The button is the source view
//            popover.sourceRect = sourceView.bounds // Position it correctly
//            popover.permittedArrowDirections = .up // [.up, .down, .any] // Set arrow direction
     popover.sourceRect = CGRect(
         x: sourceView.bounds.midX + 10.0,   // horizontally center
         y: sourceView.bounds.maxY + 20.0,   // bottom edge of the button
         width: 0,
         height: 0
     )
     popover.permittedArrowDirections = [] // <-- Remove arrow
     
     // You can even customize the popover's background
     popover.backgroundColor = UIColor.clear
 }
 
 present(menuVC, animated: true, completion: nil)
 */
