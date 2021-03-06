//
//  ImageOptionsViewController.swift
//  Iconology
//
//  Created by Liam Rosenfeld on 1/21/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import Cocoa

class ImageOptionsViewController: NSViewController {
    // MARK: - Setup

    var mods = ImageModifier(image: NSImage())

    override func viewDidLoad() {
        // Load View Hierarchy
        _ = view

        // shiftSelector
        shiftSelector.target = self
        shiftSelector.action = #selector(shiftSelected)

        // set ui
        resetAll()
        setContinuous()
        prefixPreview.stringValue = ""

        // notif
        NotificationCenter.default.addObserver(forName: .generalPrefApply, object: nil, queue: nil) { _ in
            self.setContinuous()
        }
    }

    func setContinuous() {
        let cont = Storage.preferences.continuousPreview
        // TODO: Non-Continuous Background Option
        // backgroundColor.isContinuous = cont
        scaleSlider.isContinuous = cont
        shiftSelector.isContinuous = cont
        roundSlider.isContinuous = cont
    }

    // MARK: - Outlets

    @IBOutlet var backgroundView: NSView!
    @IBOutlet var backgroundToggle: NSButton!
    @IBOutlet var backgroundColor: NSColorWell!

    @IBOutlet var scaleView: NSView!
    @IBOutlet var scaleSlider: NSSlider!
    @IBOutlet var scaleText: NSTextField!

    @IBOutlet var shiftView: NSView!
    @IBOutlet var shiftSelector: PositionSelector!
    @IBOutlet var shiftXText: NSTextField!
    @IBOutlet var shiftYText: NSTextField!

    @IBOutlet var roundView: NSView!
    @IBOutlet var roundSlider: NSSlider!
    @IBOutlet var roundText: NSTextField!

    @IBOutlet var paddingView: NSView!
    @IBOutlet var paddingSlider: NSSlider!
    @IBOutlet var paddingText: NSTextField!

    @IBOutlet var prefixView: NSView!
    @IBOutlet var prefixTextBox: NSTextField!
    @IBOutlet var prefixPreview: NSTextField!

    // MARK: - Parent Interactions

    func setMods(from preset: Preset) {
        let useMod = preset.useModifications
        backgroundView.isHidden = !useMod.background
        scaleView.isHidden = !useMod.scale
        shiftView.isHidden = !useMod.shift
        roundView.isHidden = !useMod.round
        paddingView.isHidden = !useMod.padding
        prefixView.isHidden = !useMod.prefix

        if !useMod.round {
            resetRound(self)
        }
        if !useMod.padding {
            resetPadding(self)
        }
    }

    var prefix: String {
        prefixTextBox.stringValue
    }

    // MARK: - Actions

    func resetAll() {
        resetScale(self)
        resetShift(self)
        resetRound(self)
    }

    // Background
    @IBAction func backgroundToggled(_: Any) {
        switch backgroundToggle.state {
        case .on:
            mods.background = backgroundColor.color
        case .off:
            mods.background = nil
        default:
            print("ERR: Wrong Button State")
        }
    }

    @IBAction func backgroundColorSelected(_: Any) {
        backgroundToggled(self)
    }

    // Scale
    var shiftCount = 0
    @IBAction func scaleSelected(_: Any) {
        // limit triggers
        shiftCount += 1
        if Storage.preferences.continuousPreview, shiftCount % 2 == 0 {
            return
        }

        mods.scale = CGFloat(scaleSlider.doubleValue)
        scaleText.stringValue = scaleSlider.doubleValue.description
    }

    @IBAction func resetScale(_: Any) {
        mods.scale = 100
        scaleSlider.doubleValue = 100
        scaleText.stringValue = "100"
    }

    @IBAction func scaleTyped(_: Any) {
        guard let num = Double(scaleText.stringValue) else {
            return
        }

        if num <= 10 {
            scaleText.stringValue = "10"
            mods.scale = 10
            scaleSlider.doubleValue = 10
        } else if num > 200 {
            scaleText.stringValue = "200"
            mods.scale = 200
            scaleSlider.doubleValue = 200
        } else {
            mods.scale = CGFloat(num)
            scaleSlider.doubleValue = num
        }
    }

    // Shift
    @objc func shiftSelected(_: Any) {
        let shift = shiftSelector.position
        mods.shift = shift
        shiftXText.stringValue = shift.x.description
        shiftYText.stringValue = shift.y.description
    }

    @IBAction func resetShift(_: Any) {
        mods.shift = .zero
        shiftSelector.position = .zero
        shiftXText.stringValue = "0"
        shiftYText.stringValue = "0"
    }

    @IBAction func shiftXTyped(_: Any) {
        guard let num = Double(shiftXText.stringValue) else {
            return
        }

        if num < -100 {
            shiftXText.stringValue = "-100"
            mods.shift.x = -100
        } else if num > 100 {
            shiftXText.stringValue = "100"
            mods.shift.x = 100
        } else {
            mods.shift.x = CGFloat(num)
        }

        shiftSelector.position = mods.shift
    }

    @IBAction func shiftYTyped(_: Any) {
        guard let num = Double(shiftYText.stringValue) else {
            return
        }

        if num < -100 {
            shiftYText.stringValue = "-100"
            mods.shift.y = -100
        } else if num > 120 {
            shiftYText.stringValue = "100"
            mods.shift.y = 100
        } else {
            mods.shift.y = CGFloat(num)
        }

        shiftSelector.position = mods.shift
    }

    // Round
    @IBAction func roundSelected(_: Any) {
        mods.rounding = CGFloat(roundSlider.doubleValue)
        roundText.stringValue = roundSlider.doubleValue.description
    }

    @IBAction func resetRound(_: Any) {
        mods.rounding = 0
        roundSlider.doubleValue = 0
        roundText.stringValue = "0"
    }

    @IBAction func roundTyped(_: Any) {
        guard let num = Double(roundText.stringValue) else {
            return
        }

        if num < 0 {
            roundText.stringValue = "0"
            mods.rounding = 0
            roundSlider.doubleValue = 0
        } else if num > 100 {
            roundText.stringValue = "100"
            mods.rounding = 100
            roundSlider.doubleValue = 100
        } else {
            mods.rounding = CGFloat(num)
            roundSlider.doubleValue = num
        }
    }

    // Padding
    @IBAction func paddingSelected(_: Any) {
        mods.padding = CGFloat(paddingSlider.doubleValue)
        paddingText.stringValue = paddingSlider.doubleValue.description
    }

    @IBAction func resetPadding(_: Any) {
        mods.padding = 0
        paddingSlider.doubleValue = 0
        paddingSlider.stringValue = "0"
    }

    @IBAction func paddingTyped(_: Any) {
        guard let num = Double(paddingText.stringValue) else {
            return
        }

        if num < 0 {
            paddingText.stringValue = "0"
            mods.padding = 0
            paddingSlider.doubleValue = 0
        } else if num > 75 {
            paddingText.stringValue = "75"
            mods.padding = 75
            paddingSlider.doubleValue = 75
        } else {
            mods.padding = CGFloat(num)
            paddingSlider.doubleValue = num
        }
    }

    // Prefix
    @IBAction func prefixTextEdited(_: Any) {
        let prefix = prefixTextBox.stringValue
        prefixPreview.stringValue = "Ex: \(prefix)root.type"
    }
}
