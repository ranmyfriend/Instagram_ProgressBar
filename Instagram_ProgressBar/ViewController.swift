//
//  ViewController.swift
//  Instagram_ProgressBar
//
//  Created by Ranjith Kumar on 10/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let maxProgressorCount = 5
    private var progressInitial = 0
    private let timeInterval:TimeInterval = 5.0
    private let progressorIndicatorTag:Int = 88
    private let progressorTag:Int = 99

    var holderView:UIView {
        return getProgressIndicatorView(with: progressInitial)
    }
    var animatableView:IGSnapProgressView {
        return getProgressorView(with: progressInitial)
    }

    private var progressState:AnimeState = .none {
        didSet {
            //none->start;start->pause;pause->resume;
            //none->start;start->stop;none->start;
            switch progressState {
            case .none:
                startButton.setTitle(AnimeState.start.desc, for: .normal)
                stopButton.isHidden = true
                createProgressors()
            case .start:
                startButton.setTitle(AnimeState.pause.desc, for: .normal)
                startProgressor()
                stopButton.isHidden = false
            case .pause:
                startButton.setTitle(AnimeState.resume.desc, for: .normal)
                let animatableView = getProgressorView(with: progressInitial)
                animatableView.pause()
                stopButton.isHidden = false
            case .resume:
                startButton.setTitle(AnimeState.pause.desc, for: .normal)
                animatableView.resume()
                stopButton.isHidden = false
            case .stop:
                startButton.setTitle(AnimeState.start.desc, for: .normal)
                progressInitial = 0
                animatableView.stop()
                stopButton.isHidden = true
                nullifyProgressorsWidth()
            }
        }
    }
    
    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.borderWidth = 1.5
            startButton.layer.borderColor = startButton.tintColor?.cgColor
            startButton.layer.cornerRadius = 3.0
        }
    }
    @IBOutlet weak var stopButton: UIButton! {
        didSet {
            stopButton.layer.borderWidth = 1.5
            stopButton.layer.borderColor = stopButton.titleColor(for: .normal)?.cgColor
            stopButton.layer.cornerRadius = 3.0
        }
    }
    
    lazy var progressBaseView: UIView = {
        let v = UIView.init(frame: CGRect(x:12,y:startButton.frame.maxY-100,width:view.frame.width-(2*12),height:5))
        v.backgroundColor = UIColor.clear
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(progressBaseView)

        progressState = .none

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func willEnterForeground() {
        switch progressState {
        case .none: return
        case .start:
            if self.progressInitial < self.maxProgressorCount {
                self.progressInitial = self.progressInitial+1
                progressState = .start
            }
        case .pause:
            return
        default: break
        }
    }

    private func createProgressors() {
        let padding:CGFloat = 8 //GUI-Padding
        let height:CGFloat = 5
        var x:CGFloat = padding
        let y:CGFloat = 0
        let width = (progressBaseView.frame.width - ((CGFloat((maxProgressorCount+1)) * padding)))/CGFloat(maxProgressorCount)
        for i in 0..<maxProgressorCount{
            let progressIndicator = UIView.init(frame: CGRect(x:x,y:y,width:width,height:height))
            progressBaseView.addSubview(applyProperties(progressIndicator, with: i+progressorIndicatorTag,alpha:0.1))
            progressBaseView.addSubview(progressIndicator)
            let progressor = IGSnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            progressBaseView.addSubview(applyProperties(progressor,with: i+progressorTag))
            progressBaseView.addSubview(progressor)
            x = x + width + padding
        }
    }
    
    private func applyProperties<T:UIView>(_ view:T,with tag:Int,alpha:CGFloat = 1.0)->T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.red.withAlphaComponent(alpha)
        view.tag = tag
        return view
    }
    
    func getProgressorView(with index:Int)->IGSnapProgressView {
        return progressBaseView.subviews.filter({v in v.tag == index+99}).first as! IGSnapProgressView
    }
    func getProgressIndicatorView(with index:Int)->UIView {
        return progressBaseView.subviews.filter({v in v.tag == index+88}).first!
    }
    func nullifyProgressorsWidth() {
        for i in 0..<maxProgressorCount{
            let v = getProgressorView(with: i)
            v.frame.size.width = 0
            v.stop()
        }
    }

    private func startProgressor() {
        animatableView.start(with: 5.0, width: holderView.frame.width, completion: { [unowned self] finished in
            if self.progressInitial == self.maxProgressorCount-1 {
                self.progressState = .stop
            }else {
                self.progressInitial = self.progressInitial + 1
                self.startProgressor()
            }
        })
    }
    
    @IBAction func didTapStart(_ sender: UIButton) {
        switch progressState {
        case .none: progressState = .start
        case .start: progressState = .pause
        case .pause: progressState = .resume
        case .resume: progressState = .pause
        case .stop: progressState = .start
        }
    }
    
    @IBAction func didTapStop(_ sender: UIButton) {
        progressState = .stop
    }
    
}
