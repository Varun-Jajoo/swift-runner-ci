//
//  TrainerListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit
import AVFoundation

class TrainerListTableViewCell: UITableViewCell {

    //MARK: -------------VARIABLE
    var trainerTagsData:[TrainerTagModel]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                guard trainerTagsData.count > 0 else { return }
                restrictedRange = [0...trainerTagsData.count - 1]
                self.gymCategoryCollView.reloadData()
            }
        }
    }
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    private var playWorkItem: DispatchWorkItem?

    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
//    var selectTrainerCallBack: (() -> Void)?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var btnSelectTrainer: UIButton!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var numOfRatingLbl: UILabel!
    @IBOutlet weak var viewDetailsBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var landMarkLbl: UILabel!
    @IBOutlet weak var btnMute: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gymCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.setupUI()
        self.setupFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        playWorkItem?.cancel()

        NotificationCenter.default.removeObserver(self)

        player?.pause()
        player?.seek(to: .zero)
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil

        trainerImgView.isHidden = false
        btnMute.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let playerLayer = playerLayer {
            playerLayer.frame = containerView.bounds
        }
    }
    
    @objc func videoFailed() {
        trainerImgView.isHidden = false
        btnMute.isHidden = true
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
    }

    private func setupUI() {
        self.viewDetailsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(hex: "#343534"), cornerRadious: 8.0)
        DispatchQueue.main.async {
            self.trainerImgView.addGradientImgV(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
//            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            self.cellMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.btnSelectTrainer.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerImgView.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    // MARK: -------------SET CELL INPUTDATA
    func setCellData(trainerData: TrainerModel?, indexPath: IndexPath) {
        guard let trainerData = trainerData else { return  }
        
        self.btnSelectTrainer.backgroundColor = UIColor.appWhite
        self.btnSelectTrainer.setTitleColor(UIColor.mainBg, for: .normal)
        
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
        self.gymNameLbl.text = trainerData.name
        self.btnSelectTrainer.setTitle(trainerData.isPackage ?? false ? "BOOK THE SLOT" : "SELECT THIS TRAINER", for: .normal)
        self.landMarkLbl.text = trainerData.location
        self.distanceLbl.text = trainerData.distance
        self.ratingLbl.text = "\(trainerData.averageRating?.doubleValue ?? 0.0)"
        self.numOfRatingLbl.text = trainerData.noOfRating ?? "0" + "ratings"
        
        // Always reset first (important for reuse)
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        trainerImgView.isHidden = false
        btnMute.isHidden = true

        if let videoUrl = trainerData.trainWithMe,
           !videoUrl.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = URL(string: videoUrl) {

            // Create player
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player?.isMuted = true
            btnMute.isSelected = false
            player?.actionAtItemEnd = .none

            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = containerView.bounds

            if let layer = playerLayer {
                containerView.layer.insertSublayer(layer, at: 0)
            }

            // 🔥 Video failed observer
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(videoFailed),
                name: .AVPlayerItemFailedToPlayToEndTime,
                object: item
            )

            // 🔥 Loop from beginning when finished
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }

        } else {
            trainerImgView.isHidden = false
            btnMute.isHidden = true
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    //MARK: -------------SET CELL INPUTDATA
    func setGymCellData(trainerData: GymTrainerModel?, indexPath: IndexPath) {
        guard let trainerData = trainerData else { return  }
        
        self.btnSelectTrainer.backgroundColor = UIColor.appWhite
        self.btnSelectTrainer.setTitleColor(UIColor.mainBg, for: .normal)
        self.btnSelectTrainer.setTitle(trainerData.isPackage ?? false ? "BOOK THE SLOT" : "SELECT THIS TRAINER", for: .normal)
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
        self.gymNameLbl.text = trainerData.name
        self.landMarkLbl.text = trainerData.location
        self.ratingLbl.text = "\(trainerData.averageRating?.doubleValue ?? 0.0)"
        self.numOfRatingLbl.text = trainerData.noOfRating ?? "0" + " ratings"
        self.distanceLbl.text = trainerData.distance
        // Always reset first (important for reuse)
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        trainerImgView.isHidden = false
        btnMute.isHidden = true

        if let videoUrl = trainerData.trainWithMe,
           !videoUrl.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = URL(string: videoUrl) {

            // Create player
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player?.isMuted = true
            btnMute.isSelected = false
            player?.actionAtItemEnd = .none

            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = containerView.bounds

            if let layer = playerLayer {
                containerView.layer.insertSublayer(layer, at: 0)
            }

            // 🔥 Video failed observer
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(videoFailed),
                name: .AVPlayerItemFailedToPlayToEndTime,
                object: item
            )

            // 🔥 Loop from beginning when finished
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }

        } else {
            trainerImgView.isHidden = false
            btnMute.isHidden = true
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
    }
    
    
    private func setupFont() {
        viewDetailsBtn.titleLabel?.font = AppFont.medium.size(14, familyName: familyFunnelSans)
        btnSelectTrainer.titleLabel?.font = AppFont.medium.size(14, familyName: familyFunnelSans)
        ratingLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        numOfRatingLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        gymNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        landMarkLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        distanceLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
    }
    
    func playVideoAfterDelay() {

        guard let player = player else { return }

        // pehle previous delay cancel karo
        playWorkItem?.cancel()

        trainerImgView.isHidden = false
        btnMute.isHidden = true

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let player = self.player,
                  self.window != nil else { return }

            self.trainerImgView.isHidden = true
            self.btnMute.isHidden = false
            player.play()
        }

        playWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

    func stopVideo() {

        // 🔥 delay cancel
        playWorkItem?.cancel()

        guard let player = player else { return }

        player.pause()
        player.seek(to: .zero)
    }
    
    @IBAction func onTapSelectTrainer(_ sender: UIButton) {
//        self.selectTrainerCallBack?()
    }
    
    @IBAction func btnMuteTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.setImage(UIImage(named: sender.isSelected ? "unmuteIcon" : "muteIcon"), for: .normal)

        if sender.isSelected {
            player?.isMuted = false   // unmute
        } else {
            player?.isMuted = true    // mute
        }
    }
    
}
//MARK: ------------UICOLLECIONVIEW DATASOURCE/DELEGATE
extension TrainerListTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerTagsData?.count, totalCount > 3 {
            return 4
        } else {
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        }
        cell.titleLblTopConstrnt.constant = 7.5
        
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 3) {
            cell.titleLbl.text = "+3"
        } else {
            cell.titleLbl.text = trainerTagsData?[indexPath.row].name?.uppercased() as? String
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        return !restrictedRange.contains { $0.contains(indexPath.item) }
    }
}
