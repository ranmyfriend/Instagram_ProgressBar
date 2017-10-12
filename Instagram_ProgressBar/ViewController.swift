//
//  ViewController.swift
//  Instagram_ProgressBar
//
//  Created by Ranjith Kumar on 10/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

enum AnimateType:String {
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
    //if you want to know the what state Animator currently being use one AnimatorType Var in protocol :)
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

class ViewController: UIViewController {
    
    private let barCount = 5
    private var barInitial = 0
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    lazy var progressBaseView: UIView = {
        let v = UIView.init(frame: CGRect(x:0,y:0,width:view.frame.width,height:5))
        v.backgroundColor = UIColor.black
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressBaseView)
        createBars()
    }
    
    func createBars() {
        let padding:CGFloat = 8 //GUI-Padding
        let pvHeight:CGFloat = 5
        var pvX:CGFloat = padding
        //let pvY:CGFloat = (progressBaseView.frame.height/2)-pvHeight
        let pvY:CGFloat = 0
        let pvWidth = (progressBaseView.frame.width - ((CGFloat((barCount+1)) * padding)))/CGFloat(barCount)
        for i in 0..<barCount{
            let holder = UIView.init(frame: CGRect(x:pvX,y:pvY,width:pvWidth,height:pvHeight))
            holder.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            holder.tag = i+88
            progressBaseView.addSubview(holder)
            let pv = IGSnapProgressView.init(frame: CGRect(x:pvX,y:pvY,width:0,height:pvHeight))
            pv.backgroundColor = UIColor.white
            pv.tag = i+99
            progressBaseView.addSubview(pv)
            pvX = pvX + pvWidth + padding
        }
        
    }
    
    func getAnimatableView(with index:Int)->IGSnapProgressView {
        return progressBaseView.subviews.filter({v in v.tag == index+99}).first as! IGSnapProgressView
    }
    func getHolderView(with index:Int)->UIView {
        return progressBaseView.subviews.filter({v in v.tag == index+88}).first!
    }
    func nullifyAnimatableViewWidth() {
        for i in 0..<barCount{
            let v = getAnimatableView(with: i)
            v.frame.size.width = 0
            v.stop()
        }
    }
    
    @IBAction func didTapStart(_ sender: UIButton) {
        let holderView = getHolderView(with: barInitial)
        let animatableView = getAnimatableView(with: barInitial)
        if sender.titleLabel?.text == AnimateType.start.desc || sender.titleLabel?.text == AnimateType.play.desc {
            stopButton.isHidden = false
            sender.setTitle(AnimateType.pause.desc, for: .normal)
            if sender.titleLabel?.text == AnimateType.start.desc {
                animatableView.start(with: 5.0, width: holderView.frame.width, completion: {
                    self.barInitial = self.barInitial + 1
                    if self.barInitial<self.barCount {
                        DispatchQueue.main.async {
                            sender.setTitle(AnimateType.start.desc, for: .normal)
                            self.perform(#selector(self.didTapStart(_:)), with: sender, afterDelay: 0.5)
                        }
                    }else {
                        let animatableView = self.getAnimatableView(with: self.barInitial-1)
                        animatableView.stop()
                        self.barInitial = 0
                        sender.setTitle(AnimateType.start.desc, for: .normal)
                        self.stopButton.isHidden = true
                        self.nullifyAnimatableViewWidth()
                    }
                })
            }else {
                animatableView.play()
            }
        }else {
            sender.setTitle(AnimateType.play.desc, for: .normal)
            animatableView.pause()
        }
    }
    
    @IBAction func didTapStop(_ sender: UIButton) {
        barInitial = 0
        startButton.setTitle(AnimateType.start.desc, for: .normal)
        sender.isHidden = true
        self.nullifyAnimatableViewWidth()
    }
    
}


