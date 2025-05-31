//
//  ValidationFiles.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import Foundation

//MARK: --------- Extension String
extension String {
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9+._%\\-]{1,256}" + "@" + "[a-zA-Z][a-zA-Z\\-]{0,64}" + "(" + "\\." + "[a-zA-Z][a-zA-Z\\-]{0,25}" + ")+",options:.caseInsensitive)
        return regex.firstMatch(in: self,options:[],range:NSRange(location:0,length:count)) != nil
    }
    
    func isValidPassword() -> Bool {
        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
        
    }
    //Method is used for validation of phone number
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
}


extension Double {
    
    /*
     let value1 = 2.222
     print(value1.formattedTwoDecimal) // Output: "2.22"
     */
    var formattedTwoDecimal: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Float {
    var formattedTwoDecimal: String {
        Double(self).formattedTwoDecimal
    }
}
