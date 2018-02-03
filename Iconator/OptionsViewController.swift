//
//  OptionsViewController.swift
//  Iconator
//
//  Created by Liam Rosenfeld on 2/1/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

class OptionsViewController: NSViewController {
    
    // Setup
    @IBOutlet weak var xcodeVersionSelector: NSPopUpButton!
    @IBOutlet weak var iPhoneToggle: NSButton!
    @IBOutlet weak var iPadToggle: NSButton!
    @IBOutlet weak var macToggle: NSButton!
    
    var imageURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageURL!)
    }
    
    // Actions
    @IBAction func convert(_ sender: Any) {
        let xcodeVersion = xcodeVersionSelector.titleOfSelectedItem!
        let iPhoneEnabled = iPhoneToggle.state.rawValue
        let iPadEnabled = iPadToggle.state.rawValue
        let macEnabled = macToggle.state.rawValue
        
        let imageToConvert = urlToImage(url: imageURL!)
        
        if xcodeVersion == "9" {
            if iPhoneEnabled == 1 {
                xcode9_iPhone(image: imageToConvert)
            }
            if iPadEnabled == 1 {
                xcode9_iPad(image: imageToConvert)
            }
            if macEnabled == 1 {
                xcode9_mac(image: imageToConvert)
            }
        } else if xcodeVersion == "8" {
            if iPhoneEnabled == 1 {
                xcode8_iPhone(image: imageToConvert)
            }
            if iPadEnabled == 1 {
                xcode8_iPad(image: imageToConvert)
            }
            if macEnabled == 1 {
                xcode8_mac(image: imageToConvert)
            }
        }
        
    }
    
    // Convert NSurl to NSImage
    func urlToImage(url: NSURL) -> NSImage {
        do {
            let imageData = try NSData(contentsOf: url as URL, options: NSData.ReadingOptions())
            return NSImage(data: imageData as Data)!
        } catch {
            print(error)
        }
        // Probally should change the backup return sometime
        return #imageLiteral(resourceName: "uploadIcon")
    }
    
}
