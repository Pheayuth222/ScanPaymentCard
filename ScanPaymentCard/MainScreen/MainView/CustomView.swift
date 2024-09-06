//
//  CustomView.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 3/9/24.
//

import UIKit

class CustomBackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //    applyGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //    applyGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = self.layer.sublayers?.first as? CAGradientLayer {
            applyGradient(gradientLayer: gradientLayer)
        }
    }
    
    private func applyGradient(gradientLayer: CAGradientLayer) {
        gradientLayer.frame = self.bounds
        
        // Set the colors for the gradient
        gradientLayer.colors = [
            UIColor.red.cgColor,      // Start color
            UIColor.blue.cgColor      // End color
        ]
        
        // Optionally set the locations for color change
        gradientLayer.locations = [0.0, 1.0]
        
        // Optionally set the start and end points for the gradient direction
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)   // Top left
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)     // Bottom right
        
        // Add the gradient layer to the view's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
