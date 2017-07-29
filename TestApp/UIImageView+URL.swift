//
//  UIImageView+URL.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

extension UIImageView {
    
//    enum DownloadState {
//        case New, Downloaded, Failed
//    }
    
    private struct AssociatedKeys {
        static var imageUrl = "url_imageUrl"
//        static var downloadState = "state_imageDownloadState"
    }
    
    var imageUrl: NSURL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.imageUrl) as? NSURL
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.imageUrl, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
//    var downloadState: DownloadState? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.downloadState) as? DownloadState
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &AssociatedKeys.downloadState, newValue, .OBJC_ASSOCIATION_ASSIGN)
//            }
//        }
//    }
    
    
    
    func loadImage(withUrl url: NSURL?) {
        
        self.imageUrl = url
        
        if let image = url?.cachedImage {
            self.image = image
            self.alpha = 1
        } else {
            self.alpha = 0
            url?.fetchImage(completion: { (image) in
                if self.imageUrl == url {
                    self.image = image
                    UIView.animate(withDuration: 0.25, animations: {
                        self.alpha = 1
                    })
                }
            })
        }
    }

    
}
