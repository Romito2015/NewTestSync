//
//  ImageDownloader.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class DownloadManager {
    
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var downloadsInProgress = [NSURL:Operation]()
    
    func appendOperations(_ imageView: UIImageView, and url: NSURL) {
        
        if self.downloadsInProgress.keys.contains(url) { return }
        
        let imageDownloadOperation = BlockOperation(block: {
            let img1 = DownloadManager.downloadImageWithURL(url)
            OperationQueue.main.addOperation({
                if imageView.imageUrl == url {
                    imageView.image = img1
                    UIView.animate(withDuration: 0.25) {
                        imageView.alpha = 1
                    }
                    self.downloadsInProgress.removeValue(forKey: url)
                }
            })
        })
        
        imageDownloadOperation.completionBlock = { [weak imageDownloadOperation] in
            guard let orerationStrong = imageDownloadOperation else { return }
            print("Operation \((url.path ?? "No UrlPath")) completed, cancelled:\(orerationStrong.isCancelled)")
        }
        self.downloadsInProgress[url] = imageDownloadOperation
        self.downloadQueue.addOperation(imageDownloadOperation)
    }
    
    func suspendAllOperations () {
        self.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        self.downloadQueue.isSuspended = false
    }
    
    class func downloadImageWithURL(_ url: NSURL) -> UIImage? {
        DownloadManager.showNetworkIndicator()
        do {
            let data = try Data(contentsOf: url as URL)
            
            if let imageD = url.cachedImage {
                print("🚀 We have it Cached: \((url.path ?? "No UrlPath"))")
                return imageD
            }
            
            if let image = UIImage(data: data) {
                CustomImageCache.sharedCache.setObject(image,
                                                   forKey: url.absoluteString as AnyObject,
                                                   cost: data.count)
                print("✅ Download Completed: \((url.path ?? "No UrlPath"))")
                DownloadManager.hideNetworkIndicator()
                return image
            } else {
                print("❌ Download failed Data corrupted: \((url.path ?? "No UrlPath"))")
                DownloadManager.hideNetworkIndicator()
                return #imageLiteral(resourceName: "downloadFail")
            }
        } catch {
            print("❌ Download failed: \((url.path ?? "No UrlPath"))\n Error: \(error)")
            DownloadManager.hideNetworkIndicator()
            return #imageLiteral(resourceName: "downloadFail")
        }
        
    }
    
    private static func showNetworkIndicator() {
        DispatchQueue.main.async {
            if !UIApplication.shared.isNetworkActivityIndicatorVisible {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    
    private static func hideNetworkIndicator() {
        DispatchQueue.main.async {
            if UIApplication.shared.isNetworkActivityIndicatorVisible {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
