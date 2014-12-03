//
//  SwiftWebViewProgressView.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/04.
//  Copyright (c) 2014年 MokuMokuCloud. All rights reserved.
//

import UIKit

class WebViewProgressView: UIView {
    
    var progress: Float = 0.0
    var progressBarView: UIView!
    var barAnimationDuration: NSTimeInterval!
    var fadeAnimationDuration: NSTimeInterval!
    var fadeOutDelay: NSTimeInterval!
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    // MARK: Private Method
    private func configureViews() {
        self.userInteractionEnabled = false
        self.autoresizingMask = .FlexibleWidth
        progressBarView = UIView(frame: self.bounds)
        progressBarView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        var tintColor = UIColor(red: 22/255, green: 126/255, blue: 251/255, alpha: 1.0)
        if let color = UIApplication.sharedApplication().delegate?.window??.tintColor {
            tintColor = color
        }
        progressBarView.backgroundColor = tintColor
        self.addSubview(progressBarView)
        
        barAnimationDuration = 0.1
        fadeAnimationDuration = 0.27
        fadeOutDelay = 0.1
    }
    
    // MARK: Public Method
    func setProgress(progress: Float, animated: Bool = false) {
        var isGrowing = progress > 0.0
        UIView.animateWithDuration((isGrowing && animated) ? barAnimationDuration : 0.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            var frame = self.progressBarView.frame
            frame.size.width = CGFloat(progress) * self.bounds.size.width
            self.progressBarView.frame = frame
        }, completion: nil)
        
        if progress >= 1.0 {
            UIView.animateWithDuration(animated ? fadeAnimationDuration : 0.0, delay: fadeOutDelay, options: .CurveEaseInOut, animations: {
                self.progressBarView.alpha = 0.0
                }, completion: {
                    completed in
                    var frame = self.progressBarView.frame
                    frame.size.width = 0
                    self.progressBarView.frame = frame
            })
        } else {
            UIView.animateWithDuration(animated ? fadeAnimationDuration : 0.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.progressBarView.alpha = 1.0
            }, completion: nil)
        }
    }
}
