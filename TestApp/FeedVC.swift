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
//    let pendingOperations = PendingOperations()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    

    @IBOutlet weak var feedTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = DataManager.retrieveData()
        self.setupTableView()

        // Do any additional setup after loading the view.
    }
    
    func setupTableView() {
        self.feedTableView.estimatedRowHeight = 44
        self.feedTableView.rowHeight = UITableViewAutomaticDimension
        
        self.feedTableView.register(MessagePostCell.nib, forCellReuseIdentifier: MessagePostCell.identifier)
        self.feedTableView.register(PhotoPostCell.nib, forCellReuseIdentifier: PhotoPostCell.identifier)
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
//            if (!tableView.isDragging && !tableView.isDecelerating) {
                cell.mainImageView.imageUrl = post.imageURL
                if post.imageURL == cell.mainImageView.imageUrl {
                    cell.mainImageView.image = nil
                    if let im = post.imageURL?.cachedImage {
                        cell.mainImageView.image = im
                    } else {
                        appendOperations(cell.mainImageView, and: post.imageURL!)
                    }
                    
                }
                //guard let remoteImage = post.remoteImage else { return }
                //self.startDownloadForImage(remoteImage: remoteImage, indexPath: indexPath)
//            }
        }
        
    }
    
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
//            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
//        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations () {
        downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        downloadQueue.isSuspended = false
    }
}

extension FeedVC {
    func appendOperations(_ imageView: UIImageView, and url: NSURL) {
        //imageView.image = nil
        let operation1 = BlockOperation(block: {
            let img1 = Downloader.downloadImageWithURL(url)
            OperationQueue.main.addOperation({
                imageView.image = img1
            })
        })
        
        operation1.completionBlock = {
            print("Operation \(imageView.imageUrl) completed, cancelled:\(operation1.isCancelled)")
        }
        downloadQueue.addOperation(operation1)
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
            return image
        }
        return nil
    }
}


