//
//  PaymentViewModel.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 6/9/24.
//

import UIKit

class PaymentViewModel {
    
    var paymentModel        : [PaymentModel] = []
    var cardTypeName        = "visa1"
    var cardResponseData    : CardScannerResponse?
    var imageRandomBackground : [String] = ["card1","card2","card3","card4","card5","card6","card7"]
    
    var numberColors : [UIColor] = [
        UIColor(white: 0.9, alpha: 1.0),  // Bright streak
        UIColor(white: 0.9, alpha: 1.0),  // Medium gray
        UIColor(white: 0.7, alpha: 1.0),  // Darker gray
        UIColor(white: 0.9, alpha: 1.0),  // Medium gray
        UIColor(white: 0.9, alpha: 1.0)   // Bright streak
    ]
    
    var imageView = UIImageView()
    
    //MARK: -
    
    func initData() {
        paymentModel = [
            
            PaymentModel(title: "Number", placeholder: "Required",responseValue: "",tag: 2024),
            PaymentModel(title: "Expires", placeholder: "MM",placeholderYYYY: "YYYY",monthValue: "", yearValue: "",tag: 2025),
            PaymentModel(title: "CVV", placeholder: "Security code",responseValue: "",tag: 2026),
            
        ]
    }
    
    func randomImageView() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(imageRandomBackground.count)))
        return imageRandomBackground[randomIndex]
    }
    
    // MARK: This function make Card Number to be "1234 **** **** 9832"
    func maskCreditCardNumber(_ cardNumber: String) -> String {
        let components = cardNumber.split(separator: " ")
        guard components.count == 4 else { return cardNumber }
        let maskedMiddle = "**** ****"
        return "\(components[0]) \(maskedMiddle) \(components[3])"
    }
    
    func checkCardTypes(cardNumbers: String) -> String {
        switch detectCardType(cardNumber: cardNumbers) {
        case .visa:       return "visa1"
        case .masterCard: return "mastercard"
        case .maestro:    return "maestro"
        case .jcb:        return "JCB"
        case .unionPay:   return "unionPay"
        case .americanExpress:  return "americanExpress"
        case .dinersClub: return "dinnersClub"
        case .discover:   return "discover"
        case .unknown:    return "Unknown Card"
        }
    }
    
}
