//
//  HomePageViewModel.swift
//  MyPT
//
//  Created by Pratham Gupta on 11/02/26.
//

import Foundation


class HomepageViewModel {
    class func homepageApi(params: [String:String]?, isShowLoader:Bool = false, completion: @escaping(_ resultData: HomePageModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .homeGetContents, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(HomePageModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getStoriesApi(params: [String:String]?, isShowLoader:Bool = false, completion: @escaping(_ resultData: GetStoriesModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .homeGetStories, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetStoriesModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func checkAssessmentStatusApi(params: [String: String]?, isShowLoader: Bool = false, completion: @escaping(_ resultData: AssesmentStatusModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .checkAssesmentStatus, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(AssesmentStatusModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
//                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getGymTrainersApi(params: [String:String]?, completion: @escaping(_ resultData: GymTrainerBaseModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .getGymTrainers, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GymTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getTrainerStudiosList(params: [String:String]?, completion: @escaping(_ resultData: GymTrainerBaseModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .getTrainerStudios, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GymTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func homepageBannerApi(params: [String:String]?, isShowLoader:Bool = false, completion: @escaping(_ resultData: HomepgaeBanner?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .getBanners, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(HomepgaeBanner.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}
