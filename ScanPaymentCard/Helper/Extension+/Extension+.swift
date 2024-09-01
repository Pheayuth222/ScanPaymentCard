//
//  Extension+.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 27/8/24.
//

import Foundation
import UIKit

// Card Check

extension Int {
    var isOdd: Bool {
        (self & 1) == 1
    }
}

struct CardCheck {
    private init () {}
    
    static func hasValidLuhnChecksum(_ text: String) -> Bool {
        var digits = text.compactMap { $0.wholeNumberValue }
        guard let checksum = digits.popLast(), digits.count > 8 else {
            return false
        }
        let sum = digits.reversed().enumerated().reduce(0) { (total, value) in
            let preCapValue = value.element * (value.offset.isOdd ? 1 : 2 )
            return total + (preCapValue > 9 ? preCapValue - 9 : preCapValue)
        }
        return (sum * 9) % 10 == checksum
    }
}

extension UILabel {
  
  func dropShadowLabel() {
    
//    self.textColor = .white

    // Set the shadow properties
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 1, height: 1)
    self.layer.shadowRadius = 0.8
  }
  
}

extension UIView {
  func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
      let gradientLayer = CAGradientLayer()
      gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
      gradientLayer.locations = [0, 1]
      gradientLayer.frame = bounds

     layer.insertSublayer(gradientLayer, at: 0)
  }
}
