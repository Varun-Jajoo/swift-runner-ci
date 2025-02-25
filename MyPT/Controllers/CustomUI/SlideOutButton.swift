//
//  SlideOutButton.swift
//  MyPT
//
//  Created by techsaga corp on 09/01/25.
//

import UIKit

struct Colors {
    static let background = UIColor.appCard2
    static let draggedBackground = UIColor.appCard2
    static let tint = UIColor.appWhite
}

protocol SlideToActionButtonDelegate: AnyObject {
    func didFinish()
}

class SlideToActionButton: UIView {
    
    var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.draggedBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = Colors.tint.cgColor
        return view
    }()
    
    var handleViewImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "chevron.right.2", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40, weight: .bold)))?.withRenderingMode(.alwaysTemplate)
        view.contentMode = .scaleAspectFill
        view.tintColor = Colors.tint
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let draggedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.draggedBackground
        view.layer.cornerRadius = 12
        return view
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = Colors.tint
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "Slide me!"
        return label
    }()
    
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!

    weak var delegate: SlideToActionButtonDelegate?
    
    private var xEndingPoint: CGFloat {
        return (bounds.width - handleView.bounds.width)
    }
    
    private var isFinished = false
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        backgroundColor = Colors.background
        layer.cornerRadius = 12
        addSubview(titleLabel)
        addSubview(draggedView)
        addSubview(handleView)
        handleView.addSubview(handleViewImage)
        
        //MARK: - Constraints
        
        leadingThumbnailViewConstraint = handleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            leadingThumbnailViewConstraint!,
//            handleView.topAnchor.constraint(equalTo: topAnchor),
//            handleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
            handleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.0),
            handleView.widthAnchor.constraint(equalToConstant: 60),
            draggedView.topAnchor.constraint(equalTo: topAnchor),
            draggedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            draggedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            draggedView.trailingAnchor.constraint(equalTo: handleView.trailingAnchor),
            handleViewImage.topAnchor.constraint(equalTo: handleView.topAnchor, constant: 2),
            handleViewImage.bottomAnchor.constraint(equalTo: handleView.bottomAnchor, constant: -2),
            handleViewImage.centerXAnchor.constraint(equalTo: handleView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        handleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished { return }
        let translatedPoint = sender.translation(in: self).x

        self.titleLabel.textColor = UIColor.txtDarkGray
        draggedView.addSubview(titleLabel)
        
        switch sender.state {
        case .changed:
            if translatedPoint <= 0 {
                updateHandleXPosition(0)
            } else if translatedPoint >= xEndingPoint {
                updateHandleXPosition(xEndingPoint)
            } else {
                updateHandleXPosition(translatedPoint)
            }
        case .ended:
            if translatedPoint >= xEndingPoint {
                self.updateHandleXPosition(xEndingPoint)
                isFinished = true
                delegate?.didFinish()
            } else {
                UIView.animate(withDuration: 1) {
                    self.reset()
                }
            }
        default:
            break
        }
    }
    
    private func updateHandleXPosition(_ x: CGFloat) {
        leadingThumbnailViewConstraint?.constant = x
    }

    func reset() {
        self.titleLabel.textColor = UIColor.appWhite
        isFinished = false
        updateHandleXPosition(0)
    }
}
