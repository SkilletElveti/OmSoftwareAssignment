//
//  ListDataModel.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import Foundation

class ListArray{
    var List :[ListDataModel]!
    init(onCompletion: @escaping (ListArray)->()){
           onCompletion(self)
       }
}

class ListDataModel {
    
    var title: String!
    var media_name: String!
    var final_url: String!
    var id: String!
   
    init(onCompletion: @escaping (ListDataModel)->()){
        onCompletion(self)
    }
}
