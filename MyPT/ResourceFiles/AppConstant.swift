//
//  AppConstant.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit

let appSceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

enum AssetsColor {
   case mainBgColor
   case appDarkGray
    case appBorderColor
    case appLightGray
    case txtDarkGray
    case trackLineColor
    case appYellow
    case appLigthYellow
    case appGreen
    case appOrange
}

enum AssetsMultiColor {
    case gradientColor
    case redGradientColor
    case borderGradientColor
    case stepsConnect
    case stepsDiconnect
    case blueGradient
    case lineVGradient
    case lightGreen
    case magentaGradient
    case topBottomGradient
    case cynGradient
}


extension UIColor {

    static func appColor(_ name: AssetsColor) -> UIColor? {
        switch name {
        case .mainBgColor:
            return UIColor(named: "MainBgColor")
        case .appDarkGray:
            return UIColor(named: "appDarkGray")
        case .appBorderColor:
            return UIColor(named: "appBorderColor")
        case .appLightGray:
            return UIColor(named: "appLightGray")
        case .txtDarkGray:
           return UIColor(named: "txtDarkGray")
        case .trackLineColor:
            return UIColor(red: 249.0/255.0, green: 199.0/255.0, blue: 141.0/255.0, alpha: 1.0)
        case .appYellow:
            return UIColor(named: "appYellow")
        case .appGreen:
            return UIColor(red: 112.0/255.0, green: 201.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        case .appOrange:
            return UIColor(red: 244.0/255.0, green: 109.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        case .appLigthYellow:
            return UIColor(named: "appLightYellow")
        }
    }
    
    static func appMultiColor(_ name: AssetsMultiColor) -> [UIColor] {
        switch name {
        case .gradientColor:
            return [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)]
        case .redGradientColor:
            return [UIColor(red: 31.0/255.0, green: 15.0/255.0, blue:  9.0/255.0, alpha: 1.0), UIColor(red: 96.0/255.0, green: 73.0/255.0, blue: 71.0/255.0, alpha: 1.0)]
        case .borderGradientColor:
            return [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)]
        case .stepsConnect:
            return [UIColor(red: 122.0/255.0, green: 122.0/255.0, blue: 219.0/255.0, alpha: 1.0),UIColor(red: 23.0/255.0, green: 14.0/255.0, blue: 19.0/255.0, alpha: 1.0)]
        case .stepsDiconnect:
            return [UIColor(red: 103.0/255.0, green: 48.0/255.0, blue: 76.0/255.0, alpha: 1.0),UIColor(red: 23.0/255.0, green: 14.0/255.0, blue: 18.0/255.0, alpha: 1.0)]
        case .blueGradient:
            return [UIColor(red: 0/255.0, green: 184.0/255.0, blue: 251.0/255.0, alpha: 1.0),UIColor(red: 0/255.0, green: 79.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
       
        case .lineVGradient:
            return [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0)]
        case .lightGreen:
            return [UIColor(red: 153.0/255.0, green: 219.0/255.0, blue: 122.0/255.0, alpha: 1),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 16.0/255.0, green: 23.0/255.0, blue: 14.0/255.0, alpha: 1.0)]
        case .magentaGradient:
            return [UIColor(red: 0.0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 0.0), UIColor(red: 84.0/255.0, green: 41.0/255.0, blue: 86.0/255.0, alpha: 1.0), UIColor(red: 0.0/255.0, green: 5.0/255.0, blue: 2.0/255.0, alpha: 0.0)]
        case .topBottomGradient:
            return [UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0.0),UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0), UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0.0)]
        case .cynGradient:
            return [UIColor(red: 29.0/255.0, green: 80.0/255.0, blue: 169.0/255.0, alpha: 1.0),UIColor(red: 125.0/255.0, green: 176.0/255.0, blue: 248.0/255.0, alpha: 1.0), UIColor(red: 26.0/255.0, green: 77.0/255.0, blue: 166.0/255.0, alpha: 0.0)]
        }
    }
}


//MARK: -------------- FOR SYSTEM IMAGE
public struct AppImages {
    
    public static let navLeft = UIImage(named: "ic_navLeft")
    public static let backarrow = UIImage(named: "ic_back_arrow")
    public static let arrow_right = UIImage(named: "ic_arrow_right")
    public static let editOtp = UIImage(named: "ic_editOtp")
    public static let help = UIImage(named: "ic_help")
    public static let follow = UIImage(named: "ic_follow")
    public static let shareGymWorkout = UIImage(named: "ic_shareGymWorkout")
    
    public static let ratingStar = UIImage(named: "ic_ratingStar")
   
    
    //MARK: ---------------BOOOK TRAINER
    public static let gym_workout_selected = UIImage(named: "ic_gym_workout_selected")
    public static let gym_workout = UIImage(named: "ic_gym_workout")
    public static let Home_workout_selected = UIImage(named: "ic_Home_workout_selected")
    public static let Home_workout = UIImage(named: "ic_Home_workout")
    
    public static let one_to_one_Selected = UIImage(named: "ic_one_to_one_Selected")
    public static let one_to_one = UIImage(named: "ic_one_to_one")
    public static let withBuddy_selected = UIImage(named: "ic_withBuddy_selected")
    public static let withBuddy = UIImage(named: "ic_withBuddy")
    public static let withGroup_selected = UIImage(named: "ic_withGroup_selected")
    public static let withGroup = UIImage(named: "ic_withGroup")
    
    
    
    //MARK: -----------------Bottom tabbar
    public static let bookings = UIImage(named: "ic_bookings")
    public static let bookingSelected = UIImage(named: "ic_bookingSelected")
    public static let calendar = UIImage(named: "ic_calendar")
    public static let calendarSelected = UIImage(named: "ic_calendarSelected")
    public static let home = UIImage(named: "ic_home")
    public static let homeSelected = UIImage(named: "ic_homeSelected")
    public static let Library = UIImage(named: "ic_Library")
    public static let LibrarySelected = UIImage(named: "ic_LibrarySelected")
    public static let more = UIImage(named: "ic_more")
    public static let moreSelected = UIImage(named: "ic_moreSelected")
    public static let sunny_mode = UIImage(named: "ic_sunny_mode")
    public static let night_mode = UIImage(named: "ic_night_mode")
    public static let arrow_left = UIImage(named: "ic_arrow_left")
   
    public static let moreSettings = UIImage(named: "ic_moreSettings")
    public static let sosActive = UIImage(named: "ic_sosActive")
    
    //------------------ *********************Goals
    public static let flexibilityMobility = UIImage(named: "ic_Flexibility_Mobility")
    public static let flexibilityMobility_selected = UIImage(named: "ic_Flexibility_Mobility_selected")
    public static let goalsOthers = UIImage(named: "ic_goalsOthers")
    public static let goalsOthers_Selected = UIImage(named: "ic_goalsOthers_Selected")
    public static let holisticFitness = UIImage(named: "ic_Holistic_Fitness")
    public static let holisticFitness_selected = UIImage(named: "ic_Holistic_Fitness_selected")
    public static let improvedCVEndurance = UIImage(named: "ic_Improved_Endurance")
    public static let improvedCVEndurance_selected = UIImage(named: "ic_Improved_Endurance_selected")
    public static let mentalHealth = UIImage(named: "ic_Mental_Health")
    public static let mentalHealth_selected = UIImage(named: "ic_Mental_Health_selected")
    public static let muscleBuilding = UIImage(named: "ic_Muscle_Building")
    public static let muscleBuilding_selected = UIImage(named: "ic_Muscle_Building_selected")
    public static let sportsConditioning = UIImage(named: "ic_Sports_Conditioning")
    public static let sportsConditioning_selected = UIImage(named: "ic_Sports_Conditioning_selected")
    public static let weightLoss = UIImage(named: "ic_Weight_Loss")
    public static let weightLoss_selected = UIImage(named: "ic_Weight_Loss_selected")

    //------------------ *********************Preferences
    public static let byMyself = UIImage(named: "ic_Myself")
    public static let byMyself_selected = UIImage(named: "ic_Myself_selected")
    public static let dontKnowYet = UIImage(named: "ic_Dont_Know_Yet")
    public static let dontKnowYet_selected = UIImage(named: "ic_Dont_Know_Yet_selected")
    public static let groupSession = UIImage(named: "ic_Group_Session")
    public static let groupSession_selected = UIImage(named: "ic_Group_Session_selected")
    public static let personalTrainer = UIImage(named: "ic_Personal_Trainer")
    public static let personalTrainer_selected = UIImage(named: "ic_Personal_Trainer_selected")
    
    //------------------ *********************Gender
    public static let othersGender = UIImage(named: "ic_0thersGender")
    public static let othersGender_selected = UIImage(named: "ic_0thersGender_selected")
    public static let female = UIImage(named: "ic_female")
    public static let female_selected = UIImage(named: "ic_female_selected")
    public static let male = UIImage(named: "ic_male")
    public static let male_selected = UIImage(named: "ic_male_selected")
    
    //------------------ *********************Personalized
    public static let Boost_Esteem = UIImage(named: "ic_Boost_Esteem")
    public static let Boost_Esteem_selected = UIImage(named: "ic_Boost_Esteem_selected")
    public static let Chronic_illness_Care = UIImage(named: "ic_Chronic_illness_Care")
    public static let Chronic_illness_Care_selected = UIImage(named: "ic_Chronic_illness_Care_selected")
    public static let Health_Fitness_selected = UIImage(named: "ic_Health_Fitness_selected")
    public static let Health_Fitness = UIImage(named: "ic_Health_Fitness")
    public static let Others_Presonalized = UIImage(named: "ic_Others_Presonalized")
    public static let Others_Presonalized_selected = UIImage(named: "ic_Others_Presonalized_selected")
    public static let Preparing_event_selected = UIImage(named: "ic_Preparing_event_selected")
    public static let Preparing_event = UIImage(named: "ic_Preparing_event")
    public static let Weight_Management_Selected = UIImage(named: "ic_Weight_Management_Selected")
    public static let Weight_Management = UIImage(named: "ic_Weight_Management")
    
    //------------------ *********************Others
    public static let Location = UIImage(named: "ic_Location")
    public static let Navigation = UIImage(named: "ic_Navigation")
    public static let Radius = UIImage(named: "ic_Radius")
    public static let search_normal = UIImage(named: "ic_search_normal")
    
    //------------------ *********************Dashboard
    public static let book_Trainer = UIImage(named: "ic_Book_Trainer")
    public static let Workout = UIImage(named: "ic_Di_Workout")
    public static let gym_Pass = UIImage(named: "ic_Gym_Pass")
    public static let plan_Your_Workout = UIImage(named: "ic_Plan_Your_Workout")
    public static let sessions = UIImage(named: "ic_Sessions")
    public static let chooseLocation = UIImage(named: "ic_chooseLocation")
    public static let forward = UIImage(named: "ic_forward")
    public static let notification = UIImage(named: "ic_notification")
    public static let notificationCount = UIImage(named: "ic_notificationCount")
    
    //------------------Create trainer
    public static let gymWorkout = UIImage(named: "ic_gymWorkout")
    public static let homeWorkout = UIImage(named: "ic_homeWorkout")
    public static let grid = UIImage(named: "ic_grid")
    public static let menuNav = UIImage(named: "ic_menuNav")
    public static let personal_workout = UIImage(named: "ic_person_workout")
    public static let trainer_atGym = UIImage(named: "ic_trainer_atGym")
    public static let trainer_AtHome = UIImage(named: "ic_trainer_AtHome")
    
    //-------------------More options
    public static let cart_more = UIImage(named: "ic_cart_more")
    public static let chats = UIImage(named: "ic_chats")
    public static let find_gym = UIImage(named: "ic_find_gym")
    public static let help_support = UIImage(named: "ic_help_support")
    public static let myBookings_more = UIImage(named: "ic_myBookings_more")
    public static let MyFavourite_Workouts = UIImage(named: "ic_MyFavourite_Workouts")
    public static let MyHealth_Stats = UIImage(named: "ic_MyHealth_Stats")
    public static let MyMilestone = UIImage(named: "ic_MyMilestone")
    public static let Payment_History = UIImage(named: "ic_Payment_History")
    public static let shop_more = UIImage(named: "ic_shop_more")
    public static let WorkoutLibrary_more = UIImage(named: "ic_WorkoutLibrary_more")
    public static let myGoals = UIImage(named: "ic_myGoals")
    public static let noSessions_my_Orders = UIImage(named: "ic_noSessions")
    public static let settings_more = UIImage(named: "ic_settings_more")
    public static let profile_more = UIImage(named: "ic_profile_more")
    public static let find_trainer = UIImage(named: "ic_find_trainer")
    public static let trainer_more = UIImage(named: "ic_trainer_more")
    public static let meals_more = UIImage(named: "ic_meals_more")
    
}

//MARK: -------------- FONT
public let familyClashDisplay          = "ClashDisplay"
public let familyManrope               = "Manrope"
public let familyOverpass              = "Overpass"
public let familyClashDisplayVariable  = "ClashDisplayVariable"


enum AppFont: String {
    case regular           = "Regular"
    case light             = "Light"
    case Extralight        = "Extralight"
    case ExtraLightItalic  = "ExtraLightItalic"
    case lightItalic       = "LightItalic"
    case mediumItalic      = "MediumItalic"
    case semiboldItalic    = "SemiboldItalic"
    case medium            = "Medium"
    case bold              = "Bold"
    case semibold          = "Semibold"
    case ExtraBold         = "ExtraBold"
    case boldItalic        = "BoldItalic"
    case SemiBoldItalic    = "SemiBoldItalic"
    case ExtraBoldItalic   = "ExtraBoldItalic"
    case BoldRegular       = "Bold_Regular"
    case BoldExtralight    = "Bold_Extralight"
    case BoldLight         = "Bold_Light"
    case BoldMedium        = "Bold_Medium"
    case regularItalic     = "RegularItalic"
    case thin              = "Thin"
    case thinItalic        = "ThinItalic"
    case Italic            = "Italic"
    case Heavy             = "Heavy"
    case HeavyItalic       = "HeavyItalic"
    case black             = "Black"
    case blackItalic       = "BlackItalic"
    
    
    func size(_ size: CGFloat, familyName: String) -> UIFont {
        if let font = UIFont(name: "\(familyName)-\(self.rawValue)", size: size) {
            return font
        }
        fatalError("Font '\(familyName)-\(self.rawValue)' does not exist.")
    }
    
}



