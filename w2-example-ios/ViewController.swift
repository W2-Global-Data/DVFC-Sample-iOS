//
//  ViewController.swift
//  w2-example-ios
//  Copyright © 2020 W2 Global Data. All rights reserved.
//

import UIKit
import W2DocumentVerificationClientCapture
import W2DocumentVerificationClient
import W2FacialComparisonClient
import W2FacialComparisonClientCapture

let licenseKey = "YOUR LICENSE KEY HERE"
let clientRef = "client-reference"
class ViewController: UIViewController {

    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var message: UILabel!

    @IBAction func documentCaptureTapped(_ sender: Any) {
        message.text = "Loading..."
        do {
            let capturer = try W2DocumentVerificationClientCaptureBuilder(licenceKey: licenseKey)
                    .build()
            capturer.presentCapturePage(from: self, view: self.view, type: .Id1, delegate: self)
        } catch {
            handle(error: error)
        }
    }
    
    @IBAction func documentVerifyTapped(_ sender: Any) {
        guard let image = docImageView.image else {
            alert(message: "Capture a document before verifying")
            return
        }
        
        message.text = "Loading..."
        do {
            try W2DocumentVerificationClientBuilder(licenceKey: licenseKey)
            .build()
            .verify(clientReference: clientRef,
                    document: .passport(image)) { result in
                        switch result {
                        case .success(let data):
                            print("Success: \(data)")
                            self.message.text = "Success!"
                        case .failure(let error):
                            self.handle(error: error)
                        }
            }
        } catch {
            handle(error: error)
        }
    }
    
    @IBAction func faceCaptureTapped(_ sender: Any) {
        do {
            let capturer = try W2FacialComparisonClientCaptureBuilder(licenceKey: licenseKey).build()
            capturer.presentCapturePage(from: self, view: view, delegate: self)
        } catch {
            handle(error: error)
        }
    }
    
    @IBAction func faceVerifyTapped(_ sender: Any) {
        guard let image = faceImageView.image else {
            alert(message: "Capture a face before comparing")
            return
        }
        
        message.text = "Loading..."
        do {
            try W2FacialComparisonClientBuilder(licenceKey: licenseKey)
                .build()
                .compare(clientReference: clientRef, facial: W2Facial(currentImage: image, comparisonImage: image)) { result in
                   switch result {
                   case .success(let data):
                       print("Success: \(data)")
                       self.message.text = "Success!"
                   case .failure(let error):
                       self.handle(error: error)
                   }
               }
        } catch {
            handle(error: error)
        }
    }
    
    private func handle(error: Error) {
        message.text = "Something went wrong: \(error.localizedDescription)"
    }
    
    private func dismiss(vc: UIViewController) {
        vc.dismiss(animated: true)
        vc.view.removeFromSuperview()
    }
    
    private func alert(message: String) {
        let ac = UIAlertController(title: "Oops",
                                   message: "Capture a face before comparing",
                                   preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true)
    }
}

extension ViewController: W2FaceCaptureViewControllerDelegate {
    func faceCaptureViewController(_ faceCaptureViewController: UIViewController, onCaptured image: UIImage) {
        message.text = "Success!"
        faceImageView.image = image
        dismiss(vc: faceCaptureViewController)
    }

    func faceCaptureViewController(_ faceCaptureViewController: UIViewController, onCaptureFailed error: Error) {
        handle(error: error)
        dismiss(vc: faceCaptureViewController)
    }

    func faceCaptureViewController(_ faceCaptureViewController: UIViewController, onBackButtonPressed button: UIButton) {
        dismiss(vc: faceCaptureViewController)
    }
}

extension ViewController: W2DocumentCaptureDelegate {
    func documentCaptureViewController(_ documentCaptureViewController: UIViewController,
                                       onBackButtonPressed button: UIButton) {
        dismiss(vc: documentCaptureViewController)
    }
    
    func documentCaptureViewController(_ documentCaptureViewController: UIViewController,
                                       onCaptureFailed error: Error) {
        handle(error: error)
        dismiss(vc: documentCaptureViewController)
    }
    
    func documentCaptureViewController(_ documentCaptureViewController: UIViewController, onCaptured image: UIImage) {
        message.text = "Success!"
        docImageView.image = image
        dismiss(vc: documentCaptureViewController)
    }
}
