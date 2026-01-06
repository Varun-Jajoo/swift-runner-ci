//
//  NetworkManager.swift
//  MyPT
//
//  Created by techsaga corp on 27/01/25.
//

import Foundation
import Alamofire
import SVProgressHUD

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

class NetworkManager {
    static let shared: NetworkManager = {
        return NetworkManager()
    }()
    private var retryLimit = 1
    
    // MARK: ----------------- It's used for array of object as parameter to pass to use codable struct as like struct Example:Codable{ var i = 0 }
    
    func serviceAPICallForArrayObject<T: Encodable>(_ serviceEndPoint: ApiEndPoint, method: HTTPMethod, queries: [String: String]? = nil, parametersEncode: [T]? = nil, interceptor: RequestInterceptor? = nil, isShowLoading: Bool = false, completion: @escaping ((Data?, Error?) -> Void)){
        
        let url = serviceEndPoint.getURL(queries: queries)
        let headers = serviceEndPoint.headers
        
        guard let url = url else {
            // Invalid url
            return
        }
        if !Connectivity.isConnectedToInternet{   // no internet connection
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.ckeck_network)
            completion(nil, nil)
            return
        }
        // Show Loader
        if isShowLoading {
//            Utility.showLoader(message:  AppAlertStrings.please_wait)
            Utility.showLoader(message: AppAlertStrings.preparing_your_experience)
        }
        
    
        AF.request(url, method: method, parameters: parametersEncode, encoder: JSONParameterEncoder.default, headers: headers, interceptor: interceptor ?? self).validate().responseData { response in
           
            Utility.hideLoader() // Dismiss Loader
            switch response.result{
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                    print(json)
                                }
                            }catch {
                                print(error.localizedDescription)
                            }
                            completion(data, nil)
                        }
                    case badRequest:
                        // Bad Request: Handle the specific error case
                        print("Bad Request")
                    case InvalidAccessTokenCode:
                        // Unauthorized: Handle the specific error case
                        self.handle401StatusCode(serviceEndPoint)
                        print("INVALID AUTHTOKEN") //when AuthToken is expire
                        
                    default:
                        print("Status Code: \(statusCode)")
                        break
                    }
                }
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case InvalidAccessTokenCode:
                        self.handle401StatusCode(serviceEndPoint)
                        break
                    default:
//                        AlertHelper.shared.showCustomeAlert(message: error.localizedDescription)
                        completion(nil, nil)
                        break
                    }
                }
            }
        }
        
    }
    
    func genericAPICall(serviceEndPoint: ApiEndPoint, method: HTTPMethod, queries: [String: String]? = nil, parameters: Parameters? = nil, interceptor: RequestInterceptor? = nil, isShowLoading: Bool = false, completion: @escaping ((Data?, Error?) -> Void)){
        
        let url = serviceEndPoint.getURL(queries: queries)
        print("Api url: ", url as Any)
        // Get the correct headers dynamically
        let headers = serviceEndPoint.headers
              
        guard let url = url else {
            // Invalid url
            return
        }
        if !Connectivity.isConnectedToInternet{   // no internet connection
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.ckeck_network)
            completion(nil, nil)
            return
        }
        // Show Loader
        if isShowLoading{
            Utility.showLoader(message: AppAlertStrings.preparing_your_experience)
        }
       
        //URLEncoding.default // in get method Standard URL encoding 
        //JSONEncoding.default //// JSON body encoding
        //URLEncoding.queryString) // Query string encoding
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: interceptor ?? self).validate().responseData{ response in
            Utility.hideLoader() // Dismiss Loader
            switch response.result{
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                    print(json)
                                }
                            }catch {
                                print(error.localizedDescription)
                            }
                            completion(data, nil)
                        }
                    case badRequest:
                        // Bad Request: Handle the specific error case
                        print("Bad Request")
                    case InvalidAccessTokenCode:
                        // Unauthorized: Handle the specific error case
                        self.handle401StatusCode(serviceEndPoint)
                        print("INVALID AUTHTOKEN") //when AuthToken is expire
                        
                    default:
                        print("Status Code: \(statusCode)")
                        break
                    }
                }
                
            case .failure(let error):
                
                if (error as NSError).code == NSURLErrorTimedOut {
                    // Handle timeout specifically
                    print("Request timed out.")
                    SVProgressHUD.showError(withStatus: "Request timed out. Please try again.")
                }else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    // Handle no internet connection
                    print("No internet connection.")
                    SVProgressHUD.showError(withStatus: "No internet connection. Please check your settings.")
                }
                else {
                    // Handle other errors
                    print("An error occurred: \(error.localizedDescription)")
//                    SVProgressHUD.showError(withStatus: "An error occurred. Please try again.")
//                    SVProgressHUD.showError(withStatus: "An error occurred.")
                }
                
                /*
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case InvalidAccessTokenCode:
                        self.handle401StatusCode(serviceEndPoint)
                        break
                    default:
                        AlertHelper.shared.showCustomeAlert(message: error.localizedDescription, actions: ["Ok"])
                        completion(nil, nil)
                        break
                    }
                }
                */
            }
        }
    }
    
    private func handle401StatusCode(_ serviceEndPoint: ApiEndPoint){
//        AlertHelper.shared.showCustomeAlert(message: "Session expired, please login again", actions: ["Ok"])
        AlertHelper.shared.showCustomeAlert(message: "Session expired, please login again", actions: ["Ok"], completion: { [weak self] getTag in
            
            guard self != nil else {
                return
            }
            self?.logoutOnExpiredSession()
        })
    }
    
    private func logoutOnExpiredSession(){
        if  appUserDefaults.clearUserDefault() {
            appSceneDelegate?.goToMainView()
        }
    }
    
    func uploadMedia(serviceEndPoint: ApiEndPoint,
                     method: HTTPMethod,
                     queries: [String: String]? = nil,
                     parameters: Parameters? = nil,
                     interceptor: RequestInterceptor? = nil,
                     isShowLoading: Bool = false,
                     mediaPaths: [[String: Any]],
                     completion: @escaping ((Data?, Error?) -> Void)) {
        
        guard let url = serviceEndPoint.getURL(queries: queries) else {
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        
        if isShowLoading {
//            Utility.showLoader(message: AppAlertStrings.please_wait)
            Utility.showLoader(message: AppAlertStrings.preparing_your_experience)
        }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                
                // Append parameters
                if let parameters = parameters {
                    for (key, value) in parameters {
                        let stringValue = "\(value)"
                        if let data = stringValue.data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
                
                // Append media files
                for mediaPath in mediaPaths {
                    for (key, value) in mediaPath {
                        if let url = value as? URL {
                            let fileExtension = url.pathExtension.lowercased()
                            var pathExtension = url.pathExtension
                            let mimeType: String
                            
                            switch fileExtension {
                            case "jpg", "jpeg":
                                mimeType = "image/jpeg"
                            case "png":
                                mimeType = "image/png"
                            case "mp4", "mov":
                                mimeType = "video/mp4"
                                pathExtension = "mp4"
                            case "pdf":
                                mimeType = "application/pdf"
                            case "doc", "docx":
                                mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                            case "txt":
                                mimeType = "text/plain"
                            default:
                                mimeType = "application/octet-stream"
                            }
                            
                            if let data = try? Data(contentsOf: url) {
                                multipartFormData.append(data,
                                                         withName: key, // Use key as form field name
                                                         fileName: "\(key).\(pathExtension)",
                                                         mimeType: mimeType)
                            }
                        } else if let image = value as? UIImage {
                            if let data = image.jpegData(compressionQuality: 0.5) {
                                multipartFormData.append(data,
                                                         withName: key,
                                                         fileName: "\(key).jpg",
                                                         mimeType: "image/jpeg")
                            }
                        }
                    }
                }
            },
            to: url,
            method: method,
            headers: headers,
            interceptor: interceptor ?? self
        )
        .validate()
        .responseData { response in
            Utility.hideLoader()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        completion(response.data, nil)
                    case badRequest:
                        print("Bad Request")
                    case InvalidAccessTokenCode:
                        self.handle401StatusCode(serviceEndPoint)
                    default:
                        print("Unhandled status code: \(statusCode)")
                    }
                }
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case InvalidAccessTokenCode:
                        self.handle401StatusCode(serviceEndPoint)
                    default:
                        print("Upload failed: \(error.localizedDescription)")
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }

    /*
    func uploadMedia (_ serviceEndPoint: ApiEndPoint, method: HTTPMethod, queries: [String: String]? = nil, parameters: Parameters? = nil, interceptor: RequestInterceptor? = nil, isShowLoading: Bool = false, requestImages arrImages: [Dictionary<String, Any>], requestVideos arrVideos: Dictionary<String, Any>, requestData postData: Dictionary<String, Any>, completion: @escaping ((Data?, Error?) -> Void)){
        
        let url = serviceEndPoint.getURL(queries: queries)
        //        let headers = serviceEndPoint.headers
        let headers: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
        
        guard let url = url else {
            // Invalid url
            return
        }
        if isShowLoading{
            Utility.showLoader(message: AppAlertStrings.please_wait)
        }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                
                if let videoURLS = arrVideos["files"] as? [URL]{
                    for vURL in videoURLS{
                        do {
                            let videoData = try Data(contentsOf: vURL)
                            multipartFormData.append(videoData,
                                                     withName: "files",
                                                     fileName: "files.mp4",
                                                     mimeType: "video/mp4")
                        } catch {
                            print("Unable to load data: \(error)")
                        }
                    }
                }
                
                var docValue : Data
                for dictImage in arrImages
                {
                    let validDict = kSharedInstance.getDictionary(dictImage)
                    if let image = validDict[UIImage()] as? UIImage
                    {
                        multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "files" , fileName: "files.png", mimeType: "image/png")
                    }else if let images = validDict[ConstantApiKeys.image] as? [UIImage]{
                        for image in images{
                            multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "files" , fileName: "files.png", mimeType: "image/png")
                        }
                    }else if let docURLs = validDict[ConstantApiKeys.image] as? [URL]{
                        for doc in docURLs{
                            do {
                                let docData = try Data(contentsOf: doc)
                                docValue = docData
                                multipartFormData.append(docValue,
                                                         withName: "files",
                                                         fileName: "files + \(docURLs)" ,
                                                         mimeType: "application/pdf)")
                                //                                    multipartFormData.append(docValue,withName: "files",fileName: "files + \(docURLs)" ,mimeType: "application/ + \(validDict["fileFormat"])")
                                
                            }catch {
                                print("Unable to load data: \(error)")
                            }
                        }
                    }
                }
                for (key,value) in postData{
                    //Special for Create Quiz
                    if let url = value as? URL{
                        let mimeType: String
                        let fileExtension = url.pathExtension.lowercased()
                        switch fileExtension {
                        case "pdf":
                            mimeType = "application/pdf"
                        case "doc", "docx":
                            mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                        default:
                            mimeType = "application/octet-stream"
                        }
                        
                        do {
                            if let data = try? Data(contentsOf: url){
                                multipartFormData.append(data, withName: "files", fileName: "files."+"\(url.pathExtension)", mimeType:  mimeType)
                            }
                        }
                    }
                    //                    multipartFormData.append(String.getString(value).data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: key)
                    
                    //multipartFormData.append(self.convertToData(value), withName: key)
                }
            },
            to: url, method: .post , headers: headers, interceptor: interceptor ?? self).validate()
            .responseData { (response) in
                Utility.hideLoader()
                switch response.result{
                case .success(_):
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                            
                        case 200...299:
                            if let data = response.data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                        print(json)
                                        completion(data, nil)
                                    }
                                }catch {
                                    print(error.localizedDescription)
                                }
                                completion(data, nil)
                            }
                        case badRequest:
                            // Bad Request: Handle the specific error case
                            print("Bad Request")
                        case InvalidAccessTokenCode:
                            // Unauthorized: Handle the specific error case
//                            self.handle401StatusCode(serviceEndPoint)
                            print("INVALID AUTHTOKEN") //when AuthToken is expire
                            
                        default:
                            print("Status Code: \(statusCode)")
                            break
                        }
                    }
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case InvalidAccessTokenCode:
//                            self.handle401StatusCode(serviceEndPoint)
                            break
                        default:
//                            AlertHelper.showAlert(message: error.localizedDescription)
                            AlertHelper.shared.showCustomeAlert(message: error.localizedDescription)
                            completion(nil, nil)
                            break
                        }
                    }
                }
            }
        
    }
    
    */
    
    
}


extension NetworkManager: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
                
        // Set custom timeout
        request.timeoutInterval = 90 // seconds, change as needed
        
        guard let token = appUserDefaults.getAccessToken() else {
            completion(.success(urlRequest))
            return
        }
        
        let bearerToken = "Bearer \(token)"
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode, statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        print("⚠️⚠️⚠️⚠️retry statusCode....\(statusCode)⚠️⚠️⚠️⚠️")
        
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        
        self.refreshToken(.refreshAccessToken) { success in
            success ? completion(.retry) : completion(.doNotRetry)
        }
    }
    
    func refreshToken(_ serviceEndPoint: ApiEndPoint, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let refreshToken = appUserDefaults.getRefreshToken() else {
            completion(false)
            return
        }
        
        
        let url = serviceEndPoint.getURL(queries: nil)
        let params = ["refreshToken": refreshToken]
        
        guard let url = url else {
            print("Invalid URL--->", url?.absoluteString ?? "Refresh URL is invalid")
            completion(false)
            return
        }
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
            switch response.response?.statusCode{
            case 200:
                if let data = response.data{
                    do {
//                        let result = try JSONDecoder().decode(RefreshAccessTokenModel.self, from: data)
                        
                        // FIXME: - Comment before release
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            if let apiData = json["data"] as? [String: Any]{
                                print("✅✅✅✅","result", apiData)
                            }
                        }
                        
                        appUserDefaults.setAccessToken(accessToken: "result.data?.access_token")
                        appUserDefaults.setRefreshToken(refreshToken: "result.data?.refresh_token")
                        
                        completion(true)
                    }catch{
                        print("Error")
                        completion(false)
                    }
                }
                
            default:
                print("refresh token expire--->logout")
                completion(false)
                
            }
            
        }
    }
}

extension Data{
    func getResponseDataDictionaryFromData(data: Data) -> (responseData: Dictionary<String, Any>?, error: Error?){
        do{
            let responseData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            return (responseData, nil)
        }
        catch let error{
            debugPrint( "json error: \(error.localizedDescription)")
            return (nil, error)
        }
    }
}
