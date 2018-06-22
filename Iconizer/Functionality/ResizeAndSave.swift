//
//  ResizeAndSave.swift
//  Iconizer
//
//  Created by Liam Rosenfeld on 2/3/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

func resize(name: String, image: NSImage, w: Int, h: Int, saveTo: URL) {
    let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(destSize.width), pixelsHigh: Int(destSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)
    rep?.size = destSize
    NSGraphicsContext.saveGraphicsState()
    if let aRep = rep {
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: aRep)
    }
    image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    let newImage = NSImage(size: destSize)
    if let aRep = rep {
        newImage.addRepresentation(aRep)
    }
    save(to: saveTo, name: name, image: newImage)
}

func save(to: URL, name: String, image: NSImage) {
    let data: Data = image.tiffRepresentation!
    let filename = to.appendingPathComponent("\(name).png")
    try? data.write(to: filename)
}

func selectFolder(_ callingClass: String = #function) -> String {
    let selectPanel = NSOpenPanel()
    selectPanel.title = "Select a folder to save your icons"
    selectPanel.showsResizeIndicator = true
    selectPanel.canChooseDirectories = true
    selectPanel.canChooseFiles = false
    selectPanel.allowsMultipleSelection = false
    selectPanel.canCreateDirectories = true
    selectPanel.delegate = callingClass as? NSOpenSavePanelDelegate
    
    selectPanel.runModal()
    
    if selectPanel.url != nil {
        return String(describing: selectPanel.url!)
    } else {
        return "canceled"
    }
}

func createFolder(directory: URL) {
    do {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Folder Creation Error: \(error.localizedDescription)")
    }
    
}