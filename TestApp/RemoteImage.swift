//
//  ImageWrapper.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

public enum DownloadState {
    case New, Downloaded, Failed
}

public class RemoteImage {
    let url:NSURL
    var state = DownloadState.New
    var image: UIImage?
    
    init(url:NSURL, placeholder: String) {
        self.url = url
        let img = UIImage(named: placeholder) 
            self.image = img
        
        
    }
}
