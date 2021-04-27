/**
    This file is part of Adguard for iOS (https://github.com/AdguardTeam/AdguardForiOS).
    Copyright © Adguard Software Limited. All rights reserved.

    Adguard for iOS is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Adguard for iOS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Adguard for iOS.  If not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

protocol StoriesProgressComponentViewDelegate: AnyObject {
    func segmentFullyFilled()
}

final class StoriesProgressComponentView: ThemableProgressView {

    weak var delegate: StoriesProgressComponentViewDelegate?
        
    private let animationDuration: Double
    
    private var animator: UIViewPropertyAnimator?

    init(animationDuration: Double) {
        self.animationDuration = animationDuration
        super.init(frame: .zero)
        
        self.lightThemeActiveColor = UIColor(hexString: "#B0B0B0")
        self.lightThemeInactiveColor = UIColor(hexString: "#D8D8D8")
        self.darkThemeActiveColor = UIColor(hexString: "#939393")
        self.darkThemeInactiveColor = UIColor(hexString: "#414141")
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.animationDuration = 0.0
        super.init(coder: coder)
        
        self.lightThemeActiveColor = UIColor(hexString: "#B0B0B0")
        self.lightThemeInactiveColor = UIColor(hexString: "#D8D8D8")
        self.darkThemeActiveColor = UIColor(hexString: "#939393")
        self.darkThemeInactiveColor = UIColor(hexString: "#414141")
        
        setupView()
    }
    
    // MARK: - Public methods
    
    func startFromBeginning() {
        animator?.stopAnimation(true)
        setProgress(0.0, animated: false)
        animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear, animations: { [weak self] in
            self?.setProgress(1.0, animated: true)
        })
        animator?.addCompletion({ [weak self] position in
            if position == .end {
                self?.delegate?.segmentFullyFilled()
            }
        })
        /*
         Hack to start animation in another run loop iteration
         Otherwise it works weirdly
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.animator?.startAnimation()
        }
    }
    
    func pause() {
        if animator?.isRunning == true {
            animator?.pausesOnCompletion = true
            animator?.pauseAnimation()
        }
    }
    
    func resume() {
        animator?.pausesOnCompletion = false
        animator?.continueAnimation(withTimingParameters: nil, durationFactor: 0.0)
    }
    
    func setFullProgress() {
        animator?.stopAnimation(true)
        animator = nil
        setProgress(1.0, animated: false)
    }
    
    func setZeroProgress() {
        animator?.stopAnimation(true)
        animator = nil
        setProgress(0.0, animated: false)
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        layer.cornerRadius = 1.0
        setProgress(0.0, animated: false)
    }
}
