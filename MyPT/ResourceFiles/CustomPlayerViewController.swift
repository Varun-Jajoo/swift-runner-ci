//
//  CustomPlayerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 01/05/25.
//

import AVKit

class CustomPlayerViewController: AVPlayerViewController {
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
         super.dismiss(animated: false, completion: completion)
     }
    
}



class CustomImagePickerController: UIImagePickerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true // Prevent swipe-to-dismiss
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // Optional: Log or intercept dismiss if needed
        print("Dismiss called on CustomImagePickerController")
//        super.dismiss(animated: flag, completion: completion)
        super.dismiss(animated: false, completion: completion)
    }
}
