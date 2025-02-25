//
//  VideoLoopingPlayer.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import Foundation
import AVFoundation

protocol LoopingPlayerProgressDelegate: AnyObject {
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float)
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool)
}

/*
 player.play()
 player.pausePlayback() //it is used to pause
 player.resumePlayback()
 */

class LoopingPlayer: AVPlayer {

    weak var progressDelegate: LoopingPlayerProgressDelegate?

    var loopCount: Double = 0
    var timer: Timer?
    var mutePlayers: Bool = false

    override init() {
        super.init()
        self.commonInit()
    }

    override init(url: URL?) {
        super.init(url: url ?? URL(fileURLWithPath: ""))
        self.commonInit()
    }

    override init(playerItem item: AVPlayerItem!) {
        super.init(playerItem: item)
        self.commonInit()
    }
    
    // Add this pause method
      func pausePlayback() {
          self.pause()  // Pauses the player
      }

      // Optional: You could also have a resume functionality if needed
      func resumePlayback() {
          self.play()  // Resumes the player
      }
    
    func commonInit() {
        self.addObserver(self, forKeyPath: "currentItem", options: .new, context: nil)
        self.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEndTimeNotification), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        if mutePlayers {
            self.volume = 0.0
        }

        NotificationCenter.default.addObserver(self, selector: #selector(mute), name: Notification.Name("MutePlayers"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unmute), name: Notification.Name("UnmutePlayers"), object: nil)
    }

    deinit {
        self.timer?.invalidate()
        self.removeObserver(self, forKeyPath: "currentItem")
        NotificationCenter.default.removeObserver(self)
    }

    @objc func mute() {
        self.volume = 0.0
    }

    @objc func unmute() {
        self.volume = 1.0
    }

    var playableDuration: CMTime {
        get {
            if let item: AnyObject = self.currentItem?.loadedTimeRanges.first {
                if let timeRange = item.timeRangeValue {
                    let playableDuration = CMTimeAdd(timeRange.start, timeRange.duration)
                    return playableDuration
                }
            }
            return CMTime.zero
        }
    }

    @objc var loadingProgress: Float {
        get {
            if (self.currentItem == nil) {
                self.timer?.invalidate()
                self.progressDelegate?.loopingPlayer(loopingPlayer: self, didFinishLoading: false)
                return 0
            }
            let playableDurationInSeconds = CMTimeGetSeconds(self.playableDuration)
            let totalDurationInSeconds = CMTimeGetSeconds(self.currentItem?.duration ?? CMTime())
            if (totalDurationInSeconds.isNormal) {
                let progress = Float(playableDurationInSeconds / totalDurationInSeconds)
                self.progressDelegate?.loopingPlayer(loopingPlayer: self, didLoad: progress)
                if (progress > 0.90) {
                    self.progressDelegate?.loopingPlayer(loopingPlayer: self, didFinishLoading: true)
                    self.timer?.invalidate()
                }
                return progress
            }
            return 0
        }
    }

    @objc func playerDidPlayToEndTimeNotification(notification: NSNotification) {
        let playerItem: AVPlayerItem = notification.object as! AVPlayerItem
        if (playerItem != self.currentItem) {
            return
        }
        self.seek(to: CMTime.zero)
        self.play()
        loopCount += 1
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem" {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getter: loadingProgress), userInfo: nil, repeats: true)
        }
    }
}
