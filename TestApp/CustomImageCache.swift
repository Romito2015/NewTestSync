//
//  CustomImageCache.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class CustomImageCache {
    
    static var sharedCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "CustomImageCache"
        cache.countLimit = 50
        cache.totalCostLimit = 100*1024*1024
        return cache
        }()
}


