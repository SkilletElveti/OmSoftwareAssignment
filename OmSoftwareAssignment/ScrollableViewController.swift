import UIKit
import AVKit
import SwiftyJSON
import SnapKit
import SkeletonView

protocol Appear {
    func open()
}

class ScrollableViewController: UIViewController {
  
    
    var appearDelegate: Appear?
    var mainTitle: UILabel!
    var titleLabel: UILabel!
    var subUrl: UILabel!
    var filterPlayers : [AVPlayer?] = []
    var currentPage: Int = 0
    var filterScrollView : UIScrollView?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var avPlayerLayer : AVPlayerLayer!
    var list : [ListDataModel] = []
    let app = UIApplication.shared.delegate as! AppDelegate
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app.VC = self
        getVideoList()
        self.view.backgroundColor = .black
       // self.view.backgroundColor = .black
        subUrl = UILabel()
        mainTitle = UILabel()
        titleLabel = UILabel()
        mainTitle = UILabel()
       
        self.view.addSubview(mainTitle)
        self.view.addSubview(subUrl)
        self.view.addSubview(titleLabel)
        self.navigationController?.navigationBar.isHidden = true
       
        
        self.subUrl.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview().offset(-25)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
        })
        
        self.titleLabel.snp.makeConstraints({
            $0.leading.equalTo(subUrl)
            $0.trailing.equalTo(subUrl)
            $0.bottom.equalTo(subUrl.snp.top).offset(-5)
        })
        
        self.mainTitle.snp.makeConstraints({
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
        })
      
        mainTitle.text = "Reel"
        mainTitle.textAlignment = .center
        subUrl.text = ""
        titleLabel.text = ""
        subUrl.textColor = .white
        mainTitle.textColor = .white
        mainTitle.font = UIFont.boldSystemFont(ofSize: 25)
        subUrl.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
       
        
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        
       
    }
    
        
       
    func getVideoList(){
        if Reachability.isInternetAvailable(){
            app.showLoader()
            self.view.makeToast("Fetching Data...")
            let SERVER_URL = Constant.GET_LIST
            print("SEVER URL => \(SERVER_URL)")
            let url = URL(string: SERVER_URL)
            var request = URLRequest(url: url!)
            request.setValue("\(Constant.TOKEN)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            print("Authorization => \(request.value(forHTTPHeaderField: "Authorization") ?? "SOME")")
            URLSession.shared.dataTask(with: request){Data,Response,Error in
                if Error == nil{
                   
                    let JSONResponse = JSON(Data)
                    print(JSON(Data))
                    if JSONResponse["status"].boolValue{
                        let base_url = JSONResponse["pic_url"].stringValue
                        for i in 0 ..< JSONResponse["data"].count{
                            for j in 0 ..< JSONResponse["data"][i]["media"].count{
                                
                                let media_name = JSONResponse["data"][i]["media"][j]["media_name"].stringValue
                                let final_url = base_url + media_name
                                let title = JSONResponse["data"][i]["title"].stringValue
                                let id = JSONResponse["data"][i]["media"][j]["id"].stringValue
                                let media_type = JSONResponse["data"][i]["media"][j]["media_type"].stringValue
                                print(media_type)
                                if media_type == "video/mp4"{
                                    self.list.append(ListDataModel(onCompletion: {
                                            data in
                                                                   
                                            data.media_name = media_name
                                            data.final_url = final_url
                                            data.title = title
                                            data.id = id
                                                                   
                                    }))
                                }
                                
                            }
                            
                            if i == JSONResponse["data"].count - 1 {
                                DispatchQueue.main.async { [weak self] in
                                    self?.setupFilterWith(size: UIScreen.main.bounds.size)
                                   
                                    self?.subUrl.text = self?.list[0].media_name
                                    self?.titleLabel.text = "Product ID:" + (self?.list[0].id)!
                                }
                               
                            }
                        }
                    }else{
                        
                    }
                    
                }else{
                    print(Error)
                }
                print()
            }.resume()
            
        }else{
           self.view.makeToast("Internet Not Available")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
       // self.navigationController?.popViewController(animated: true)
        for i in 0 ..< filterPlayers.count{
            filterPlayers[i]!.pause()
            if i == filterPlayers.count - 1{
                self.appearDelegate?.open()
            }
        }
    }
    
}


extension ScrollableViewController: UIScrollViewDelegate {
    
    func setupFilterWith(size: CGSize)  {
        titleLabel.text = "Product ID:" + list[0].id
        subUrl.text  = list[0].media_name
        currentPage = 0
        filterPlayers.removeAll()
        filterScrollView = UIScrollView(frame: UIScreen.main.bounds)
        
        let count = list.count
        for i in 0...count-1 {
            //Adding image to scroll view
            let imgView : UIView = UIView.init(frame: CGRect(x: 0 , y: CGFloat(i) * size.height, width: size.width, height: size.height))
            let imgViewThumbnail: UIImageView = UIImageView.init(frame: imgView.bounds)
            
            //imgView.image =
            imgView.backgroundColor = .clear
            imgViewThumbnail.contentMode = .scaleAspectFit
            imgView.addSubview(imgViewThumbnail)
            imgViewThumbnail.image = getThumbnailImage(forUrl: URL(string: list[i].final_url)!)
            filterScrollView?.addSubview(imgView)
           
            
            //For Multiple player
            
             let player = AVPlayer(url: URL(string: list[i].final_url)!)
             let avPlayerLayer = AVPlayerLayer(player: player)
             avPlayerLayer.videoGravity = .resizeAspectFill
             avPlayerLayer.masksToBounds = true
             avPlayerLayer.cornerRadius = 5
             avPlayerLayer.frame = imgView.layer.bounds
             imgView.layer.addSublayer(avPlayerLayer)
             filterPlayers.append(player)
            if i == count - 1{
                app.removeLoader()
            }
             
            
        }
        filterScrollView?.isPagingEnabled = true
        filterScrollView?.contentSize = CGSize.init(width:  size.width, height: CGFloat(list.count) * size.height)
        filterScrollView?.backgroundColor = .black
        filterScrollView?.delegate = self
        view.addSubview(filterScrollView!)
        self.view.bringSubviewToFront(mainTitle)
        self.mainTitle.textAlignment = .center
        self.view.bringSubviewToFront(titleLabel)
        self.view.bringSubviewToFront(subUrl)
       
        titleLabel.numberOfLines = 0
        subUrl.numberOfLines = 0

        playVideos()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func playVideos() {
        for i in 0...filterPlayers.count - 1 {
            playVideoWithPlayer((filterPlayers[i])!)
        }

        for i in 0...filterPlayers.count - 1 {
            if i != currentPage {
                (filterPlayers[i])!.pause()
            }
        }
    }
    
    func playVideoWithPlayer(_ player: AVPlayer) {
        player.play()
    }
    
    //For Single player
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //avPlayerLayer.isHidden = true
        //player?.pause()
    }
    
    //For Single player
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       // avPlayerLayer.isHidden = false
        //player?.play()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth : CGFloat = (filterScrollView?.frame.size.height)!
        let fractionalPage : Float = Float((filterScrollView?.contentOffset.y)! / pageWidth)
        let targetPage : NSInteger = lroundf(fractionalPage)
        
        if targetPage != currentPage {
            currentPage = targetPage
            
            //For Single player
//            player = AVPlayer(url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!)
//            player?.play()
            
            //For Multiple player
            for i in 0...filterPlayers.count - 1 {
                if i == currentPage {
                    (filterPlayers[i])!.play()
                    titleLabel.text = "Product ID:" + list[i].id
                    subUrl.text  = list[i].media_name
                } else {
                    (filterPlayers[i])!.pause()
                }
            }
        }
        
    }
    
    func playVideoWithPlayer(_ player: AVPlayer, video:AVURLAsset, filterName:String) {
        
        let  avPlayerItem = AVPlayerItem(asset: video)
        
        if (filterName != "NoFilter") {
            let avVideoComposition = AVVideoComposition(asset: video, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                let filter = CIFilter(name:filterName)!
                filter.setDefaults()
                filter.setValue(source, forKey: kCIInputImageKey)
                let output = filter.outputImage!
                request.finish(with:output, context: nil)
            })
            avPlayerItem.videoComposition = avVideoComposition
        }
        
        player.replaceCurrentItem(with: avPlayerItem)
        player.play()
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        
        //For Single player
//                player!.seek(to: CMTime.zero)
//                player!.play()
        
        
        //        For Multiple player
                for i in 0...filterPlayers.count - 1 {
                    if i == currentPage {
                        (filterPlayers[i])!.seek(to: CMTime.zero)
                        (filterPlayers[i])!.play()
                    }
                }
    }
    
}
