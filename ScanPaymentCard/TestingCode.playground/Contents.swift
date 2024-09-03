import Foundation

enum CardType: String {
    case visa             = "Visa"
    case masterCard       = "MasterCard"
    case americanExpress  = "American Express"
    case discover         = "Discover"
    case dinersClub       = "Diners Club"
    case jcb              = "JCB"
    case unionPay         = "UnionPay"
    case maestro          = "Maestro"
    case unknown          = "Unknown"
}

func detectCardTypes(cardNumber: String) -> CardType {
    // Remove any non-digit characters (e.g., spaces, hyphens)
    let sanitizedCardNumber = cardNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
    
    // Visa: Starts with 4, 13 or 16 digits long
    let visaRegex = "^4[0-9]{12}(?:[0-9]{3})?$"
    
    // MasterCard: Starts with 51-55 or 2221-2720, 16 digits long
    let masterCardRegex = "^(5[1-5][0-9]{14}|2(?:2[2-9][1-9][0-9]{2}|[3-6][0-9]{4}|7[0-1][0-9]{3}|720[0-9]{2}))$"
    
    // American Express: Starts with 34 or 37, 15 digits long
    let amexRegex = "^3[47][0-9]{13}$"
    
    // Discover: Starts with 6011, 622126-622925, 644-649, or 65, 16 digits long
//    let discoverRegex = "^6(?:011|5[0-9]{2}|4[4-9][0-9]|22[1-9][0-9]{2}|22[2-8][0-9]{1}[0-9]|229[0-2][0-9]|2293[0-5])\\d{10}$"
  
    let discoverRegex = "^6(?:011|5[0-9]{2}|22[0-9]{2}|[4-9][0-9]{2})[0-9]{12}$"
    
    // Diners Club: Starts with 300-305, 36, or 38, 14 digits long
    let dinersClubRegex = "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
    
    // JCB: Starts with 3528-3589, 16 to 19 digits long
    let jcbRegex = "^(?:2131|1800|35\\d{3})\\d{11,15}$"
    
    // UnionPay: Starts with 62, 16-19 digits long
    let unionPayRegex = "^62[0-9]{14,17}$"
    
    // Maestro: Starts with 50, 56-69, 12 to 19 digits long
    let maestroRegex = "^(5[06-9][0-9]{4}|6[0-9]{5})[0-9]{0,13}$"
    
    // Check each card type
    if sanitizedCardNumber.range(of: visaRegex, options: .regularExpression) != nil {
        return .visa
    } else if sanitizedCardNumber.range(of: masterCardRegex, options: .regularExpression) != nil {
        return .masterCard
    } else if sanitizedCardNumber.range(of: amexRegex, options: .regularExpression) != nil {
        return .americanExpress
    } else if sanitizedCardNumber.range(of: discoverRegex, options: .regularExpression) != nil {
        return .discover
    } else if sanitizedCardNumber.range(of: dinersClubRegex, options: .regularExpression) != nil {
        return .dinersClub
    } else if sanitizedCardNumber.range(of: jcbRegex, options: .regularExpression) != nil {
        return .jcb
    } else if sanitizedCardNumber.range(of: unionPayRegex, options: .regularExpression) != nil {
        return .unionPay
    } else if sanitizedCardNumber.range(of: maestroRegex, options: .regularExpression) != nil {
        return .maestro
    } else {
        return .unknown
    }
}

// Example usage
//let cardNumber = "6221261234567890" // Discover
//let cardNumber = "4111 1111 1111 1111" // Visa
//let cardNumber = "6212345678901234" // UnionPay
let cardNumber = "6504 8132 6680 8926"
let cardType = detectCardTypes(cardNumber: cardNumber)

print("This card is of type: \(cardType.rawValue)")

func maskCreditCardNumber(_ cardNumber: String) -> String {
    let components = cardNumber.split(separator: " ")
    guard components.count == 4 else { return cardNumber }
    print("components \(components)")
    print("cardNumber \(cardNumber)")
    let maskedMiddle = "**** ****"
    return "\(components[0]) \(maskedMiddle) \(components[3])"
}

let maskedCardNumber = maskCreditCardNumber(cardNumber)
print(maskedCardNumber)
