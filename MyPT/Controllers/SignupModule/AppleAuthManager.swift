//
//  AppleAuthManager.swift
//  MyPT
//
//  Created by techsaga corp on 10/06/25.
//

import Foundation
import AuthenticationServices

struct AppleLoginData {
    var userIdentifier: String?
    var fullName: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var identityToken: String? //for send to server
}

class AppleAuthManager: NSObject {

    static let shared = AppleAuthManager()
    var sendData: ((AppleLoginData) -> Void)?

    private override init() {
        super.init()
    }

    func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    private func getCredentialState(for userId: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { state, error in
            switch state {
            case .authorized:
                break
            case .revoked:
                break
            case .notFound:
                break
            default:
                break
            }
        }
    }

}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName ?? ""
            let userLastName = appleIDCredential.fullName?.familyName ?? ""
            let email = appleIDCredential.email
            
            if let identityTokenData = appleIDCredential.identityToken,
               let tokenString = String(data: identityTokenData, encoding: .utf8) {

                let loginData = AppleLoginData(
                    userIdentifier: userIdentifier,
                    fullName: "\(userFirstName) \(userLastName)",
                    firstName: userFirstName,
                    lastName: userLastName,
                    email: email,
                    identityToken: tokenString
                )
                
                self.sendData?(loginData)
            }
            
            getCredentialState(for: userIdentifier)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed:", error.localizedDescription)
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

