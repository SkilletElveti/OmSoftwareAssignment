//
//  Utils.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import Foundation
import UIKit
import SystemConfiguration
import Alamofire
import SwiftyJSON


@IBDesignable
class CardViewGrad: UIView {
    
    @IBInspectable var CornerRadiusCard: CGFloat = 5
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.9
    
    override func layoutSubviews() {
        layer.cornerRadius = CornerRadiusCard
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadiusCard)
        layer.masksToBounds = false
        //layer.borderColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0).cgColor
        //layer.borderWidth = 1
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    func RoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor(red: 0.65, green: 0.89, blue: 1.00, alpha: 1.00).cgColor, UIColor(red: 0.06, green: 0.38, blue: 0.52, alpha: 1.00).cgColor]
    }

}

class Reachability {
    
    class func isInternetAvailable() -> Bool{
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    class func getIP()-> String? {
        
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next } // memory has been renamed to pointee in swift 3 so changed memory to pointee
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {  // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
}

@IBDesignable
class CardView: UIView {
    
    @IBInspectable var CornerRadiusCard: CGFloat = 5
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.9
    
    override func layoutSubviews() {
        layer.cornerRadius = CornerRadiusCard
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadiusCard)
        layer.masksToBounds = false
        //layer.borderColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0).cgColor
        //layer.borderWidth = 1
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    func RoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}




class AFWrapper: NSObject {
    
    
    class func requestWith(url: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let headers: HTTPHeaders = [
           
            "Authorization": "\(Constant.TOKEN))"
        ]
        
        print("Headers => \(headers)")
        
        print("Server Url => \(url)")
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let data = imageData{
                multipartFormData.append(data, withName: "product_video", fileName: "video.mp4", mimeType: "video/mp4")
            }
            
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                print("PARAMS => \(multipartFormData)")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    print(JSON(response.result.value as Any))
                    onCompletion?(JSON(response.result.value as Any))
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    class func requestPOSTURLWithJSONRequest(view : UIViewController, requestMethod : HTTPMethod, _ strURL : String, params : [String : AnyObject]?, headers: [String: String]?, success:@escaping (JSON) -> Void, failure:@escaping (NSError) -> Void){
        let viewD = view
        print(JSON(params))
        print(JSON(headers))
        //view.showLoader()
        
        let requestUrl = strURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        print("URL ->\(requestUrl ?? "")")
        
        let Alamofire = SessionManager.default
        Alamofire.session.configuration.timeoutIntervalForRequest = 300
        
        Alamofire.request(requestUrl!, method: requestMethod, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)){
                progress in
            }
            .responseJSON {
                
                response in
                if response.result.isSuccess {
                    
                   // view.stopLoader()
                    
                    let resJson = JSON(response.result.value!)
                    
                    print(resJson)
                    
//                    if resJson["status"].boolValue  {

                        success(resJson)

//                    }else {

                        //view.showToast(message: "Please try again")

  //                  }

//                    print(resJson)
//                    success(resJson)
                    
                }
                if response.result.isFailure {
                    
                   // view.stopLoader()
                    
                    print(response.result.error)
                    
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 404:
                            
                            break
                        case -1005:
                            
                            let error : NSError = response.result.error! as NSError
                            failure(error)
                            
                            break
                        default:
                            let error : NSError = response.result.error! as NSError
                           
                            let app = UIApplication.shared.delegate as! AppDelegate
                            
//                            if app.isCart{
//
//                                app.isCart = false
//                                app.invalidCard = true
//                                failure(error)
//
//                            }
                            
                          
                            
                           
                            
                            break;
                        }
                    } else {
                        
                        let error : NSError = response.result.error! as NSError
                        failure(error)
                        
                    }
                }
        }
    }
}

