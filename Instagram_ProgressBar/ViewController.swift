//
//  ViewController.swift
//  Instagram_ProgressBar
//
//  Created by Ranjith Kumar on 10/12/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let progressorCount = 5
    private var progressInitial = 0
    private let timeInterval:TimeInterval = 5.0
    private let progressorIndicatorTag:Int = 88
    private let progressorTag:Int = 99
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(startProgressor), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        createProgressors()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func startProgressor() {
        let progressorIndicatorView = getProgressIndicatorView(with: progressInitial)
        let progressorView = getProgressorView(with: progressInitial)
        progressorView.start(with: timeInterval, width: progressorIndicatorView.frame.width) {
            self.progressInitial = self.progressInitial + 1
            if self.progressInitial<self.progressorCount {
                DispatchQueue.main.async {
                    self.startButton.setTitle(AnimateState.start.desc, for: .normal)
                    self.perform(#selector(self.didTapStart(_:)), with: self.startButton, afterDelay: 0.5)
                }
            }else {
                let animatableView = self.getProgressorView(with: self.progressInitial-1)
                animatableView.stop()
                self.progressInitial = 0
                self.startButton.setTitle(AnimateState.start.desc, for: .normal)
                self.stopButton.isHidden = true
                self.nullifyProgressorsWidth()
            }
        }
    }
    
    private func createProgressors() {
        let padding:CGFloat = 8 //GUI-Padding
        let height:CGFloat = 5
        var x:CGFloat = padding
        let y:CGFloat = 0
        let width = (progressBaseView.frame.width - ((CGFloat((progressorCount+1)) * padding)))/CGFloat(progressorCount)
        for i in 0..<progressorCount{
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
        for i in 0..<progressorCount{
            let v = getProgressorView(with: i)
            v.frame.size.width = 0
            v.stop()
        }
    }
    
    @IBAction func didTapStart(_ sender: UIButton) {
        let holderView = getProgressIndicatorView(with: progressInitial)
        let animatableView = getProgressorView(with: progressInitial)
        if sender.titleLabel?.text == AnimateState.start.desc || sender.titleLabel?.text == AnimateState.play.desc {
            stopButton.isHidden = false
            sender.setTitle(AnimateState.pause.desc, for: .normal)
            if sender.titleLabel?.text == AnimateState.start.desc {
                animatableView.start(with: 5.0, width: holderView.frame.width, completion: {
                    self.startProgressor()
                })
            }else {
                animatableView.play()
            }
        }else {
            sender.setTitle(AnimateState.play.desc, for: .normal)
            animatableView.pause()
        }
    }
    
    @IBAction func didTapStop(_ sender: UIButton) {
        progressInitial = 0
        startButton.setTitle(AnimateState.start.desc, for: .normal)
        sender.isHidden = true
        self.nullifyProgressorsWidth()
    }
    
}
