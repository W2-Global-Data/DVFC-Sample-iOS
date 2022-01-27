//
//  ViewController.swift
//  w2-example-ios
//  Copyright © 2021 W2 Global Data. All rights reserved.
//

import UIKit
import W2DocumentVerificationClientCapture
import W2DocumentVerificationClient
import W2FacialComparisonClient
import W2FacialComparisonClientCapture

let licenseKey = "Your-License-Key"
let clientRef = "client-reference-ios"
let apiKey = "Your-Api-Key"
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
    
    @IBAction func documentClassifyAndVerifyTapped(_ sender: Any) {
        guard let image = docImageView.image else {
            alert(message: "Capture a document before verifying")
            return
        }
        
        message.text = "Loading..."
        do {
            try W2DocumentVerificationClientBuilder(licenceKey: licenseKey)
            .build()
            .classifyAndVerify(clientReference: clientRef, autoVerify: true,
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
    
    @IBAction func documentVerifyUsingRestEndpoint(_ sender: Any) {
        guard let image = docImageView.image else {
            alert(message: "Capture a document before verifying")
            return
        }
        
        message.text = "Loading..."
        do {
            let url = URL(string: "https://api.w2globaldata.com/document-verification/verify?api-version=1.5")
            
            let boundary = UUID().uuidString
            
            let utf8ApiKey = apiKey.data(using: .utf8)
            let base64encodedApiKey = utf8ApiKey?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            var urlRequest = URLRequest(url: url!)
            
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("Basic " + base64encodedApiKey!, forHTTPHeaderField: "Authorization")
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            
            
            var data = Data()
            
            let pagesParam = "Pages"
            let fileName = "image.jpg"
            let mimeType = "image/jpg"
            let documentTypeParam = "DocumentType"
            let documentTypeValue = "ID3"
            let clientReferenceParam = "ClientReference"
            
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(documentTypeParam)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(documentTypeValue)\r\n".data(using: .utf8)!)
            
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(clientReferenceParam)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(clientRef)\r\n".data(using: .utf8)!)
            
            
            
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(pagesParam)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            data.append(image.jpegData(compressionQuality: 1.0)!)

            
            data.append("\r\n".data(using: .utf8)!)
            
            
            data.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            urlRequest.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            
            
            urlRequest.httpBody = data
            
            urlRequest.timeoutInterval = 120.0
            
            
            let session = URLSession.shared
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let response = response {
                    let urlResponseHttp = response as! HTTPURLResponse
                    DispatchQueue.main.async {
                        if (200...299).contains(urlResponseHttp.statusCode){
                            self.message.text = "Success - Rest Endpoint!"
                        }
                    }
                    print(response)
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        DispatchQueue.main.async {
                            self.message.text = "Something went wrong: \(error.localizedDescription)"
                        }
                        print(error)
                    }
                }
            }.resume()
            
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
