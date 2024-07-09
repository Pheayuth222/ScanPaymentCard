//
//  ViewController.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 8/7/24.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
    }
    
    private func setUpCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }


}

extension ViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: requestOptions)
        
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func handleDetectedText(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else { continue }
            
            let detectedText = bestCandidate.string
            print("Detected text: \(detectedText)")
            
            if let cardNumber = detectCardNumber(from: detectedText) {
                print("Card Number: \(cardNumber)")
            }
            
            if let expirationDate = detectExpirationDate(from: detectedText) {
                print("Expiration Date: \(expirationDate)")
            }
            
            if let cardholderName = detectCardholderName(from: detectedText) {
                print("Cardholder Name: \(cardholderName)")
            }
        }
    }

    func detectCardNumber(from text: String) -> String? {
        let cardNumberPattern = "\\b(?:\\d[ -]*?){13,16}\\b"
        let regex = try? NSRegularExpression(pattern: cardNumberPattern, options: [])
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            return String(text[range])
        }
        return nil
    }

    func detectExpirationDate(from text: String) -> String? {
        let expirationDatePattern = "\\b(0[1-9]|1[0-2])/([0-9]{2})\\b"
        let regex = try? NSRegularExpression(pattern: expirationDatePattern, options: [])
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            return String(text[range])
        }
        return nil
    }

    func detectCardholderName(from text: String) -> String? {
        // This is a bit tricky as names can vary widely.
        // You may need a predefined list of names or a more sophisticated approach.
        print("Text :: ",text)
        return text
    }

    
}
