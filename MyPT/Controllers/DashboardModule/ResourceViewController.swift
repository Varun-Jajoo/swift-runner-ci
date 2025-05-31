//
//  ResourceViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/05/25.
//

import UIKit

class ResourceViewController: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var resourceList: [ResourceModel]? = []
    
    @IBOutlet weak var resourceCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resourceCollView.isHidden = true
        resourceCollView.register(UINib(nibName: "ResourcesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ResourcesCollectionViewCell")
        
        self.getResourceApi()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Resources"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }

    
    //------------------ Delegate/ Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.numberOfRows(count: self.resourceList?.count, title: "", message: "No resources found!", messageImage: UIImage(named: "ic_search_NoResult")?.resized(to: CGSize(width: 120, height: 120)), messageImageHeight: 120, fromCenter: -20, fromTop: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resourceCell: ResourcesCollectionViewCell = resourceCollView.dequeueReusableCell(withReuseIdentifier: "ResourcesCollectionViewCell", for: indexPath) as! ResourcesCollectionViewCell
        resourceCell.stckBottomConstrnt.constant = 10.0
        resourceCell.likeBtn.isHidden = true
        resourceCell.ratingBtn.isHidden = true
        resourceCell.dot1Btn.isHidden = true
        resourceCell.dot2Btn.isHidden = true
        resourceCell.likesCountBtn.isHidden = true
        resourceCell.viewsCountBtn.isHidden = true
        
        resourceCell.bckImgView.loadImage(urlString: self.resourceList?[indexPath.row].image, placeholder: nil)
        resourceCell.resourceTitleLbl.text = self.resourceList?[indexPath.row].title
        
        return resourceCell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: ResourceDetailsViewController = ResourceDetailsViewController.instantiate(appStoryboard: .dashboard)
        vc.resourceData = self.resourceList?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 200)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}


extension ResourceViewController{
    private func getResourceApi(){
        UpcomingClassVM.getResourcesApi(inputParams: nil, completion: {[weak self] getResaultData in
            guard let self = self, let getResaultData = getResaultData else { return }
            self.resourceCollView.isHidden = false
            self.resourceList?.removeAll()
            self.resourceList?.append(contentsOf: getResaultData.data ?? [])
            if let _ = self.self.resourceList {
                self.resourceCollView.reloadData()
            }
        })
    }
}
