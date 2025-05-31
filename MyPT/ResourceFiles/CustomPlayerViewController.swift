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
