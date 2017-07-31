//
//  NSURL+.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/30/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

extension NSURL {
    
    var cachedImage: UIImage? {
        let cache = CustomImageCache.sharedCache
        let cachedImage = cache.object(forKey: self.absoluteString as AnyObject) as? UIImage
        return cachedImage
    }
}
