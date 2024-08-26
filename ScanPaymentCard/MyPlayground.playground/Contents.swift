import UIKit

struct BPCD_MBL_L005 {
    
    struct Request {
        let INQ_GB: String  // 조회구분 | 0: 전체통화,  1: 사용통화(환율고시통화),  2:기타통화
    }
    
    struct Response {
        var REC             : [REC]?
        let FX_RATE_CD      : String? // 0:매매기준율, 1:현찰매입율(살때),  2:현찰매도율(팔때), 3:전신환매입율(보낼때), 4:전신환매도율(받을때)
        let FX_RATE_INPUT_YN: String? // Y:환율직접입력가능(환율조회후 입력가능)
        
        struct REC {
            let CURR_NO : String? // 국가별 통화 (숫자코드)
            let CURR_CD : String? // 국가별 통화 (문자코드)
            let MEMO    : String? // 통화설명 (ex: 미국 달러)
            
            // Add Custom Key
            let OTHER_CURR  : String?
            let ENABLE      : String?
        }
    }
}

var l05Data = [
    BPCD_MBL_L005.Response.REC(CURR_NO: "840", CURR_CD: "USD", MEMO: "달러(USD)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "901", CURR_CD: "TWD", MEMO: "타이완달러(TWD)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "344", CURR_CD: "HKD", MEMO: "홍콩달러(HKD)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "410", CURR_CD: "KRW", MEMO: "원(KRW)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "978", CURR_CD: "EUR", MEMO: "유로(EUR)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "826", CURR_CD: "GBP", MEMO: "파운드(GBP)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "156", CURR_CD: "CNY", MEMO: "위안(CNY)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "392", CURR_CD: "JPY", MEMO: "엔(JPY)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "764", CURR_CD: "THB", MEMO: "바트(THB)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "704", CURR_CD: "VND", MEMO: "베트남동(VND)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "036", CURR_CD: "", MEMO: "호주달러(AUD)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "124", CURR_CD: "CAD", MEMO: "캐나다달러(CAD)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "356", CURR_CD: "INR", MEMO: "인도루피(INR)", OTHER_CURR: nil, ENABLE: nil),
    BPCD_MBL_L005.Response.REC(CURR_NO: "702", CURR_CD: "SGD", MEMO: "싱가폴달러(SGD)", OTHER_CURR: nil, ENABLE: nil),
    
]

print(l05Data.count)

// Define a custom sorting order for the currency codes.
// Implement a sorting function that uses this custom order to sort the array.
//
//let customOrder = ["HKD", "USD", "TWD", "KRW"]
//
//l05Data.sort { (rec1, rec2) -> Bool in
//    if let index1 = customOrder.firstIndex(of: rec1.CURR_CD ?? ""),
//       let index2 = customOrder.firstIndex(of: rec2.CURR_CD ?? "") {
//        return index1 < index2
//    } else if let index1 = customOrder.firstIndex(of: rec1.CURR_CD ?? "") {
//        return true
//    } else if let index2 = customOrder.firstIndex(of: rec2.CURR_CD ?? "") {
//        return false
//    } else {
//        return rec1.CURR_CD ?? "" < rec2.CURR_CD ?? ""
//    }
//}
//
//for rec in l05Data {
//    print("\(rec.CURR_CD ?? ""): \(rec)")
//}


// Create a sorting function
//func customSort(lhs: BPCD_MBL_L005.Response.REC, rhs: BPCD_MBL_L005.Response.REC) -> Bool {
//    let order: [String: Int] = ["HKD": 0, "USD": 1, "TWD": 2, "KRW": 3]
//    
//    if let lhsIndex = order[lhs.CURR_CD ?? ""], let rhsIndex = order[rhs.CURR_CD ?? ""] {
//        return lhsIndex < rhsIndex
//    }
//    
//    if let lhsIndex = order[lhs.CURR_CD ?? ""] {
//        return true
//    }
//    
//    if let rhsIndex = order[rhs.CURR_CD ?? ""] {
//        return false
//    }
//    
//    if lhs.CURR_CD == "EUR" {
//        return true
//    }
//    
//    if rhs.CURR_CD == "EUR" {
//        return false
//    }
//    
//    return (lhs.CURR_CD ?? "") < (rhs.CURR_CD ?? "")
//}
//
//// Sort the array
//l05Data.sort(by: customSort)
//
//// Print the sorted array
//for rec in l05Data {
//    print("\(rec.CURR_CD ?? ""): \(rec.MEMO ?? "")")
//}


// Sorting criteria
let order: [String] = ["HKD", "USD", "TWD", "KRW"]

// Sorting function
l05Data.sort { (rec1, rec2) -> Bool in
    // First check if the currencies are in the specific order list
    if let index1 = order.firstIndex(of: rec1.CURR_CD ?? ""), let index2 = order.firstIndex(of: rec2.CURR_CD ?? "") {
        return index1 < index2
    }
    // If one of them is in the order list, prioritize it
    if let index1 = order.firstIndex(of: rec1.CURR_CD ?? "") {
        return true
    }
    if let index2 = order.firstIndex(of: rec2.CURR_CD ?? "") {
        return false
    }
    // Handle the special case for INR to be last
    if rec1.CURR_CD == "" {
        return false
    }
    if rec2.CURR_CD == "" {
        return true
    }
    // For other cases, compare lexicographically
    return (rec1.CURR_CD ?? "") < (rec2.CURR_CD ?? "")
}

// Print the sorted result
for rec in l05Data {
    print("\(rec.CURR_CD ?? ""): \(rec.MEMO ?? "")")
}

