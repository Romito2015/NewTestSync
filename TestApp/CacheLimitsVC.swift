//
//  CacheLimitsVC.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/30/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class CacheLimitsVC: UIViewController {
    
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var itemsCountSlider: UISlider!
    
    @IBOutlet weak var cacheSizeLabel: UILabel!
    @IBOutlet weak var cacheSizeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemsCountSlider.value = Float(CustomImageCache.sharedCache.countLimit)
        self.cacheSizeSlider.value = Float(CustomImageCache.sharedCache.totalCostLimit/(1024*1024))
        self.setupItemsCountLabel()
        self.setupCacheSizeLabel()
    }
    
    @IBAction func itemsCountValueChanged(_ sender: UISlider) {
        self.setupItemsCountLabel()
        if !sender.isTracking {
            CustomImageCache.sharedCache.countLimit = Int(sender.value)
        }
    }
    
    @IBAction func cacheSizeValueChanged(_ sender: UISlider) {
        self.setupCacheSizeLabel()
        if !sender.isTracking {
            CustomImageCache.sharedCache.totalCostLimit = Int(sender.value)*1024*1024
        }
    }
    
    //MARK: Convenience methods
    private let stepForSlider: Float = 1
    func setupItemsCountLabel() {
        let newValue = round(self.itemsCountSlider.value / stepForSlider) * stepForSlider
        self.itemsCountSlider.value = newValue
        self.itemsCountLabel.text = "Max image items in cache: \(Int(newValue))"
    }
    
    func setupCacheSizeLabel() {
        let newValue = round(self.cacheSizeSlider.value / stepForSlider) * stepForSlider
        self.cacheSizeSlider.value = newValue
        self.cacheSizeLabel.text = "Max chache size, \(Int(newValue))Mb"
    }
}
