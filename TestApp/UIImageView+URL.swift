//
//  UIImageView+URL.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

extension UIImageView {
    
    private struct AssociatedKeys {
        static var imageUrl = "url_imageUrl"
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
}
