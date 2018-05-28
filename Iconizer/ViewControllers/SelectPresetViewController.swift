//
//  SelectPresetViewController.swift
//  Iconizer
//
//  Created by Liam Rosenfeld on 5/19/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

class SelectPresetViewController: NSViewController {
    
    @IBOutlet weak var presetTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presetTable.delegate = self
        presetTable.dataSource = self
    }
    
    @IBAction func presetListClicked(_ sender: Any) {
        let clicked = presetTable.clickedRow
        
        if clicked >= 0 {
            let presetSelected = presetTable.clickedRow
            print(UserPresets.presets[presetSelected].name)
            
            let editPresetViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditPresetViewController")) as? EditPresetViewController
            editPresetViewController?.presetSelected = presetSelected
            view.window?.contentViewController = editPresetViewController
        }

    }
    
    @IBAction func done(_ sender: Any) {
        self.view.window!.close()
    }
    
}

extension SelectPresetViewController: NSTableViewDataSource {
    
    func numberOfRows(in presetList: NSTableView) -> Int {
        return UserPresets.presets.count
    }
    
}

extension SelectPresetViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = UserPresets.presets[row]
        let text = item.name

        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "selectTextCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = text
        return cell
    }
    
}