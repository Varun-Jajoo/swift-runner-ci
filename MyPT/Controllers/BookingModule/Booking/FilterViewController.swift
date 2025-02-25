//
//  FilterViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/12/24.
//

import UIKit

enum flowSetupFilter {
    case filter
    case cancellationReason
    case reschedule
    case defaultFlow
}


class FilterViewController: UIViewController {

    //MARK: ---------VARIABLE
    var sectionsFilter: [SectionModel] = []
    var flowUI:flowSetupFilter = .defaultFlow 
    var navFilterCtrl:UINavigationController?
    
    //MARK: ---------IBOUTLET
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var setionTitleLbl: UILabel!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var filterDataLst: UITableView!
    @IBOutlet weak var heightFilterDataLstConstrnt: NSLayoutConstraint!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var noteBtn: UIButton!
    @IBOutlet weak var noteBtnHieghtConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                            
        self.dismissBtn.isHidden = true
        self.noteBtn.isHidden = true
        self.noteBtnHieghtConstrnt.constant = 0
       
        filterDataLst.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        filterDataLst.allowsMultipleSelection = true
        
        self.flowSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        self.setUpUI()
    }
    
    //MARK: -----------FLOW SETUP
    func flowSetup(){
        
        self.noteBtnHieghtConstrnt.constant = 0
        
        switch flowUI {
        case .filter:
            print("filter flow")
            /*
             self.dismissBtn.isHidden = true
             self.clearBtn.isHidden = false
             self.applyBtn.isHidden = false
             
             self.sectionsFilter =  [
             Section(title: "Type", items: ["Trainer Session", "Gym Session"]),
             Section(title: "Location", items: ["Home", "MyPT Studio"]),
             Section(title: "Status", items: ["All", "Upcoming", "Completed", "Cancelled"])
             ]
             self.filterDataLst.reloadData()
             */
            
        case .cancellationReason:
            print("cancellationReason flow")
            self.dismissBtn.isHidden = false
            self.clearBtn.isHidden = true
            self.applyBtn.isHidden = false
            
            self.noteBtnHieghtConstrnt.constant = 40
            self.noteBtn.isHidden = false
            self.noteBtn.setTitle("We won’t be charging you a cancellation fee", for: .normal)
            self.noteBtn.setImage(UIImage(named: "ic_dobNote"), for: .normal)
            
            self.applyBtn.backgroundColor = UIColor.appDarkGray
            self.applyBtn.setTitle("CANCEL BOOKING", for: .normal)
            self.applyBtn.isUserInteractionEnabled = false
            self.applyBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.topTitleLbl.text = "Reason For Cancellation"
            
            self.sectionsFilter =  [
                SectionModel(title: "", items: ["Schedule Conflict",
                                           "Feeling Unwell",
                                           "Unexpected Personal Commitment",
                                           "Change of Plans"
                                          ]
                       )
            ]
            self.filterDataLst.reloadData()
            
        case .reschedule:
            self.dismissBtn.isHidden = false
            self.clearBtn.isHidden = true
            self.applyBtn.isHidden = false
            
            self.applyBtn.backgroundColor = UIColor.appDarkGray
            self.applyBtn.setTitle("CANCEL BOOKING", for: .normal)
            self.applyBtn.isUserInteractionEnabled = false
            self.applyBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.topTitleLbl.text = "Reason For Cancellation"
            
            self.sectionsFilter =  [
                SectionModel(title: "", items: ["Change in Availability",
                                           "Health or Injury Concerns",
                                           "Unexpected Travel Plans",
                                           "Personal Emergency"
                                          ]
                       )
            ]
            self.filterDataLst.allowsMultipleSelection = false
            self.filterDataLst.reloadData()
            
        case .defaultFlow:
            print("filter flow")
            //bcz of this flow allready have
            
            self.dismissBtn.isHidden = true
            self.clearBtn.isHidden = false
            self.applyBtn.isHidden = false
            self.topTitleLbl.text = "Filter"
            
            self.sectionsFilter =  [
                SectionModel(title: "Type", items: ["Trainer Session", "Gym Session"]),
                SectionModel(title: "Location", items: ["Home", "MyPT Studio"]),
                SectionModel(title: "Status", items: ["All", "Upcoming", "Completed", "Cancelled"])
            ]
            self.filterDataLst.reloadData()
        }
       
    }
    
    func setUpUI(){
        self.topTitleLbl.font = AppFont.semibold.size(18, familyName: familyManrope)
        self.noteBtn.titleLabel?.font = AppFont.regular.size(12, familyName: familyManrope)
        self.clearBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.applyBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.noteBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.clearBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            
            self.applyBtn.setCornerRadius(borderWidth: 0.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
   
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let vcHeight = (self.view.frame.size.height*0.6)
        
        heightFilterDataLstConstrnt.constant = filterDataLst.contentSize.height < vcHeight ? filterDataLst.contentSize.height : vcHeight
        self.view.layoutIfNeeded()
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 2101 {
            print("top bar clicked")
        }
        else if sender.tag == 2102{
            print("clear btn clicked")
        }
        else if sender.tag == 2103{
            
            switch flowUI {
            case .filter:
                print("filter is called")
            case .cancellationReason:
                print("cancellationReason is called")
                
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("bookingCancelled"), object: "Data from bookingCancelled")
                })
                
            case .reschedule:
                self.dismiss(animated: true, completion: {
                    let vc:CalendarPopViewController = CalendarPopViewController.instantiate(appStoryboard: .booking)
                    vc.modalPresentationStyle = .automatic
                    vc.navCtrl = self.navFilterCtrl
                    self.navFilterCtrl?.present(vc, animated: true)
                })
                
            case .defaultFlow:
                self.dismiss(animated: true)
                print("deaflut is called")
            }
        }
        else{
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let location = touch.location(in: view)
//                  if !self.filterDataLst.frame.contains(location) {
//                      self.dismiss(animated: true, completion: nil)
//                  }else{
//                      print("tap at popup view.")
//                  }
//        }
//    }
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsFilter.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsFilter[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PointsTableViewCell = filterDataLst.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
        cell.leftImgView.image = nil
        
        DispatchQueue.main.async {
            cell.leftImgView.setCornerRadius(borderWidth: 1.2, borderColor: UIColor.appWhite, cornerRadious: 3.0)
        }
        
        cell.titleLbl.text = sectionsFilter[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
        
        selectedCell.leftImgView.image = UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate)
        selectedCell.leftImgView.tintColor = UIColor.appWhite
        
        //-------------***********
        switch flowUI {
        case .filter:
            print("filter flow")
        case .reschedule:
            self.applyBtn.backgroundColor = UIColor.appWhite
            self.applyBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.applyBtn.isUserInteractionEnabled = true
            
        case .cancellationReason:
            self.applyBtn.backgroundColor = UIColor.appWhite
            self.applyBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.applyBtn.isUserInteractionEnabled = true
        case .defaultFlow:
            print("noe of these")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
        deSelectedCell.leftImgView.image = nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        hView.backgroundColor = .clear
        let label = UILabel()
        label.frame = CGRect.init(x: 1, y: 1, width: hView.frame.width-2, height: hView.frame.height-2)
        label.text = sectionsFilter[section].title
        label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        label.textColor = UIColor.txtDarkGray
        
        hView.addSubview(label)
        
        if sectionsFilter[section].title == "" {
            hView.frame.size.height = 1.0
        }
        
        return  hView
    }
    
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].title
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if sectionsFilter[section].title == "" {
            return 1 // or some non-zero value
        }else{
            return 30 // or some non-zero value
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}


