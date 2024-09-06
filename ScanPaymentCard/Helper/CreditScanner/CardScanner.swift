//
//  CardScannerExtensions.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 29/8/24.
//

import Foundation
import SharkUtils
import Vision
import CoreImage

// " RegexHandle " is ExpressibleByStringLiteral protocol that from SharkUtils Library
private let numberCheck: RegexHandle = #"""
^                   # start of string
(\d\s*){12,18}\d    # Basic for now 13 to 19 digits with possible whitespace inbetween digits
$                   # end of string
"""#

private let preferredNumberFormatCheck: RegexHandle = #"""
^                   # start of string
[4-6]\d{3}          # Basic for now 13 to 19 digits with possible whitespace inbetween digits
\s
(\d{4,}\s){1,}
\d{3,}
$                   # end of string
"""#

private let expiryCheck: RegexHandle = #"""
^                   # start of string
.*?                 # some possible stuff; handles the `\(startDate)-\(endDate)` format case
(\d{2})             # capture group for exactly 2 digits
\/                  # single /
(\d{2})             # capture group for exactly 2 digits
$                   # end of string
"""#

private let whitespaceCaptureGroupRun: RegexHandle = #"""
(\s{1,})               # capture group for 1 or more whitespace; NSRegularExpression.stringByReplacingMatches requires a capture group
"""#

private let holderCheck: RegexHandle = #"""
^                   # start of string
[A-Z']{1,24}
\.?
\s
[A-Z]
[A-Z'\s]{3,23}
\.?
$                   # end of string
"""#

private let preferredHolderPrefixCheck: RegexHandle = #"""
^                           # start of string
(MISS|MRS|MS|MR|DR|PROF)    # common title match
\.?                         # optional '.'
\s                          # single space
.*                          # other stuff
$                           # end of string
"""#

private let ignores = [
    "visa",
    "mastercard",
    "amex",
    "debit",
    "credit",
    "from",
    "end",
    "valid",
    "exp",
    "until",
    "account",
    "number",
    "sort",
    "code"
]

//MARK: - Card Scanner

/// Card Response
struct CardScannerResponse: Equatable {
    
    let number: String
    let expireDate: String?
    let holder: String?
    
    init(number: String, expireDate: String?, holder: String?) {
        self.number = number
        self.expireDate = expireDate
        self.holder = holder
    }
    
}

/// Custom Card Scanner Protocol
protocol CardScannerProtocol: AnyObject {
    var output: (CardScannerResponse?) -> Void { get set }
    var regionOfInterest: CGRect { get set }
    func read(buffer: CVPixelBuffer,orientatiobn: CGImagePropertyOrientation)
    func reset()
}

private let regionOfInterestDefault = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))

final class CardScanner: CardScannerProtocol {
    
    @ThreadSafe public var output: (CardScannerResponse?) -> Void
    @ThreadSafe public var regionOfInterest: CGRect
    private let nowInMonthsSince2000: Int
    private let writeSafe = WriteSafe()
    private var numberDigitsOnly: Item<String?> = Item(value: nil)
    private var number: Item<String?> = Item(value: nil)
    private var expiryInMonthsSince2000: Item<Int?> = Item(value: nil)
    private var holder: Item<String?> = Item(value: nil)
    private var requestsInFlight: Int = 0
    private let queue = DispatchQueue(label: "com.gymshark.cardscan.CardScanner", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    init(now: Date = Date()) {
        self._regionOfInterest = ThreadSafe(wrappedValue: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), writeSafe: self.writeSafe)
        self.nowInMonthsSince2000 = now.monthsSince2000
        self._output = ThreadSafe(wrappedValue: { _ in }, writeSafe: self.writeSafe)
    }
    
    func read(buffer: CVPixelBuffer, orientatiobn orientation: CGImagePropertyOrientation) {
        writeSafe.perform {
            guard requestsInFlight <= 1 else {
                return
            }
            requestsInFlight += 1
            
            let request = VNRecognizeTextRequest(completionHandler: weakClosure(self) { (self, request, error) in
                self.writeSafe.perform {
                    self.process(request: request, error: error)
                    self.requestsInFlight -= 1
                }
            })
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true // false is meant to be better for numbers but overall I find it better with
            request.customWords = (0...9).map { "\($0)" } + ["MISS", "MRS", "MS", "MR", "DR", "PROF"] // Not sure this helps
            request.minimumTextHeight = _regionOfInterest.unsafeValue == regionOfInterestDefault ? 0 : 0.1 // Signicantly reduces CPU load with some cards
            request.recognitionLanguages = ["en_US"]
            if #available(iOS 14.0, *) {
                // Avoid new iOS versions moving to a newer version with differnet behaviours
                request.revision = VNRecognizeTextRequestRevision2
            }
            
            let handler = VNImageRequestHandler(
                ciImage: Self.preprocess(buffer: buffer, regionOfInterest0to1: _regionOfInterest.unsafeValue),
                orientation: orientation
            )
            queue.async {
                do {
                    try handler.perform([request])
                } catch {
                    print("\(error)")
                }
            }
           
        }
    }
    
    public func reset() {
        writeSafe.perform {
            number.reset()
            numberDigitsOnly.reset()
            expiryInMonthsSince2000.reset()
            holder.reset()
            _output.unsafeValue(nil)
        }
    }
    
    private func process(request: VNRequest, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
        (request.results as? [VNRecognizedTextObservation] ?? []).forEach {
            let bounds = $0.boundingBox
            for observation in $0.topCandidates(3) {
                if let value = Self.extractNumber(observation.string, current: number.currentMatch.value ?? "") {
                    let unformatted = String(value.filter { $0.isWholeNumber })
                    if unformatted != numberDigitsOnly.currentMatch.value {
                        number.reset()
                    }
                    numberDigitsOnly.process(newValue: unformatted, observation: observation, bounds: bounds)
                    number.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
                if let value = Self.extractExpiryInMonthsSince2000(observation.string, now: nowInMonthsSince2000) {
                    expiryInMonthsSince2000.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
                /*
                 After extractExpiry: to allow "EXP 02/25" etc
                 Before extractHolder: to reduce holder false possitives
                 */
                if Self.shouldIgnore(observation.string) {
                    return
                }
                if let value = Self.extractHolder(observation.string,
                                                  current: holder.currentMatch.value ?? "",
                                                  bounds: bounds,
                                                  numberBounds: numberDigitsOnly.bounds,
                                                  expiryBounds: expiryInMonthsSince2000.bounds) {
                    holder.process(newValue: value, observation: observation, bounds: bounds)
                    return
                }
            }
        }
        guard numberDigitsOnly.currentMatch.hits > 1 else {
            return
        }
        _output.unsafeValue(
            CardScannerResponse(
                number: number.currentMatch.value ?? "",
                expireDate: expiryInMonthsSince2000.currentMatch.value.flatMap { type(of: self).format(monthsSince2000: $0) },
                holder: holder.highestRunMatch.hits > 1 ? holder.highestRunMatch.value : nil
            )
        )
    }
}


extension CardScanner {
    
    struct Match<T: Equatable>: Equatable {
        var value: T
        var hits: Int = 0
    }
    
    struct Item<T: Equatable>: Equatable {
        var confidence: Float = 0
        var currentMatch: Match<T>
        var highestRunMatch: Match<T>
        var bounds = CGRect.zero
        private let startingValue: T
        init(value: T) {
            self.startingValue = value
            self.currentMatch = .init(value: value)
            self.highestRunMatch = .init(value: value)
        }
        
        mutating func reset() {
            self = Item(value: startingValue)
        }
        
        mutating func process(newValue: T, observation: VNRecognizedText, bounds: CGRect) {
            guard observation.confidence >= 0.3, observation.confidence >= confidence else {
                self.bounds = currentMatch.value == newValue ? bounds : self.bounds
                return
            }
            currentMatch.hits = currentMatch.value != newValue ? 1 : currentMatch.hits + 1
            currentMatch.value = newValue
            if currentMatch.hits >= highestRunMatch.hits {
                highestRunMatch = currentMatch
            }
            confidence = observation.confidence
            self.bounds = bounds
        }
    }

    static func extractNumber(_ source: String, current: String) -> String? {
        // Strip consecutive whitespace but otherwise leave the formatting alone until a there is a formatter added to the UI
        let sourceHasPreferedFormat = preferredNumberFormatCheck.regex.matches(in: source).isEmpty == false
        let currentHasPreferedFormat = preferredNumberFormatCheck.regex.matches(in: current).isEmpty == false
        return numberCheck.regex.stringMatches(in: source).isEmpty == false
            && CardCheck.hasValidLuhnChecksum(source)
            && (sourceHasPreferedFormat == false && currentHasPreferedFormat) == false
            ? whitespaceCaptureGroupRun.regex.stringByReplacingMatches(in: source, options: .withoutAnchoringBounds, range: source.fullNSRange, withTemplate: " ")
            : nil
    }
    
    static func extractExpiryInMonthsSince2000(_ source: String, now: Int) -> Int? {
        let matches = expiryCheck.regex.stringMatches(in: source)
        guard matches.count == 3, let month = Int(matches[1]), let year = Int(matches[2]), 1 <= month && month <= 12  else {
            return nil
        }
        let result = month - 1 + 12 * year
        let fiveYears = 12 * 5
        return now <= result && result <= now + fiveYears  ? result : nil
    }
    
    static func extractHolder(_ source: String, current: String, bounds: CGRect, numberBounds: CGRect, expiryBounds: CGRect) -> String? {
        let sourceHasPreferedPrefix = preferredHolderPrefixCheck.regex.matches(in: source).isEmpty == false
        let currentHasPreferedPrefix = preferredHolderPrefixCheck.regex.matches(in: current).isEmpty == false
        guard
            bounds.maxY < numberBounds.minY,
            (sourceHasPreferedPrefix == false && currentHasPreferedPrefix) == false,
            (sourceHasPreferedPrefix && currentHasPreferedPrefix == false) || source.count + 3 >= current.count,
            holderCheck.regex.matches(in: source).isEmpty == false
        else {
            return nil
        }
        return source
    }
    
    static func shouldIgnore(_ source: String) -> Bool {
        let lowercase = source.lowercased().replacingOccurrences(of: " ", with: "")
        return ignores.first { lowercase.contains($0) } != nil
    }
    
    static func format(monthsSince2000: Int) -> String {
        String(format: "%02d/%02d", (monthsSince2000 % 12) + 1, monthsSince2000 / 12)
    }
    
    /// CIImage from ` import CoreImage `
    static func preprocess(buffer: CVPixelBuffer, regionOfInterest0to1: CGRect) -> CIImage {
        var cropArea = regionOfInterest0to1
        cropArea.size.height = 0.5 * cropArea.size.height // We only care about the bottom of the card
        
        let size = CVImageBufferGetDisplaySize(buffer)
        cropArea = cropArea.applying(CGAffineTransform(scaleX: size.width, y: size.height))
        
        return CIImage(cvPixelBuffer: buffer)
            .cropped(to: cropArea) // speed
//            .applyingFilter("CIPhotoEffectTonal") // accuracy; make black and white
//            .applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": 16]) // accuracy
            .applyingFilter("CILanczosScaleTransform", parameters: ["inputScale": 432 / size.width, "inputAspectRatio": 1]) // speed
    }
}
