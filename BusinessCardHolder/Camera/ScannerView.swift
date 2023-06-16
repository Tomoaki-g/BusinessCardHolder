//
//  ScannerView.swift
//  BusinessCardHolder
//

import SwiftUI
import UIKit
import AVFoundation

struct ScannerView: UIViewRepresentable {
    @Binding var isScanActive: Bool
    @Binding var qrCodeData: String
    
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "sessionQueue")
    let preview = UIView(frame: .init(origin: .zero, size: UIScreen.main.bounds.size))

    func makeCoordinator() -> ScannerView.Coordinator {
        return Coordinator(parent: self, previewLayer: AVCaptureVideoPreviewLayer(session: session))
    }
    
    func makeUIView(context: Context) -> UIView {
        if !session.isRunning {
            DispatchQueue.main.async {
                self.session.startRunning()
            }
        }
        
        let mainView = UIView(frame: .init(origin: .zero, size: preview.bounds.size))
        return mainView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer.frame = uiView.frame
        uiView.layer.addSublayer(context.coordinator.previewLayer)
        
        if !isScanActive {
            if session.isRunning {
                session.stopRunning()
            }
            return
        }
    }
    
    func captureSession(_ session: AVCaptureSession, didFailWithError error: Error) {
        print("Camera session failed with error: \(error)")
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {
        var parent: ScannerView
        var previewLayer: AVCaptureVideoPreviewLayer
        private let metadataOutput = AVCaptureMetadataOutput()
        private let metadataObjectQueue = DispatchQueue(label: "metadataObjectQueue")

        init(parent: ScannerView, previewLayer: AVCaptureVideoPreviewLayer) {
            self.parent = parent
            self.previewLayer = previewLayer
            super.init()
            checkCameraAuthorizationStatus(self.parent.preview)
        }
        
        private func checkCameraAuthorizationStatus(_ uiView: UIView) {
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if cameraAuthorizationStatus == .authorized {
                cameraInit()
            } else {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.sync {
                        if granted {
                            self.cameraInit()
                        }
                    }
                }
            }
        }
        
        private func cameraInit() {
            guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                print("Failed to get the camera device")
                return
            }
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.parent.session.canAddInput(videoDeviceInput) {
                    self.parent.session.addInput(videoDeviceInput)
                }
                if self.parent.session.canAddOutput(metadataOutput) {
                    self.parent.session.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectQueue)
                    metadataOutput.metadataObjectTypes = [.qr]
                }
            } catch {
                print("Failed to initialize camera: \(error)")
                self.parent.session.commitConfiguration()
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.parent.session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = .portrait
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            for metadataObject in metadataObjects {
                guard let machineReadableCode = metadataObject as? AVMetadataMachineReadableCodeObject,
                      machineReadableCode.type == .qr,
                      let stringValue = machineReadableCode.stringValue
                else {
                    return
                }
                if !self.parent.qrCodeData.contains(stringValue) {
                    self.parent.qrCodeData = stringValue
                    self.parent.isScanActive = false
                    print("The content of QR code: \(stringValue)")
                }
            }
        }
    }
}
