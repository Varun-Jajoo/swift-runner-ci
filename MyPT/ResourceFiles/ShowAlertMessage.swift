//
//  ShowAlertMessage.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit

class AlertHelper: NSObject {
    static let shared = AlertHelper()

    private var isPresentingAlert = false
    private var pendingAlerts: [() -> Void] = []

    func alertMesssage(view: UIViewController, title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(defaultAction)
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true)
        })
    }
    
    func showCustomeAlert(title alertTitle:String = "", message alertMessage:String, actions:[String] = ["OK","Cancel"], withCancel:Bool = false, completion:((_ index: Int?) -> (Void))? = nil) -> Void {
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: .alert)
        let getActions: [String] = (withCancel ? actions : [actions.first ?? "OK"])
        
        for (index,item) in getActions.enumerated() {
            
            let action = UIAlertAction(title: item,
                                       style: .default,
                                       handler: { _ in
                DispatchQueue.main.async { completion?(index) }
            })
            
            alertController.addAction(action)
        }
        
        DispatchQueue.main.async(execute: {
            self.presentViewController(alertController: alertController)
        })
    }
    
    //MARK: -------------------FOR ROOTVIEW
    /// Guards against UIKit's fatal "Attempt to present <UIAlertController> ...
    /// while a presentation is in progress" crash: rapid free -> paid -> free
    /// booking flows can each fire their own alert/loader/sheet transition in
    /// quick succession, all funnelling through this single shared presenter.
    /// Alerts requested while one is already up (or the top controller is mid
    /// present/dismiss) are queued and shown one at a time instead of colliding.
    private func presentViewController(alertController: UIAlertController, completion: (() -> Void)? = nil) {
        let work: () -> Void = { [weak self] in
            guard let self = self else { return }
            guard let topController = self.topMostViewController() else {
                self.isPresentingAlert = false
                self.presentNextPendingAlert()
                return
            }
            guard topController.presentedViewController == nil,
                  !topController.isBeingPresented,
                  !topController.isBeingDismissed else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.presentViewController(alertController: alertController, completion: completion)
                }
                return
            }
            self.isPresentingAlert = true
            topController.present(alertController, animated: true) { [weak self] in
                completion?()
                self?.isPresentingAlert = false
                self?.presentNextPendingAlert()
            }
        }

        if isPresentingAlert {
            pendingAlerts.append(work)
        } else {
            work()
        }
    }

    private func presentNextPendingAlert() {
        guard !isPresentingAlert, !pendingAlerts.isEmpty else { return }
        let next = pendingAlerts.removeFirst()
        next()
    }

    private func topMostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard var topController = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    private override init() { }
}


class Toast {
    static func show(message: String, duration: TimeInterval = 2.0) {
           guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
           
           let toastContainer = UIView(frame: CGRect())
           toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
           toastContainer.alpha = 0.0
           toastContainer.layer.cornerRadius = 25
           toastContainer.clipsToBounds  =  true
           
           let toastLabel = UILabel(frame: CGRect())
           toastLabel.textColor = UIColor.white
           toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15.0) //AppFont.regular.size(15.0)
           toastLabel.text = message
           toastLabel.clipsToBounds  =  true
           toastLabel.numberOfLines = 0
           
           toastContainer.addSubview(toastLabel)
           window.addSubview(toastContainer)
           
           toastLabel.translatesAutoresizingMaskIntoConstraints = false
           toastContainer.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 15),
               toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -15),
               toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 15),
               toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -15),
               
               toastContainer.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 15),
               toastContainer.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -15),
               toastContainer.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -75),
               toastContainer.centerXAnchor.constraint(equalTo: window.centerXAnchor)
           ])
           
           UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
               toastContainer.alpha = 1.0
           }, completion: { _ in
               UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                   toastContainer.alpha = 0.0
               }, completion: { _ in
                   toastContainer.removeFromSuperview()
               })
           })
       }
    
}
