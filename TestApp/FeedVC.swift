//
//  FeedVC.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    var dataSource: [Post] = []
    let imageDownloder = DownloadManager()
    lazy var expandedRows = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = DataManager.retrieveData()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageDownloder.resumeAllOperations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.imageDownloder.suspendAllOperations()
    }
    
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
            
            self.loadImage(imageView: cell.mainImageView, post: post)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MessagePostCell else { return }
        
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
    
    func loadImage(imageView: UIImageView, post:Post) {
        guard let postUrl = post.imageURL else { return }
        guard let imageViewUrl = imageView.imageUrl else { return }
        imageView.alpha = 0
        if postUrl == imageViewUrl {
            if let cachedImage = postUrl.cachedImage {
                imageView.image = cachedImage
                UIView.animate(withDuration: 0.25) {
                    imageView.alpha = 1
                }
                print("🚀 We have it Cached: \((postUrl.path ?? "No UrlPath"))")
            } else {
                imageView.image = nil
                self.imageDownloder.appendOperations(imageView, and: postUrl)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.imageDownloder.suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            self.imageDownloder.resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        self.imageDownloder.resumeAllOperations()
    }
    
    func loadImagesForOnscreenCells () {
        if let pathsArray = feedTableView.indexPathsForVisibleRows {
            
            let arryOfVisibleData: [(url:NSURL, imageView:UIImageView)] = pathsArray.flatMap { [weak self] in
                let cell = self?.feedTableView.cellForRow(at: $0)  as? PostCellProtocol
                guard let url = cell?.mainImageView.imageUrl else {return nil}
                guard let imV = cell?.mainImageView else { return nil }
                return (url, imV)
            }
            
            let allPendingOperations = self.imageDownloder.downloadsInProgress.keys

            let arryOfVisibleUrls = arryOfVisibleData.map{$0.url}

            let toBeCancelled = allPendingOperations.filter { !arryOfVisibleUrls.contains($0)}

            let toBeStarted = arryOfVisibleUrls.filter{!arryOfVisibleUrls.contains($0)}
            
            for urlKey in toBeCancelled {
                if let pendingDownload = self.imageDownloder.downloadsInProgress[urlKey] {
                    pendingDownload.cancel()
                }
                self.imageDownloder.downloadsInProgress.removeValue(forKey: urlKey)
            }
            
            for urlKey in toBeStarted {
                let imageViewOptional = arryOfVisibleData.filter{$0.url == urlKey}.map{$0.imageView}.first
                guard let imageView = imageViewOptional else { return }
                
                if (imageView.image != nil) { continue }
                self.imageDownloder.appendOperations(imageView, and: urlKey)
            }
        }
    }
}
