//
//  IGSnapProgressView.swift
//  Instagram_ProgressBar
//
//  Created by Ranjith Kumar on 10/17/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

enum AnimateState:String {
    case start,play,pause,stop
    var desc:String {
        switch self {
        case .start: return "Start"
        case .play: return "Play"
        case .pause: return "Pause"
        case .stop: return "Stop"
        }
    }
}

protocol ViewAnimator:class {
    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping ()->())
    func play()
    func pause()
    func stop()
}
extension ViewAnimator where Self:UIView {
    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping ()->()) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.frame.size.width = width
        }) { (finished) in
            if finished == true {
                completion()
            }
        }
    }
    func play(){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    func pause(){
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    func stop(){
        play()
        layer.removeAllAnimations()
    }
}

class IGSnapProgressView:UIView,ViewAnimator{}
