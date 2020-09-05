//
//  ViewController.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import UIKit
import Toast_Swift
import SwiftyJSON
import SkeletonView
import SDWebImage
import SnapKit

class VideoListViewController: UIViewController {

    @IBOutlet weak var parT: UITableView!
    
    var ListSG: [ListDataModel] = []
    var ParentArray : [ListArray] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parT.delegate = self
        parT.dataSource = self
        parT.backgroundColor = .clear
        parT.separatorStyle = .none
        getVideoList()
        
    }

    
    
    func getVideoList(){
        if Reachability.isInternetAvailable(){
            
            let SERVER_URL = Constant.GET_LIST
            
            let url = URL(string: SERVER_URL)
            var request = URLRequest(url: url!)
            request.setValue("\(Constant.TOKEN)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "Get"
            
            URLSession.shared.dataTask(with: request){Data,Response,Error in
                if Error == nil{
                   
                    let JSONResponse = JSON(Data)
                    if JSONResponse["status"].boolValue{
                        let base_url = JSONResponse["pic_url"].stringValue
                        for i in 0 ..< JSONResponse["data"].count{
                            for j in 0 ..< JSONResponse["data"][i]["media"].count{
                                
                                let media_name = JSONResponse["data"][i]["media"][j]["media_name"].stringValue
                                let final_url = base_url + media_name
                                let title = JSONResponse["data"][i]["title"].stringValue
                                let id = JSONResponse["data"][i]["media"][j]["id"].stringValue
                                
                                self.ListSG.append(ListDataModel(onCompletion: {
                                        data in
                                                               
                                        data.media_name = media_name
                                        data.final_url = final_url
                                        data.title = title
                                        data.id = id
                                                               
                                }))
                                
                                
                                if j == JSONResponse["data"][i]["media"].count - 1{
                                    self.ParentArray.append(ListArray(onCompletion: {
                                        data in
                                        data.List = self.ListSG
                                       
                                    }))
                                     self.ListSG = []
                                }
                                
                                
                            }
                        
                            
                            
                           
                            if i == JSONResponse["data"].count - 1 {
                                DispatchQueue.main.async {
                                     self.parT.reloadData()
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
    

}

extension VideoListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ParentArray.count == 0{
            return 10
        }else{
            return ParentArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! tableCell
        if self.ParentArray.count == 0{
            
        }else{
            
            cell.list = self.ParentArray[indexPath.row].List
            cell.reloadCollection()
            
        }
        return cell
    }
    
    
}


class tableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var list: [ListDataModel]!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if list == nil{
            return 2
        }else{
            return list.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentCollectionViewCell", for: indexPath) as! RecentCollectionViewCell
        if list == nil{
            
            self.titleLabel.isSkeletonable = true
            self.titleLabel.showSkeleton(usingColor: .belizeHole, transition: .crossDissolve(1))
            cell.skeletonBegin()
            
        }else{
            
            self.titleLabel.hideSkeleton()
            self.titleLabel.text = list[indexPath.row].title
            cell.hideSkeleton()
            cell.image.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.image.sd_setImage(with: URL(string: list[indexPath.row].final_url), completed: nil)
            cell.model.text = list[indexPath.row].title
        }
        
        
        
        return cell
    }
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configCollection2(){
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width - 20
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 1, right: 0)
                    layout.itemSize = CGSize(width:(screenWidth / 2 ), height: 270)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        self.collection.collectionViewLayout = layout
    
    }
   
    
    override func awakeFromNib() {
        configCollection2()
        
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.bottom.equalTo(collection.snp.top).offset(-5)
        })
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        collection.snp.makeConstraints({
            
            $0.leading.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.bottom.equalToSuperview().offset(-2)
            
        })
        
        collection.dataSource = self
        collection.delegate = self
        
    }
    
    func reloadCollection(){
        self.collection.reloadData()
    }
}

class RecentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var model: UILabel!
   
    
    func skeletonBegin(){
        
        image.isSkeletonable = true
        model.isSkeletonable = true
        image.showSkeleton(usingColor: .belizeHole, transition: .crossDissolve(1))
        model.showSkeleton(usingColor: .clouds, transition: .crossDissolve(1))
       
    }
    
    func hideSkeleton(){
        
        image.hideSkeleton()
        model.hideSkeleton()
        
    }
    
}
