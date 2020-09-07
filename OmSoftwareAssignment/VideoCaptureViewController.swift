//
//  VideoCaptureViewController.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import UIKit
import MobileCoreServices
import Toast_Swift
class VideoCaptureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  , Appear {

    var controller = UIImagePickerController()
    let app = UIApplication.shared.delegate as! AppDelegate
    func open() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   
               // 2 Present UIImagePickerController to take video
            controller.sourceType = .camera
            controller.videoQuality = .typeHigh
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.videoMaximumDuration = 40
            controller.delegate = self
                   
               present(controller, animated: true, completion: nil)
           }
           else {
               print("Camera is not available")
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        open()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
       
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
        self.controller.dismiss(animated: true, completion: nil)
        
        guard
            let mediaType = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }
        
        let data = try! Data(contentsOf: url.standardizedFileURL)
        
        if Reachability.isInternetAvailable(){
            self.app.VC = self
            self.app.showLoader()
           
            self.view.makeToast("Uploading Video...")
            AFWrapper.requestWith(url: Constant.UPLOAD_VIDEO, imageData: data, parameters: ["product_video": "video.mp4"], onCompletion: {_ in
                self.app.removeLoader()
                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScrollableViewController") as! ScrollableViewController
                VC.appearDelegate = self
                self.navigationController?.pushViewController(VC, animated: false)
                
            })
        }else{
            self.view.makeToast("Internet Not Available")
        }
        
        

        // Handle a movie capture
//        UISaveVideoAtPathToSavedPhotosAlbum(
//            url.path,
//            self,
//            #selector(video(_:didFinishSavingWithError:contextInfo:)),
//            nil)
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
