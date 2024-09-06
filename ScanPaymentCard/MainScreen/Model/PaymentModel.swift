//
//  PaymentModel.swift
//  ScanPaymentCard
//
//  Created by YuthFight's MacBook Pro  on 1/9/24.
//

import Foundation

//enum SECTION_TYPE: String, CaseIterable {
//    case PaymentMethod
//    case CardInfo
//}
//
//struct Container<T> {
//    let value : T?
//    let sectionType: SECTION_TYPE
//}

struct PaymentModel {
    let title           : String?
    var placeholder     : String?
    var placeholderYYYY : String?
    var responseValue   : String?
    var monthValue      : String?
    var yearValue       : String?
    var tag             : Int?
  
    init(title: String?, placeholder: String? = nil, placeholderYYYY: String? = nil, responseValue: String? = nil, monthValue: String? = nil, yearValue: String? = nil, tag: Int? = nil) {
        self.title = title
        self.placeholder = placeholder
        self.placeholderYYYY = placeholderYYYY
        self.responseValue = responseValue
        self.monthValue = monthValue
        self.yearValue = yearValue
        self.tag = tag
    }
  
}


