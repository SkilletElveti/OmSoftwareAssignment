//
//  VideoCaptureViewController.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import UIKit
import MobileCoreServices

class VideoCaptureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate   {

    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   
               // 2 Present UIImagePickerController to take video
               controller.sourceType = .camera
               controller.mediaTypes = [kUTTypeMovie as String]
            controller.videoMaximumDuration = 40
               controller.delegate = self
                   
               present(controller, animated: true, completion: nil)
           }
           else {
               print("Camera is not available")
           }
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        guard
            let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }

        // Handle a movie capture
        UISaveVideoAtPathToSavedPhotosAlbum(
            url.path,
            self,
            #selector(video(_:didFinishSavingWithError:contextInfo:)),
            nil)
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
