//
//  FeedVC.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    
    var dataSource: [Post] = []
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var downloadsInProgress = [NSURL:Operation]()
    lazy var expandedRows = Set<Int>()
    
    @IBOutlet weak var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = DataManager.retrieveData()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.downloadQueue.isSuspended {
            self.resumeAllOperations()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.suspendAllOperations()    }
    
    func setupTableView() {
        self.feedTableView.estimatedRowHeight = 44
        self.feedTableView.rowHeight = UITableViewAutomaticDimension
        
        self.feedTableView.register(MessagePostCell.nib, forCellReuseIdentifier: MessagePostCell.identifier)
        self.feedTableView.register(PhotoPostCell.nib, forCellReuseIdentifier: PhotoPostCell.identifier)
    }
}

extension FeedVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = dataSource[indexPath.row]
        switch post.type {
        case .messagePost:
            return self.messagePostCell(withPost: post, at: indexPath)
        case .photoPost:
            return self.photoPostCell(withPost: post, at: indexPath)
        }
    }
    
    func messagePostCell(withPost post: Post, at indexPath: IndexPath) -> MessagePostCell {
        
        if let cell = feedTableView.dequeueReusableCell(withIdentifier: MessagePostCell.identifier,                                                                         for: indexPath) as? MessagePostCell{
            cell.isExpanded = self.expandedRows.contains(indexPath.row)
            cell.messageLabel.text = post.message
            return cell
        }
        return MessagePostCell()
    }
    
    func photoPostCell(withPost post: Post, at indexPath: IndexPath) -> PhotoPostCell {
        
        if let cell = feedTableView.dequeueReusableCell(withIdentifier: PhotoPostCell.identifier, for: indexPath) as? PhotoPostCell{
            return cell
        }
        return PhotoPostCell()
    }
}

extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let post = self.dataSource[indexPath.row]
        if let cell = cell as? PostCellProtocol {
            cell.configureCell(withPost: post)
            //if (!tableView.isDragging && !tableView.isDecelerating) {
            self.loadImage(imageView: cell.mainImageView, post: post)
            //}
        }
    }
    
    func loadImage(imageView: UIImageView, post:Post) {
        guard let postUrl = post.imageURL else { return }
        guard let imageViewUrl = imageView.imageUrl else { return }
        if postUrl == imageViewUrl {
            if let cachedImage = postUrl.cachedImage {
                imageView.image = cachedImage
                print("FROM CACHE!!!")
            } else {
                imageView.image = nil
                appendOperations(imageView, and: postUrl)
                
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations () {
        downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells () {
        //1
        print("**********")
        if let pathsArray = feedTableView.indexPathsForVisibleRows {
            
            
            let arryOfVisibleData: [(url:NSURL, imageView:UIImageView)] = pathsArray.flatMap { [weak self] in
                let cell = self?.feedTableView.cellForRow(at: $0)  as? PostCellProtocol
                guard let url = cell?.mainImageView.imageUrl else {return nil}
                guard let imV = cell?.mainImageView else { return nil }
                return (url, imV)
            }
            
            //2
            let allPendingOperations = downloadsInProgress.keys
            
            //3

            let arryOfVisibleUrls = arryOfVisibleData.map{$0.url}

            let toBeCancelled = allPendingOperations.filter { !arryOfVisibleUrls.contains($0)}
//            toBeCancelled.subtract(arryOfVisibleUrls)
            
            //4
            //var toBeStarted = visibleURLsSet
            let toBeStarted = arryOfVisibleUrls.filter{!arryOfVisibleUrls.contains($0)}
            
            // 5
            for urlKey in toBeCancelled {
                if let pendingDownload = downloadsInProgress[urlKey] {
                    pendingDownload.cancel()
                }
                downloadsInProgress.removeValue(forKey: urlKey)
                
            }
            
            // 6
            for urlKey in toBeStarted {
                let imageViewOptional = arryOfVisibleData.filter{$0.url == urlKey}.map{$0.imageView}.first
                guard let imageView = imageViewOptional else { return }
                
                if (imageView.image != nil) { continue }
                print("🚀\(urlKey)")
                self.appendOperations(imageView, and: urlKey)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MessagePostCell
            
            else { return }
        
        switch cell.isExpanded {
            
        case true:
            self.expandedRows.remove(indexPath.row)
        case false:
            self.expandedRows.insert(indexPath.row)
        }
        
        cell.isExpanded = !cell.isExpanded
        
        self.feedTableView.beginUpdates()
        self.feedTableView.endUpdates()
    }
    
}

extension FeedVC {
    func appendOperations(_ imageView: UIImageView, and url: NSURL) {
        
        if self.downloadsInProgress.keys.contains(url) { return }
        
        let imageDownloadOperation = BlockOperation(block: {
            let img1 = Downloader.downloadImageWithURL(url)
            OperationQueue.main.addOperation({
                if imageView.imageUrl == url {
                    imageView.image = img1
                    self.downloadsInProgress.removeValue(forKey: url)
                }
            })
        })
        
        imageDownloadOperation.completionBlock = { [weak imageDownloadOperation] in
            print("Operation \(String(describing: url.path)) completed, cancelled:\(imageDownloadOperation?.isCancelled)")
        }
        self.downloadsInProgress[url] = imageDownloadOperation
        self.downloadQueue.addOperation(imageDownloadOperation)
    }
    
    
}

class Downloader {
    
    class func downloadImageWithURL(_ url: NSURL) -> UIImage? {
        let data = try? Data(contentsOf: url as URL)
        
        if let imageD = url.cachedImage {
            return imageD
        }
        
        if let data = data, let image = UIImage(data: data) {
            MyImageCache.sharedCache.setObject(image,
                                               forKey: url.absoluteString as AnyObject,
                                               cost: data.count)
            print("✅ Download Completed: \(String(describing: url.path))")
            return image
        } else {
            print("❌ Download failed: \(String(describing: url.path))")
            return #imageLiteral(resourceName: "downloadFail")
        }
    }
}


