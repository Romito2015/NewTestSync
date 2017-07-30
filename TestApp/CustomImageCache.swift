//
//  CustomImageCache.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class MyImageCache {
    
    static var sharedCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "MyImageCache"
        cache.countLimit = 50
        cache.totalCostLimit = 100*1024*1024
        return cache
        }()
}

extension NSURL {
    
    typealias ImageCacheCompletion = (UIImage) -> Void
    
    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        let cache = MyImageCache.sharedCache
        let cachedImage = cache.object(forKey: self.absoluteString as AnyObject) as? UIImage
        return cachedImage
    }
    
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: @escaping ImageCacheCompletion) {
        
        self.showNetworkIndicator()
        let task = URLSession.shared.dataTask(with: self as URL) {
            data, response, error in
            if error == nil {
                print("Thread: \(Thread.current)")
                if let data = data, let image = UIImage(data: data) {
                    MyImageCache.sharedCache.setObject(image,
                                                       forKey: self.absoluteString as AnyObject,
                                                       cost: data.count)
                    DispatchQueue.main.async() { [weak self] in
                        self?.hideNetworkIndicator()
                        completion(image)
                        
                    }
                } else {
                    self.hideNetworkIndicator()
                    print("ImageDownload Fail")
                }
            } else {
                self.hideNetworkIndicator()
                print("🎟 Fail\(String(describing: error))")
            }
        }
        task.resume()
    }
    
    internal func showNetworkIndicator() {
        if !UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    internal func hideNetworkIndicator() {
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
}
