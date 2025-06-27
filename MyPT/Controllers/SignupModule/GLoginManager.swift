//
//  GLoginManager.swift
//  MyPT
//
//  Created by techsaga corp on 10/06/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class GLoginManager: NSObject {
    static let shared:GLoginManager = GLoginManager()
    var handle:AuthStateDidChangeListenerHandle?
    
    private override init() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("User is signed in with email: \(user.email ?? "")")
            } else {
                // User is signed out.
                print("User is signed out.")
            }
        }
    }
    
    deinit {
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    //MARK: ---------------- Google login
    func gLogin(viewController:UIViewController, completion: @escaping((_ userInfo:[String:Any?]?,_ userProfile:[String:Any?]?) -> Void)){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            guard self != nil else { return }
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                print(result ?? (Any).self)
                var userInfo:[String:Any?]? = nil
                var userProfile:[String:Any?]? = nil
                
                let user = Auth.auth().currentUser
                if let user = user {
//                    var multiFactorString = "MultiFactor: "
//                    for info in user.multiFactor.enrolledFactors {
//                        multiFactorString += info.displayName ?? "[DispayName]"
//                        multiFactorString += " "
//                    }
                    
                    userInfo = [ "displayName":user.displayName,
                                 "uid":user.uid,
                                 "email":user.email,
                                 "photoURL":user.photoURL,
                                 "phoneNumber":user.phoneNumber,
                    ]
                    
                    completion(userInfo,userProfile)
                }
                
                if let userProfileInfo: GIDGoogleUser = GIDSignIn.sharedInstance.currentUser {
//                    if let _ = userProfileInfo.profile?.hasImage {
//                        let userDP = userProfileInfo.profile?.imageURL(withDimension: 200)
//
//                    }
                    
                    userProfile = ["fullName":userProfileInfo.profile?.name,
                                   "userName":userProfileInfo.profile?.givenName,
                                   "lastName":userProfileInfo.profile?.familyName,
                                   "email":userProfileInfo.profile?.email,
                                   "hasImage":userProfileInfo.profile?.hasImage
                                  ]
                    
                    completion(userInfo,userProfile)
                }
            }
            
        }
    }
    
    func glogout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
