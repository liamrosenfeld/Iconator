//
//  EditPresetViewController.swift
//  Iconology
//
//  Created by Liam Rosenfeld on 5/19/18.
//  Copyright © 2018 Liam Rosenfeld. All rights reserved.
//

import Cocoa

protocol EditPresetDelegate {
    func removeSize(at index: Int)
    func addSize(_ size: ImgSetPreset.ImgSetSize, at index: Int?)
    func changeName(at index: Int, to name: String)
    func changeWidth(at index: Int, to size: Int)
    func changeHeight(at index: Int, to size: Int)
    func changeAspect(to aspect: NSSize)
    var preset: CustomPreset? { get }
}

extension EditPresetDelegate {
    func appendSize(_ size: ImgSetPreset.ImgSetSize) {
        addSize(size, at: nil)
    }
}

class EditPresetViewController: NSViewController {
    // MARK: - Setup

    @IBOutlet var presetTable: NSTableView!
    @IBOutlet var titleLabel: NSTextFieldCell!
    @IBOutlet var manageRowsButton: NSSegmentedControl!
    @IBOutlet var aspectW: NSTextField!
    @IBOutlet var aspectH: NSTextField!

    var delegate: EditPresetDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Delegates
        presetTable.delegate = self
        presetTable.dataSource = self

        // Load UI
        if delegate.preset != nil {
            prepUI()
        }
    }

    // MARK: - Temp Save

    func reloadUI() {
        if isViewLoaded, view.window != nil {
            let presetSelected = (delegate.preset != nil)

            // enable/disable table
            enableUI(presetSelected)

            // set UI values
            if presetSelected {
                prepUI()
            }
        }
    }

    func enableUI(_ enabled: Bool) {
        presetTable.isEnabled = enabled
        manageRowsButton.isEnabled = enabled
        aspectW.isEnabled = enabled
        aspectH.isEnabled = enabled

        if !enabled {
            presetTable.reloadData()
            titleLabel.stringValue = "Please Select a Preset"
        }
    }

    func prepUI() {
        presetTable.reloadData()
        guard let preset = delegate.preset else { return }
        titleLabel.stringValue = "\(preset.name)'s Sizes"
        aspectW.stringValue = preset.aspect.width.clean
        aspectH.stringValue = preset.aspect.height.clean
    }

    // MARK: - Actions

    @IBAction func manageRows(_: Any) {
        if manageRowsButton.selectedSegment == 0 {
            newRow()
        } else if manageRowsButton.selectedSegment == 1 {
            removeRow()
        }
    }

    @IBAction func aspectSelected(_: Any) {
        guard var width = Int(aspectW.stringValue) else {
            Alerts.warningPopup(title: "Non-Integer Inputed", text: "'\(aspectW.stringValue)' is Not an Integer")
            return
        }
        guard var height = Int(aspectH.stringValue) else {
            Alerts.warningPopup(title: "Non-Integer Inputed", text: "'\(aspectH.stringValue)' is Not an Integer")
            return
        }

        if width == 0 {
            width = 1
            aspectW.stringValue = "1"
        }
        if height == 0 {
            height = 1
            aspectH.stringValue = "1"
        }

        let aspect = NSSize(width: width, height: height)
        delegate.changeAspect(to: aspect)
    }

    // MARK: - Table Updates

    func newRow() {
        // Generate Name
        var name = "New Size"
        var num = 1
        while true {
            let contains = delegate.preset!.sizes.contains { $0.name == name }
            if !contains {
                break
            }
            name = "New Size \(num)"
            num += 1
        }

        // Update Data
        delegate.appendSize(ImgSetPreset.ImgSetSize(name: name, size: delegate.preset!.aspect))

        // Update Table
        addTableRow(at: delegate.preset!.sizes.count - 1)
    }

    func removeRow() {
        let selectedRow = presetTable!.selectedRow
        if selectedRow != -1 {
            // Update Data
            delegate.removeSize(at: selectedRow)

            // Update Table
            removeTableRow(at: selectedRow)
        }
    }

    // MARK: - Table Updating

    func addTableRow(at index: Int) {
        presetTable.insertRows(at: IndexSet(integer: index), withAnimation: .effectFade)
        presetTable.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
    }

    func removeTableRow(at index: Int) {
        presetTable.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
        if index > Storage.userPresets.presets.count - 1 {
            presetTable.selectRowIndexes(IndexSet(integer: index - 1), byExtendingSelection: false)
        } else {
            presetTable.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        }
    }

    func reload(row: Int, col: Int) {
        presetTable.reloadData(forRowIndexes: IndexSet(integer: row),
                               columnIndexes: IndexSet(integer: col))
    }

    func reloadAspect() {
        aspectW.stringValue = delegate.preset!.aspect.width.clean
        aspectH.stringValue = delegate.preset!.aspect.height.clean
    }

    // MARK: - Textbox Management

    @IBAction func textFieldFinishEdit(sender: NSTextField) {
        let selectedRow = presetTable.selectedRow
        let column = presetTable.column(for: sender)
        let value = sender.stringValue
        guard let preset = delegate.preset else { return }

        if selectedRow != -1 {
            switch column {
            case 0:
                let oldName = preset.sizes[selectedRow].name
                for index in 0 ..< preset.sizes.count {
                    if value == preset.sizes[index].name && index != selectedRow {
                        Alerts.warningPopup(title: "Name Already Exists", text: "'\(value)' is Already Taken")
                        sender.stringValue = oldName
                        return
                    }
                }
                delegate.changeName(at: selectedRow, to: value)
            case 1:
                guard let intValue = Int(value) else {
                    Alerts.warningPopup(title: "Non-Integer Inputed", text: "'\(value)' is Not an Integer")
                    sender.stringValue = Int(preset.sizes[selectedRow].size.width).description
                    return
                }
                delegate.changeWidth(at: selectedRow, to: intValue)
            case 2:
                guard let intValue = Int(value) else {
                    Alerts.warningPopup(title: "Non-Integer Inputed", text: "'\(value)' is Not an Integer")
                    sender.stringValue = Int(preset.sizes[selectedRow].size.height).description
                    return
                }
                delegate.changeHeight(at: selectedRow, to: intValue)
            default:
                fatalError("Column not found")
            }
        }
    }
}

// MARK: - Table Setup

extension EditPresetViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        guard let sizes = delegate.preset?.sizes else {
            return 0
        }
        return sizes.count
    }
}

extension EditPresetViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers: String {
        case nameCell = "nameCellID"
        case xCell = "xCellID"
        case yCell = "yCellID"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text = ""
        var cellIdentifier = ""
        let sizes = delegate.preset!.sizes[row]

        if tableColumn == presetTable.tableColumns[0] {
            text = sizes.name
            cellIdentifier = CellIdentifiers.nameCell.rawValue
        } else if tableColumn == presetTable.tableColumns[1] {
            text = sizes.size.width.clean
            cellIdentifier = CellIdentifiers.xCell.rawValue
        } else if tableColumn == presetTable.tableColumns[2] {
            text = sizes.size.height.clean
            cellIdentifier = CellIdentifiers.yCell.rawValue
        } else {
            print("Somthing went wrong... \(String(describing: tableColumn))")
        }

        let cellID = NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)
        let cell = tableView.makeView(withIdentifier: cellID, owner: self) as? NSTableCellView
        cell?.textField?.stringValue = text
        return cell
    }
}
