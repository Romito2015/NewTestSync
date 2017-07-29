//
//  ImageDownloader.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    //1
    let remoteImage: RemoteImage
    
    //2
    init(remoteImage: RemoteImage) {
        self.remoteImage = remoteImage
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        //5
        do {
        let imageData = try Data(contentsOf: self.remoteImage.url as URL)
            //6
            if self.isCancelled {
                return
            }
            
            //7
            if imageData.count > 0 {
                self.remoteImage.image = UIImage(data:imageData)
                self.remoteImage.state = .Downloaded
            } else {
                handleDownloadFail()
            }
            
        } catch {
            
            self.handleDownloadFail()
            
        }
        
        
    }
    
    internal func handleDownloadFail() {
        self.remoteImage.state = .Failed
        self.remoteImage.image = UIImage(named: "downloadFail")
    }
}
