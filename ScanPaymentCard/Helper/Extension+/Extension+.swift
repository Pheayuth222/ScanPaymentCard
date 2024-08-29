//
//  Extension+.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 27/8/24.
//

import Foundation

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
