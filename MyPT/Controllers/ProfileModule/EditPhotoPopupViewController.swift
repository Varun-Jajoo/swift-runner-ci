//
//  EditPhotoPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 16/06/25.
//

import UIKit

class EditPhotoPopupViewController: UIViewController {

    var getBackImg : ((UIImage?)-> Void)?
    var profileImg: UIImage? = nil
    var coverProfileImg: UIImage? = nil
    let imagePicker = ImagePicker()
    var navCtrnl:UINavigationController?
    
    
    // MARK: ----------------IBOUTLET
    @IBOutlet weak var editPhotoPopupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var changePhotoBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var viewPhotoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        //rgba(35, 35, 35, 0.25)
        self.view.backgroundColor = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.25)
        self.setupFont()
        self.setupUI()
    }
    
    enum editPhotoBtnTag: Int {
    case topBar = 3301, changePhoto, removePhoto, viewPhoto
    }
    
    @IBAction func editPhotoCommonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case editPhotoBtnTag.topBar.rawValue:
            self.dismiss(animated: true, completion: nil)
            break
        case editPhotoBtnTag.changePhoto.rawValue:
            print("Change photo")
            imagePicker.showImagePicker(from: self, allowsEditing: true)
            
        case editPhotoBtnTag.removePhoto.rawValue:
            print("remove Photo")
            var params:[String:String] = [ : ]
            if let _ = self.profileImg {
                params["type"] = "profile"
            }else{
                params["type"] = "cover_image"
            }
            
            ProfileVM.deleteUserProfileImageApi(inputparams: params, completion: { [weak self] getResultData in
                guard let self = self else { return  }
                print("getResultData", getResultData as Any)
                self.dismiss(animated: true, completion: {
                    self.navCtrnl?.popToViewController(ofClass: ProfileViewController.self)
                })
            })
            
        case editPhotoBtnTag.viewPhoto.rawValue:
            print("view photo")
            self.dismiss(animated: true, completion: {
                let vc: ImagePreviewerViewController = ImagePreviewerViewController.instantiate(appStoryboard: .profile)
//                vc.previewImg = self.profileImg
                if let profileImg = self.profileImg {
                    vc.previewImg = profileImg
                }else{
                    vc.previewImg = self.coverProfileImg
                }
                vc.modalPresentationStyle = .automatic
                vc.navCtrnl = self.navCtrnl
                self.navCtrnl?.present(vc, animated: true)
            })
        
        default:
            print("none....")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.editPhotoPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.editPhotoPopupMBV.applyShadow(fillColor: UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.25), shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
        }
    }
    
    private func setupFont(){
        [
            changePhotoBtn.titleLabel,
            removeBtn.titleLabel,
            viewPhotoBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.editPhotoPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

extension EditPhotoPopupViewController: ImagePickerDelegate {
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        // Handle the selected image
        // You can display, upload, or process the image as needed
//        userProfileImgView.image = image
        self.getBackImg?(image)
        imagePicker.dismiss()
        self.dismiss(animated: true, completion: nil)
        
//        imagePicker.dismiss()
    }
    
    func cancelButtonDidClick(on imagePicker: ImagePicker) {
        print("Image selection/capture was canceled")
        imagePicker.dismiss()
    }
}
