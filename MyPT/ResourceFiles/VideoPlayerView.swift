//
//  VideoPlayerView.swift
//  MyPT
//
//  Created by techsaga corp on 15/03/25.
//

import UIKit
import Foundation
import AVFoundation

class PlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
}

//protocol VideoPlayerDelegate: AnyObject {
//    func downloadedProgress(progress: Double)
//    func readyToPlay()
//    func didUpdateProgress(progress: Double)
//    func didFinishPlayItem()
//    func didFailPlayToEnd()
//}

protocol VideoPlayerDelegate: AnyObject {
    func downloadedProgress(progress: Double)
    func readyToPlay()
    func didUpdateProgress(progress: Double)
    func didFinishPlayItem()
    func didFailPlayToEnd()
}

class VideoPlayer: NSObject {

    private var assetPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var urlAsset: AVURLAsset?
    private var videoOutput: AVPlayerItemVideoOutput?
    
    private var assetDuration: Double = 0
    private weak var playerView: PlayerView?

    private var autoRepeatPlay: Bool = true
    private var autoPlay: Bool = true

    weak var delegate: VideoPlayerDelegate?

    var playerRate: Float = 1 {
        didSet { assetPlayer?.rate = playerRate > 0 ? playerRate : 0.0 }
    }

    var volume: Float = 1.0 {
        didSet { assetPlayer?.volume = volume > 0 ? volume : 0.0 }
    }

    // Use `withUnsafeMutableBytes` for KVO context
    private var videoContextIn = 0
    private var videoContext: UnsafeMutableRawPointer?

    override init() {
        super.init()
        
        // Ensure the pointer remains valid for the object's lifetime
        withUnsafeMutableBytes(of: &videoContextIn) { pointer in
            videoContext = pointer.baseAddress
        }
    }

    // MARK: - Initialization

    convenience init(urlAsset: NSURL, view: PlayerView, startAutoPlay: Bool = true, repeatAfterEnd: Bool = true) {
        self.init()
        self.playerView = view
        self.autoPlay = startAutoPlay
        self.autoRepeatPlay = repeatAfterEnd

        if let playerLayer = view.layer as? AVPlayerLayer {
            playerLayer.videoGravity = .resizeAspectFill
        }

        initialSetupWithURL(url: urlAsset)
        prepareToPlay()
    }

    // MARK: - Public Methods

    func isPlaying() -> Bool {
        return assetPlayer?.rate ?? 0 > 0
    }

    func seekToPosition(seconds: Float64) {
        guard let player = assetPlayer, let timeScale = player.currentItem?.asset.duration.timescale else { return }
        
        pause()
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: timeScale)) { [weak self] _ in
            self?.play()
        }
    }

    func pause() {
        assetPlayer?.pause()
    }

    func play() {
        guard let player = assetPlayer, player.currentItem?.status == .readyToPlay else { return }
        player.play()
        player.rate = playerRate
    }

    func cleanUp() {
        if let item = playerItem {
            item.removeObserver(self, forKeyPath: "status", context: videoContext)
            item.removeObserver(self, forKeyPath: "loadedTimeRanges", context: videoContext)
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)

        assetPlayer?.replaceCurrentItem(with: nil)
        assetPlayer = nil
        playerItem = nil
        urlAsset = nil
    }

    // MARK: - Private Methods

    private func prepareToPlay() {
        let keys = ["tracks"]
        urlAsset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.main.async {
                self?.startLoading()
            }
        }
    }

    private func startLoading() {
        guard let asset = urlAsset else { return }
        
        var error: NSError?
        let status = asset.statusOfValue(forKey: "tracks", error: &error)

        if status == .loaded {
            assetDuration = CMTimeGetSeconds(asset.duration)
            let videoOutputOptions: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            ]

            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputOptions)
            playerItem = AVPlayerItem(asset: asset)

            if let item = playerItem {
                item.addObserver(self, forKeyPath: "status", options: .initial, context: videoContext)
                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: videoContext)

                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)
                NotificationCenter.default.addObserver(self, selector: #selector(didFailedToPlayToEnd), name: .AVPlayerItemFailedToPlayToEndTime, object: item)

                if let output = videoOutput {
                    item.add(output)
                    item.audioTimePitchAlgorithm = .varispeed
                    assetPlayer = AVPlayer(playerItem: item)

                    assetPlayer?.rate = playerRate
                    addPeriodicalObserver()

                    if let layer = playerView?.playerLayer {
                        layer.player = assetPlayer
                    }
                }
            }
        }
    }

    private func addPeriodicalObserver() {
        let timeInterval = CMTime(seconds: 1, preferredTimescale: 1)
        assetPlayer?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            self?.playerDidChangeTime(time: time)
        }
    }

    private func playerDidChangeTime(time: CMTime) {
        let timeNow = CMTimeGetSeconds(time)
        let progress = assetDuration == 0 ? 0.0 : timeNow / assetDuration
        delegate?.didUpdateProgress(progress: progress)
    }

    @objc private func playerItemDidReachEnd() {
        delegate?.didFinishPlayItem()

        if autoRepeatPlay {
            assetPlayer?.seek(to: .zero)
            play()
        }
    }

    @objc private func didFailedToPlayToEnd() {
        delegate?.didFailPlayToEnd()
    }

    private func playerDidChangeStatus(status: AVPlayer.Status) {
        if status == .failed {
            print("Failed to load video")
        } else if status == .readyToPlay {
            volume = assetPlayer?.volume ?? 1.0
            delegate?.readyToPlay()

            if autoPlay && assetPlayer?.rate == 0.0 {
                play()
            }
        }
    }

    private func moviewPlayerLoadedTimeRangeDidUpdated(ranges: [NSValue]) {
        let maximum = ranges
            .map { CMTimeGetSeconds($0.timeRangeValue.start) + CMTimeGetSeconds($0.timeRangeValue.duration) }
            .max() ?? 0

        let progress = assetDuration == 0 ? 0.0 : maximum / assetDuration
        delegate?.downloadedProgress(progress: progress)
    }

    deinit {
        cleanUp()
    }

    private func initialSetupWithURL(url: NSURL) {
        let options: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        urlAsset = AVURLAsset(url: url as URL, options: options)
    }
}


//class VideoPlayer: NSObject {
//
//    private var assetPlayer: AVPlayer?
//    private var playerItem: AVPlayerItem?
//    private var urlAsset: AVURLAsset?
//    private var videoOutput: AVPlayerItemVideoOutput?
//    
//    private var assetDuration: Double = 0
//    private weak var playerView: PlayerView?
//
//    private var autoRepeatPlay: Bool = true
//    private var autoPlay: Bool = true
//
//    weak var delegate: VideoPlayerDelegate?
//
//    var playerRate: Float = 1 {
//        didSet { assetPlayer?.rate = playerRate > 0 ? playerRate : 0.0 }
//    }
//
//    var volume: Float = 1.0 {
//        didSet { assetPlayer?.volume = volume > 0 ? volume : 0.0 }
//    }
//
//    // ✅ Fix: Use instance property for KVO context
//    private var videoContext = 0
////    private var videoContextPointer: UnsafeMutableRawPointer {
////        return UnsafeMutableRawPointer(&videoContext)
////    }
//    
//    private var videoContextPointer: UnsafeMutableRawPointer {
//        return UnsafeMutableRawPointer(&videoContext)
//    }
//
//    // MARK: - Initialization
//
//    convenience init(urlAsset: NSURL, view: PlayerView, startAutoPlay: Bool = true, repeatAfterEnd: Bool = true) {
//        self.init()
//        self.playerView = view
//        self.autoPlay = startAutoPlay
//        self.autoRepeatPlay = repeatAfterEnd
//
//        if let playerLayer = view.layer as? AVPlayerLayer {
//            playerLayer.videoGravity = .resizeAspectFill
//        }
//
//        initialSetupWithURL(url: urlAsset)
//        prepareToPlay()
//    }
//
//    override init() {
//        super.init()
//    }
//
//    // MARK: - Public Methods
//
//    func isPlaying() -> Bool {
//        return assetPlayer?.rate ?? 0 > 0
//    }
//
//    func seekToPosition(seconds: Float64) {
//        guard let player = assetPlayer, let timeScale = player.currentItem?.asset.duration.timescale else { return }
//        
//        pause()
//        player.seek(to: CMTime(seconds: seconds, preferredTimescale: timeScale)) { [weak self] _ in
//            self?.play()
//        }
//    }
//
//    func pause() {
//        assetPlayer?.pause()
//    }
//
//    func play() {
//        guard let player = assetPlayer, player.currentItem?.status == .readyToPlay else { return }
//        player.play()
//        player.rate = playerRate
//    }
//
//    func cleanUp() {
//        if let item = playerItem {
//            item.removeObserver(self, forKeyPath: "status", context: videoContextPointer)
//            item.removeObserver(self, forKeyPath: "loadedTimeRanges", context: videoContextPointer)
//        }
//        
//        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
//
//        assetPlayer?.replaceCurrentItem(with: nil)
//        assetPlayer = nil
//        playerItem = nil
//        urlAsset = nil
//    }
//
//    // MARK: - Private Methods
//
//    private func prepareToPlay() {
//        let keys = ["tracks"]
//        urlAsset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
//            DispatchQueue.main.async {
//                self?.startLoading()
//            }
//        }
//    }
//
//    private func startLoading() {
//        guard let asset = urlAsset else { return }
//        
//        var error: NSError?
//        let status = asset.statusOfValue(forKey: "tracks", error: &error)
//
//        if status == .loaded {
//            assetDuration = CMTimeGetSeconds(asset.duration)
//            let videoOutputOptions: [String: Any] = [
//                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
//            ]
//
//            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputOptions)
//            playerItem = AVPlayerItem(asset: asset)
//
//            if let item = playerItem {
//                item.addObserver(self, forKeyPath: "status", options: .initial, context: videoContextPointer)
//                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: videoContextPointer)
//
//                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)
//                NotificationCenter.default.addObserver(self, selector: #selector(didFailedToPlayToEnd), name: .AVPlayerItemFailedToPlayToEndTime, object: item)
//
//                if let output = videoOutput {
//                    item.add(output)
//                    item.audioTimePitchAlgorithm = .varispeed
//                    assetPlayer = AVPlayer(playerItem: item)
//
//                    assetPlayer?.rate = playerRate
//                    addPeriodicalObserver()
//
//                    if let layer = playerView?.playerLayer {
//                        layer.player = assetPlayer
//                    }
//                }
//            }
//        }
//    }
//
//    private func addPeriodicalObserver() {
//        let timeInterval = CMTime(seconds: 1, preferredTimescale: 1)
//        assetPlayer?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
//            self?.playerDidChangeTime(time: time)
//        }
//    }
//
//    private func playerDidChangeTime(time: CMTime) {
//        let timeNow = CMTimeGetSeconds(time)
//        let progress = assetDuration == 0 ? 0.0 : timeNow / assetDuration
//        delegate?.didUpdateProgress(progress: progress)
//    }
//
//    @objc private func playerItemDidReachEnd() {
//        delegate?.didFinishPlayItem()
//
//        if autoRepeatPlay {
//            assetPlayer?.seek(to: .zero)
//            play()
//        }
//    }
//
//    @objc private func didFailedToPlayToEnd() {
//        delegate?.didFailPlayToEnd()
//    }
//
//    private func playerDidChangeStatus(status: AVPlayer.Status) {
//        if status == .failed {
//            print("Failed to load video")
//        } else if status == .readyToPlay {
//            volume = assetPlayer?.volume ?? 1.0
//            delegate?.readyToPlay()
//
//            if autoPlay && assetPlayer?.rate == 0.0 {
//                play()
//            }
//        }
//    }
//
//    private func moviewPlayerLoadedTimeRangeDidUpdated(ranges: [NSValue]) {
//        let maximum = ranges
//            .map { CMTimeGetSeconds($0.timeRangeValue.start) + CMTimeGetSeconds($0.timeRangeValue.duration) }
//            .max() ?? 0
//
//        let progress = assetDuration == 0 ? 0.0 : maximum / assetDuration
//        delegate?.downloadedProgress(progress: progress)
//    }
//
//    deinit {
//        cleanUp()
//    }
//
//    private func initialSetupWithURL(url: NSURL) {
//        let options: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
//        urlAsset = AVURLAsset(url: url as URL, options: options)
//    }
//}


/*
class PlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
}

protocol VideoPlayerDelegate: AnyObject {
    func downloadedProgress(progress: Double)
    func readyToPlay()
    func didUpdateProgress(progress: Double)
    func didFinishPlayItem()
    func didFailPlayToEnd()
}

//private let videoContext = UnsafeMutableRawPointer(mutating: "VideoPlayerContext")

private var videoContextIn = 0
private var videoContext: UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(&videoContextIn)
}

class VideoPlayer: NSObject {

    private var assetPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var urlAsset: AVURLAsset?
    private var videoOutput: AVPlayerItemVideoOutput?
    
    private var assetDuration: Double = 0
    private weak var playerView: PlayerView?

    private var autoRepeatPlay: Bool = true
    private var autoPlay: Bool = true

    weak var delegate: VideoPlayerDelegate?

    var playerRate: Float = 1 {
        didSet { assetPlayer?.rate = playerRate > 0 ? playerRate : 0.0 }
    }

    var volume: Float = 1.0 {
        didSet { assetPlayer?.volume = volume > 0 ? volume : 0.0 }
    }

    // MARK: - Init

    convenience init(urlAsset: NSURL, view: PlayerView, startAutoPlay: Bool = true, repeatAfterEnd: Bool = true) {
        self.init()
        self.playerView = view
        self.autoPlay = startAutoPlay
        self.autoRepeatPlay = repeatAfterEnd

        if let playerLayer = view.layer as? AVPlayerLayer {
            playerLayer.videoGravity = .resizeAspectFill
        }

        initialSetupWithURL(url: urlAsset)
        prepareToPlay()
    }

    override init() {
        super.init()
    }

    // MARK: - Public Methods

    func isPlaying() -> Bool {
        return assetPlayer?.rate ?? 0 > 0
    }

    func seekToPosition(seconds: Float64) {
        guard let player = assetPlayer, let timeScale = player.currentItem?.asset.duration.timescale else { return }
        
        pause()
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: timeScale)) { [weak self] _ in
            self?.play()
        }
    }

    func pause() {
        assetPlayer?.pause()
    }

    func play() {
        guard let player = assetPlayer, player.currentItem?.status == .readyToPlay else { return }
        player.play()
        player.rate = playerRate
    }

    func cleanUp() {
        if let item = playerItem {
            item.removeObserver(self, forKeyPath: "status", context: videoContext)
            item.removeObserver(self, forKeyPath: "loadedTimeRanges", context: videoContext)
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)

        assetPlayer?.replaceCurrentItem(with: nil)
        assetPlayer = nil
        playerItem = nil
        urlAsset = nil
    }

    // MARK: - Private Methods

    private func prepareToPlay() {
        let keys = ["tracks"]
        urlAsset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.main.async {
                self?.startLoading()
            }
        }
    }

    private func startLoading() {
        guard let asset = urlAsset else { return }
        
        var error: NSError?
        let status = asset.statusOfValue(forKey: "tracks", error: &error)

        if status == .loaded {
            assetDuration = CMTimeGetSeconds(asset.duration)
            let videoOutputOptions: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
            ]

            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputOptions)
            playerItem = AVPlayerItem(asset: asset)

            if let item = playerItem {
                item.addObserver(self, forKeyPath: "status", options: .initial, context: videoContext)
                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: videoContext)

                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)
                NotificationCenter.default.addObserver(self, selector: #selector(didFailedToPlayToEnd), name: .AVPlayerItemFailedToPlayToEndTime, object: item)

                if let output = videoOutput {
                    item.add(output)
                    item.audioTimePitchAlgorithm = .varispeed
                    assetPlayer = AVPlayer(playerItem: item)

                    assetPlayer?.rate = playerRate
                    addPeriodicalObserver()

                    if let layer = playerView?.layer as? AVPlayerLayer {
                        layer.player = assetPlayer
                    }
                }
            }
        }
    }

    private func addPeriodicalObserver() {
        let timeInterval = CMTime(seconds: 1, preferredTimescale: 1)
        assetPlayer?.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            self?.playerDidChangeTime(time: time)
        }
    }

    private func playerDidChangeTime(time: CMTime) {
        let timeNow = CMTimeGetSeconds(time)
        let progress = assetDuration == 0 ? 0.0 : timeNow / assetDuration
        delegate?.didUpdateProgress(progress: progress)
    }

    @objc private func playerItemDidReachEnd() {
        delegate?.didFinishPlayItem()

        if autoRepeatPlay {
            assetPlayer?.seek(to: .zero)
            play()
        }
    }

    @objc private func didFailedToPlayToEnd() {
        delegate?.didFailPlayToEnd()
    }

    private func playerDidChangeStatus(status: AVPlayer.Status) {
        if status == .failed {
            print("Failed to load video")
        } else if status == .readyToPlay {
            volume = assetPlayer?.volume ?? 1.0
            delegate?.readyToPlay()

            if autoPlay && assetPlayer?.rate == 0.0 {
                play()
            }
        }
    }

    private func moviewPlayerLoadedTimeRangeDidUpdated(ranges: [NSValue]) {
        let maximum = ranges
            .map { CMTimeGetSeconds($0.timeRangeValue.start) + CMTimeGetSeconds($0.timeRangeValue.duration) }
            .max() ?? 0

        let progress = assetDuration == 0 ? 0.0 : maximum / assetDuration
        delegate?.downloadedProgress(progress: progress)
    }

    deinit {
        cleanUp()
    }

    private func initialSetupWithURL(url: NSURL) {
        let options: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        urlAsset = AVURLAsset(url: url as URL, options: options)
    }

    // MARK: - Observations
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == videoContext, let keyPath = keyPath, let item = object as? AVPlayerItem, item == playerItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == "status", let player = assetPlayer {
            playerDidChangeStatus(status: player.status)
        } else if keyPath == "loadedTimeRanges" {
            moviewPlayerLoadedTimeRangeDidUpdated(ranges: item.loadedTimeRanges)
        }
    }
}
*/
