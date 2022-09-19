//
//  PhPicker.swift
//  helloSwift
//
//  Created by corkine on 2022/9/19.
//

import Foundation
import SwiftUI
import PhotosUI

extension PHPickerViewController {
    struct View {
        @Binding var image: Image?
        @Binding var showing: Bool
    }
}

extension PHPickerViewController.View: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: .init())
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    class Coordinator: PHPickerViewControllerDelegate {
        let parent: PHPickerViewController.View
        init(_ parent: PHPickerViewController.View) {
            self.parent = parent
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self){ [self]
                        (newImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            if let img = newImage as? UIImage {
                                print("Select image \(img.hashValue)")
                                parent.image = SwiftUI.Image.init(uiImage: img)
                            }
                        }
                    }
                } else {
                    print("Can't load, non UIImage")
                }
            }
            parent.showing = false
        }
    }
}
