//
//  CameraView.swift
//  BusinessCardHolder
//

import SwiftUI
import PhotosUI

struct CameraView : UIViewControllerRepresentable {
    @Binding var image: Data
    @Binding var sourceType:UIImagePickerController.SourceType
    @Binding var isActive: Bool

    func makeCoordinator() -> Coodinator {
        return Coordinator(parent: self)
    }
      
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    class Coodinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent : CameraView
       
        init(parent : CameraView){
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if var image = info[.originalImage] as? UIImage {
                image = image.resizeImage(withPercentage: 0.1)!
                self.parent.image = image.jpegData(compressionQuality: 1.0)!
            }
            self.parent.isActive = false
        }
    }
}

extension UIImage {
    func resizeImage(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
