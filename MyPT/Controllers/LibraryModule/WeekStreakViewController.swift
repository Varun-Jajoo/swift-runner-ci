//
//  WeekStreakViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class WeekStreakViewController: UIViewController {
    
    //MAKR: ----------------- VARIABLE
    var dayStreaksData: UserDayStreakDataModel?
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var weekStreakMBV: UIView!
    @IBOutlet weak var weekStreakImgView: UIImageView!
    @IBOutlet weak var streakPodiumImgView: UIImageView!
    @IBOutlet weak var weekStreakTitleLbl: UILabel!
    @IBOutlet weak var weekStreakDescLbl: UILabel!
    @IBOutlet weak var dayStreakLbl: UILabel!
    @IBOutlet weak var dayStreakContainerV: UIView!
    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var sunSubMBV: UIView!
    @IBOutlet weak var monSubMBV: UIView!
    @IBOutlet weak var tuesSubMBV: UIView!
    @IBOutlet weak var wedSubMBV: UIView!
    @IBOutlet weak var thuSubMBV: UIView!
    @IBOutlet weak var friSubMBV: UIView!
    @IBOutlet weak var satSubMBV: UIView!
    @IBOutlet weak var sunImgView: UIImageView!
    @IBOutlet weak var monImgView: UIImageView!
    @IBOutlet weak var tuesImgView: UIImageView!
    @IBOutlet weak var wedImgView: UIImageView!
    @IBOutlet weak var thuImgView: UIImageView!
    @IBOutlet weak var friImgView: UIImageView!
    @IBOutlet weak var satImgView: UIImageView!
    @IBOutlet weak var sunTitleLbl: UILabel!
    @IBOutlet weak var monTitleLbl: UILabel!
    @IBOutlet weak var tuesTitleLbl: UILabel!
    @IBOutlet weak var wedTitleLbl: UILabel!
    @IBOutlet weak var thuTitleLbl: UILabel!
    @IBOutlet weak var friTitleLbl: UILabel!
    @IBOutlet weak var satTitleLbl: UILabel!
    @IBOutlet weak var sunCountLbl: UILabel!
    @IBOutlet weak var monCountLbl: UILabel!
    @IBOutlet weak var tuesCountLbl: UILabel!
    @IBOutlet weak var wedCountLbl: UILabel!
    @IBOutlet weak var thuCountLbl: UILabel!
    @IBOutlet weak var friCountLbl: UILabel!
    @IBOutlet weak var satCountLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var dayStreakNoteLbl: UILabel!
    @IBOutlet weak var streakTopCountBtn: UIButton!
    @IBOutlet weak var proceedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupFont()
        self.setupAnimation()
        self.setInputData()
        self.getDayStreak()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func proceedBtnActn(_ sender: Any) {
        let vc:BadgeEarnedViewController = BadgeEarnedViewController.instantiate(appStoryboard: .library)
        vc.badgeDayStreaksData = self.dayStreaksData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupAnimation(){
        self.weekStreakMBV.animShow(duration: 0.7, delay: 0.1) {
            print("anomation done..")
        }
        self.weekStreakTitleLbl.animShow(duration: 0.4, delay: 0.1){
            print("anomation done..")
        }
        
        self.weekStreakDescLbl.animShow(duration: 0.4, delay: 0.1){
            print("anomation done..")
        }
        
        self.dayStreakLbl.animShow(duration: 0.3, delay: 0.1){
            print("anomation done..")
        }
        
        self.dayStreakContainerV.animShow(duration: 0.7, delay: 0.2) {
            print("anomation done..")
        }
        
        self.calendarMBV.animShow(duration: 0.7, delay: 0.2) {
            print("anomation done..")
        }
        self.proceedBtn.animShow(duration: 0.7, delay: 0.2) {
            print("anomation done..")
        }
    }
    
    private func setInputData(){
        self.streakTopCountBtn.setTitle(dayStreaksData?.weekNumber?.value, for: .normal)
        self.weekStreakDescLbl.text = dayStreaksData?.message?.value
        
        let daysImgView: [UIImageView?] = [
            sunImgView, monImgView, tuesImgView,
            wedImgView, thuImgView, friImgView, satImgView
        ]
        
        let dayIndexMap = ["sun": 0, "mon": 1, "tue": 2, "wed": 3, "thu": 4, "fri": 5, "sat": 6]
                
        (dayStreaksData?.weekDays ?? []).forEach { dayStreak in
            guard let day = dayStreak.day?.value?.lowercased(),
                  let index = dayIndexMap[day],
                  let imgView = daysImgView[index],
                  let status = dayStreak.status?.value?.lowercased() else { return }

            if status == "completed" {
                imgView.image = UIImage(named: "ic_checkDay")
            } else if ["today_pending", "not_started", "upcoming"].contains(status) {
                imgView.image = UIImage(named: "ic_circle_gray")
            } else if status == "missed" {
                imgView.image = UIImage(named: "ic_circle_heck_red")
            }
        }
        
        /*
        (dayStreaksData?.weekDays ?? []).forEach { dayStreak in
            guard let day = dayStreak.day?.value?.lowercased(),
                  let index = dayIndexMap[day],
                  let imgView = daysImgView[index] else { return }
            
            imgView.image = UIImage(named: (dayStreak.completed ?? false) ? "ic_checkDay" : "ic_circle_heck_red")
        }
        */
        
        /*
         "status" = "completed" = "green" "ic_checkDay"
         "status" = "today_pending" = "grey" "ic_circle_gray"
         "status" = "not_started" = "grey"
         "status" = "upcoming" = "grey"
         "status" = "missed" = "red" "ic_circle_heck_red"
         */

    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            
            self.calendarMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            
            self.dayStreakContainerV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20)
            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            //            self.calendarMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 20.0)
            
            self.calendarMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 20.0)
            
            
            [self.sunSubMBV,
             self.monSubMBV,
             self.tuesSubMBV,
             self.wedSubMBV,
             self.thuSubMBV,
             self.friSubMBV,
             self.satSubMBV].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            })
            
            self.lineLbl.backgroundColor = UIColor.txtDarkGray //UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
            self.proceedBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        //-------------------------------
        self.weekStreakTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.weekStreakDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.dayStreakLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
        [self.sunTitleLbl,self.monTitleLbl, self.tuesTitleLbl, self.wedTitleLbl, self.thuTitleLbl, self.friTitleLbl, self.satTitleLbl].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [self.sunCountLbl, self.monCountLbl, self.tuesCountLbl, self.wedCountLbl, self.thuCountLbl, self.friCountLbl, self.satCountLbl].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        self.dayStreakNoteLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.streakTopCountBtn.titleLabel?.font = AppFont.semibold.size(123.0, familyName: familyClashDisplay)
        self.proceedBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
    
}

extension WeekStreakViewController{
    private func getDayStreak(){
        WorkoutLibraryVM.getUserStreakApi(completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            print("getResultData: ", getResultData)
            self.dayStreaksData = getResultData.data
            self.setInputData()
        })
    }
}
