//
//  ImageWrapper.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

enum DownloadState {
    case New, Downloaded, Failed
}

class PhotoRecord {
    let url:NSURL
    var state = DownloadState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:NSURL) {
        self.name = name
        self.url = url
    }
}
