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
        
        self.itemsCountSlider.value = Float(MyImageCache.sharedCache.countLimit)
        self.cacheSizeSlider.value = Float(MyImageCache.sharedCache.totalCostLimit/(1024*1024))
        self.setupItemsCountLabel()
        self.setupCacheSizeLabel()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func itemsCountValueChanged(_ sender: UISlider) {
        self.setupItemsCountLabel()
        if !sender.isTracking {
            
            MyImageCache.sharedCache.countLimit = Int(sender.value)
            print(")_(_)_)*_)*_(**_(*)(")
        }
    }
    
    @IBAction func cacheSizeValueChanged(_ sender: UISlider) {
        self.setupCacheSizeLabel()
        if !sender.isTracking {
            
            MyImageCache.sharedCache.totalCostLimit = Int(sender.value)*1024*1024
            print(")_(_)_)*_)*_(**_(*)(")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
