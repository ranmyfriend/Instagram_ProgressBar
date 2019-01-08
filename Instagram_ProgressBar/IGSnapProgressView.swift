//
//  IGSnapProgressView.swift
//  Instagram_ProgressBar
//
//  Created by Ranjith Kumar on 10/17/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import Foundation
import UIKit

enum AnimeState:String {
    case start,resume,pause,stop,none
    var desc:String {
        switch self {
        case .start: return "Start"
        case .resume: return "Resume"
        case .pause: return "Pause"
        case .stop: return "Stop"
        case .none: return "None"
        }
    }
}

protocol ViewAnimator:class {
    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping (Bool)->())
    func resume()
    func pause()
    func stop()
}
extension ViewAnimator where Self:UIView {
    func start(with duration:TimeInterval,width:CGFloat,completion:@escaping (_ finished:Bool)->()) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.frame.size.width = width
        }) { (finished) in
            print(#function + "finished with: \(finished)")
            if finished == true {
                completion(finished)
            }
        }
    }
    func resume(){
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
        resume()
        layer.removeAllAnimations()
    }
}

class IGSnapProgressView:UIView,ViewAnimator{}
