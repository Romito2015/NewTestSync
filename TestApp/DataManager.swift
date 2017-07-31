//
//  DataManager.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation

class DataManager {
    static func retrieveData() -> [Post] {
        return DataManager.loadPosts("Data", in: Bundle.main)
    }
    
    static func loadPosts(_ plistName: String, in bundle: Bundle) -> [Post] {
        let path = bundle.path(forResource: plistName, ofType: "plist")!
        let array = NSArray(contentsOfFile: path) as! [[String:Any]]
        return Post.array(dictArray: array)
    }
}
