//
//  AchievmentsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/06/25.
//

import UIKit

class AchievmentsViewController: CommonViewController {

    @IBOutlet weak var badgeMBV: UIView!
    @IBOutlet weak var centerMaxsetsMBV: UIView!
    @IBOutlet weak var leftMaxsetsMBV: UIView!
    @IBOutlet weak var rightMaxsetsMBV: UIView!
    @IBOutlet weak var achievementsMBV: UIView!
    @IBOutlet weak var yourBadgesTitleLbl: UILabel!
    @IBOutlet weak var showBadgesBtn: UIButton!
    @IBOutlet weak var badgesLstTblView: UITableView!
    @IBOutlet weak var badgesLstTblHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var badgesUnlockedCountLbl: UILabel!
    @IBOutlet weak var badgesUnlockedTitleLbl: UILabel!
    @IBOutlet weak var centerMaxsetsShadowIng: UIImageView!
    @IBOutlet weak var centerBadgeImg: UIImageView!
    @IBOutlet weak var centerBadgesDateLbl: UILabel!
    @IBOutlet weak var centerMaxsetsTitleLbl: UILabel!
    @IBOutlet weak var leftMaxsetsShadowIng: UIImageView!
    @IBOutlet weak var leftBadgeImg: UIImageView!
    @IBOutlet weak var leftBadgesDateLbl: UILabel!
    @IBOutlet weak var leftMaxsetsTitleLbl: UILabel!
    @IBOutlet weak var rightMaxsetsShadowIng: UIImageView!
    @IBOutlet weak var rightBadgeImg: UIImageView!
    @IBOutlet weak var rightBadgesDateLbl: UILabel!
    @IBOutlet weak var rightMaxsetsTitleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        badgesLstTblView.register(UINib(nibName: "BadgesTableViewCell", bundle: nil), forCellReuseIdentifier: "BadgesTableViewCell")
        self.setupFont()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Achievements"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func showBadgesBtnActn(_ sender: Any) {
        print("Show all badges btn....")
    }
    
    
    private func setupFont(){
        yourBadgesTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        badgesUnlockedCountLbl.font = AppFont.semibold.size(42.0, familyName: familyClashDisplay)
        badgesUnlockedTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        
        [
            centerMaxsetsTitleLbl,
            leftMaxsetsTitleLbl,
            rightMaxsetsTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        })
        
        [
            centerBadgesDateLbl,
            leftBadgesDateLbl,
            rightBadgesDateLbl
        ].forEach({[weak self] in
            guard  self != nil else { return  }
            $0?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        })
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        badgesLstTblHeightConstrnt.constant = badgesLstTblView.contentSize.height
        view.layoutIfNeeded()
    }
    
}

//MARK: ---------------- UITABLEVIEW DELEGATE/DATASOURCE
extension AchievmentsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BadgesTableViewCell = badgesLstTblView.dequeueReusableCell(withIdentifier: "BadgesTableViewCell", for: indexPath) as! BadgesTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
