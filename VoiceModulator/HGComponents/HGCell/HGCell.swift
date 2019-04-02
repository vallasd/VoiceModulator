//
//  HGCell.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/3/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

enum Option {
    case yes
    case no
    case askUser // Will Display a Prompt
}

enum HGLocationType: Int16 {
    case field
    case image
    case check
    case row
}

struct HGTableLocation {
    let index: Int
    let type: HGLocationType
    let typeIndex: Int
}

extension HGTableLocation: Equatable {
    static func == (lhs: HGTableLocation, rhs: HGTableLocation) -> Bool {
        return
            lhs.index == rhs.index &&
            lhs.type == rhs.type &&
            lhs.typeIndex == rhs.typeIndex
    }
}

protocol HGCellDelegate: AnyObject {
    func hgcell(_ cell: HGCell, shouldSelectTypeIndex index: Int, type: HGLocationType) -> Bool
    func hgcell(_ cell: HGCell, didSelectTypeIndex index: Int, type: HGLocationType)
    func hgcell(_ cell: HGCell, shouldEditField field: Int) -> Bool
    func hgcell(_ cell: HGCell, didEditField field: Int, withString string: String)
}

let HGCellImageBorder: CGFloat = 2.0

class HGCell: NSTableCellView, NSTextFieldDelegate {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var image0: NSButton?
    
    @IBOutlet weak var field0: NSTextField?
    @IBOutlet weak var field1: NSTextField?
    @IBOutlet weak var field2: NSTextField?
    @IBOutlet weak var field3: NSTextField?
    @IBOutlet weak var field4: NSTextField?
    @IBOutlet weak var field5: NSTextField?
    @IBOutlet weak var field6: NSTextField?
    @IBOutlet weak var field7: NSTextField?
    
    @IBOutlet weak var check0: NSButton?
    @IBOutlet weak var check1: NSButton?
    @IBOutlet weak var check2: NSButton?
    @IBOutlet weak var check3: NSButton?
    
    weak var delegate: HGCellDelegate?
    
    fileprivate(set) var row: Int = 0
    
    /// special variable used when HGCellData is images only
    fileprivate var imagesCellHas: Int = 0
    fileprivate var shouldUpdateConstraintsForImageCells = false
    fileprivate var spacers: [NSView] = []
    
    /// ordered array of images for HGCell
    lazy var images: [NSButton?] = {
        
        let _images = [image0]
        
        var index = 0
        for image in _images {
            set(imagebutton: image, withTag: index)
            index += 1
        }
        
        return _images
    }()
    
    /// ordered array of fields for HGCell
    lazy var fields: [NSTextField?] = {
        let _fields = [field0, field1, field2, field3, field4, field5, field6, field7]
        for index in 0...7 {
            set(field: _fields[index], withTag: index)
        }
        return _fields
    }()
    
    /// ordered array of checks for HGCell
    lazy var checks: [NSButton?] = {
        let _checks = [check0, check1, check2, check3]
        for index in 0...3 {
            set(checkbutton: _checks[index], withTag: index)
        }
        return _checks
    }()
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// updates images, fields, and checks of HGCell with HGCellData
    func update(withRow row: Int, cellData: HGCellData) {
        
        // update row tag
        self.row = row
        
        // Update and/or Clear Fields
        if cellData.numImages > 0 { create(numImages: cellData.numImages) }
        update(withData: cellData.fields)
        disable(missingData: cellData.fields)
        
        // Update and/or Clear Images
        update(withData: cellData.images)
        disable(missingData: cellData.images)
        
        // Update and/or Clear Checks
        update(withData: cellData.checks)
        disable(missingData: cellData.checks)
    }
    
    // MARK: Button and Field Target Actions
    
    /// function called when user selects an image
    @objc func didSelectImage(_ sender: NSButton!) {
        // We can not select an image in HGCell
        let shouldSelect = delegate?.hgcell(self, shouldSelectTypeIndex: sender.tag, type: .image) ?? false
        if shouldSelect == true {
            delegate?.hgcell(self, didSelectTypeIndex: sender.tag, type: .image)
        }
    }
    
    /// function called when user selects an check button
    @objc func didSelectCheck(_ sender: NSButton!) {
        delegate?.hgcell(self, didSelectTypeIndex: sender.tag, type: .check)
    }
    
    /// function called when a user selects a field (if field is selectable)
    @objc func didSelectField(_ sender: NSTextField!) {
        delegate?.hgcell(self, didSelectTypeIndex: sender.tag, type: .field)
    }
    
    /// unhighlights all images in cell
    func unhighlightImages() {
        for image in images {
            image?.backgroundColor(HGColor.clear)
        }
    }
    
    /// unhighlights image at index, 0 being left most for imageCell
    func unhighlight(imageIndex index: Int) {
        if let image = images[index] {
            image.backgroundColor(HGColor.clear)
        }
    }
    
    /// highlights image at index, 0 being left most for imageCell
    func highlight(imageIndex index: Int) {
        if let image = images[index] {
            image.backgroundColor(HGColor.blueBright)
        }
    }
    
    // MARK: Set Fields and Buttons
    
    /// sets field with approprate tag and delegate
    fileprivate func set(field: NSTextField?, withTag tag: Int) {
        guard let field = field else { return }
        field.delegate = self
        field.tag = tag
    }
    
    /// sets image with approprate tag and action
    fileprivate func set(imagebutton button: NSButton?, withTag tag: Int) {
        guard let button = button else { return }
        button.image = nil
        button.target = self
        button.action = #selector(HGCell.didSelectImage(_:))
        button.tag = tag
    }
    
    /// set check with appropriate tag and target
    fileprivate func set(checkbutton button: NSButton?, withTag tag: Int) {
        guard let button = button else { return }
        button.target = self
        button.action = #selector(HGCell.didSelectCheck(_:))
        button.tag = tag
    }
    
    // MARK: Update Cell Data
    
    /// Updates fields with HGFieldData (assumes [HGFieldData] is correctly ordered)
    fileprivate func update(withData data: [HGFieldData]) {
        let maxCount = min(data.count, fields.count)
        for index in 0 ..< maxCount {
            update(field: fields[index], withData: data[index])
        }
    }
    
    /// Updates images with HGImageData (assumes [HGImageData] is correctly ordered)
    fileprivate func update(withData data: [HGImageData]) {
        let maxCount = min(data.count, images.count)
        for index in 0 ..< maxCount {
            update(image: images[index], withData: data[index])
        }
    }
    
    /// Updates checks with HGCheckData (assumes [HGCheckData] is correctly ordered)
    fileprivate func update(withData data: [HGCheckData]) {
        let maxCount = min(data.count, checks.count)
        for index in 0 ..< maxCount {
            update(check: checks[index], withData: data[index])
        }
    }
    
    /// Updates a field with appropriate HGFieldData and makes field ready for custom display
    fileprivate func update(field: NSTextField?, withData data: HGFieldData) {
        guard let field = field else { return }
        field.stringValue = data.title
        field.isEnabled = true
        field.isHidden = false
        selectionSetup(field: field)
    }
    
    /// Updates an image with appropriate HGImageData and makes image ready for custom display
    fileprivate func update(image: NSButton?, withData data: HGImageData) {
        
        guard let image = image else { return }
        
        /// If image is returned, use that, else, try to use title.
        if let dataImage = data.image {
            image.image = dataImage
        } else {
            image.image = NSImage(named: NSImage.Name(data.title))
        }
        
        image.isEnabled = true
        image.isHidden = false
    }
    
    /// Updates an check with appropriate HGCheckData and makes check ready for custom display
    fileprivate func update(check: NSButton?, withData data: HGCheckData) {
        guard let check = check else { return }
        check.title = data.title
        check.state = NSControl.StateValue(rawValue: data.state == true ? 1 : 0)
        check.isEnabled = true
        check.isHidden = false
        selectionSetup(check: check)
    }
    
    // MARK: Disable Cells
    
    /// Disables fields that do not have cooresponding HGFieldData (assumes [HGFieldData] is correctly ordered)
    fileprivate func disable(missingData data: [HGFieldData]) {
        if data.count < fields.count {
            for index in data.count ..< fields.count {
                disable(field: fields[index])
            }
        }
    }
    
    /// Disables images that do not have cooresponding HGImageData (assumes [HGImageData] is correctly ordered)
    fileprivate func disable(missingData data: [HGImageData]) {
        if data.count < images.count {
            for index in data.count ..< images.count {
                disable(image: images[index])
            }
        }
    }
    
    /// Disables checks that do not have cooresponding HGCheckData (assumes [HGCheckData] is correctly ordered)
    fileprivate func disable(missingData data: [HGCheckData]) {
        if data.count < checks.count {
            for index in data.count ..< checks.count {
                disable(check: checks[index])
            }
        }
    }
    
    /// Disables field so that it will not be used by the HGCell
    fileprivate func disable(field: NSTextField?) {
        
        guard let field = field else { return }
        
        field.stringValue = ""
        field.isEnabled = false
        field.isHidden = true
        field.isEditable = false
        removeSelectFieldButton(field: field)
    }
    
    /// Disables image so that it will not be used by the HGCell
    fileprivate func disable(image: NSButton?) {
        
        guard let image = image else { return }
        
        image.title = ""
        image.image = nil
        image.isEnabled = false
        image.isHidden = true
    }
    
    /// Disables check so that it will not be used by the HGCell
    fileprivate func disable(check: NSButton?) {
        
        guard let check = check else { return }
        
        check.title = ""
        check.state = NSControl.StateValue(rawValue: 0)
        check.isEnabled = false
        check.isHidden = true
    }
    
    // MARK: Create image buttons for ImageCell
    
    /// creates image buttons for this view, this function
    fileprivate func create(numImages: Int) {
        
        // if the numImages are the same, we will just reuse the cell
        if numImages == imagesCellHas {
            unhighlightImages()
            return
        }
        
        // set imagesCellHas, we will create them below
        imagesCellHas = numImages
        
        // remove all subviews from the cell, we start clean
        let _ = self.subviews.map { $0.removeFromSuperview() }
        
        // array of image buttons
        var images: [NSButton] = []
        
        // append images with properly set image buttons
        for tag in 0..<numImages {
            let button = NSButton.imageButton
            images.append(button)
            set(imagebutton: button, withTag: tag)
            self.addSubview(button)
        }
        
        // create spacers, that will go between images
        spacers = []
        for _ in 0..<numImages - 1 {
            let spacer = NSView.spacer
            self.addSubview(spacer)
            spacers.append(spacer)
        }
        
        // we will need to update the constraints at a later time
        shouldUpdateConstraintsForImageCells = true
        
        // set HGCell variable images
        self.images = images
        
        updateConstraints()
    }
    
    override func updateConstraints() {

        // we don't need to update any constraints
        if shouldUpdateConstraintsForImageCells == false || self.images.count == 0 {
            super.updateConstraints()
            return
        }
        
        // set check to false since we are updating constraints
        shouldUpdateConstraintsForImageCells = false
        
        // get image buttons
        let images = self.images as! [NSButton]
        
        // add top, bottom, aspect ratio to image buttons
        var index = 0
        for image in images {
            self.addConstraints([NSLayoutConstraint.bottom(view: image, superView: self, spacing: HGCellImageBorder),
                                 NSLayoutConstraint.top(view: image, superView: self, spacing: HGCellImageBorder)
                ])
            image.addConstraint(NSLayoutConstraint.aspectRatio(view: image, ratio: 1.0))
            index += 1
        }
        
        // add leading constraint
        let first = images.first!
        self.addConstraint(NSLayoutConstraint.leading(view: first, superView: self, spacing: HGCellImageBorder))
        
        // if we only had one image we are done
        if images.count == 1 {
            super.updateConstraints()
            return
        }
        
        // add trailing constraint
        let last = images.last!
        self.addConstraint(NSLayoutConstraint.trailing(view: last, superView: self, spacing: HGCellImageBorder))
        
        // update spacers
        index = 0
        for spacer in spacers {
            let left = images[index]
            let right = images[index + 1]
            self.addConstraints([NSLayoutConstraint.horizontal(left: left, right: spacer, spacing: 0),
                                 NSLayoutConstraint.horizontal(left: spacer, right: right, spacing: 0),
                                 NSLayoutConstraint.bottom(view: spacer, superView: self, spacing: HGCellImageBorder),
                                 NSLayoutConstraint.top(view: spacer, superView: self, spacing: HGCellImageBorder)
                ])
            
            if index > 0 {
                let left = spacers[index - 1]
                let c = NSLayoutConstraint.width(view: spacer, toView: left, multipler: 1)
                self.addConstraint(c)
            }
            
            index += 1
        }
        
        super.updateConstraints()
    }
    
    // MARK: Field Select Button
    
    fileprivate func selectionSetup(check: NSButton) {
        
        let shouldSelect = delegate?.hgcell(self, shouldSelectTypeIndex: check.tag, type: .check) ?? false
        
        if shouldSelect {
            check.isEnabled = true
            return
        }
        
        check.isEnabled = false
    }
    
    /// Sets up appropriate field selection button, edit ability, and field text color for a field by polling delegate
    fileprivate func selectionSetup(field: NSTextField) {
        
        let shouldSelect = delegate?.hgcell(self, shouldSelectTypeIndex: field.tag, type: .field) ?? false
        
        // Selectable Field
        if shouldSelect {
            field.isEditable = false
            field.textColor = NSColor.blue
            addSelectFieldButton(field: field)
            return
        }
        
        let shouldEdit = delegate?.hgcell(self, shouldEditField: field.tag) ?? false
        
        // Editable Field
        if shouldEdit {
            field.isEditable = true
            field.textColor = NSColor.blue
            updateSpecialType(forField: field)
            removeSelectFieldButton(field: field)
            return
        }
        
        // Not Selectable or Editable Field (Just Displayable)
        field.isEditable = false
        field.textColor = NSColor.black
        removeSelectFieldButton(field: field)
    }
    
    /// update specials data for special types
    func updateSpecialType(forField field: NSTextField) {
        // FIXME: need to fix, current not handling special types
        // guard let stype = SpecialAttribute.specialTypeFrom(varRep: field.stringValue) else { return }
        // field.textColor = stype.color
        // image0?.image  = stype.image
    }
    
    /// Returns the appropriate field selection button for a field if it exists
    fileprivate func selectFieldButton(field: NSTextField) -> NSButton? {
        for view in field.subviews {
            if let view = view as? NSButton, view.tag == field.tag { return view }
        }
        return nil
    }
    
    /// Adds a field selection button for a field
    fileprivate func addSelectFieldButton(field: NSTextField) {
        if selectFieldButton(field: field) != nil { return }
        let frame = NSRect(x: 0, y: 0, width: field.frame.width, height: field.frame.height)
        let button = NSButton(frame: frame)
        button.tag = field.tag
        button.title = ""
        button.alphaValue = 0.1 // Hides button but it is still functional
        button.action = #selector(HGCell.didSelectField(_:))
        button.target = self
        field.addSubview(button)
    }
    
    /// Removes a field selection button from the field if the button exists
    fileprivate func removeSelectFieldButton(field: NSTextField) {
        let button = selectFieldButton(field: field)
        button?.removeFromSuperview()
    }
    
    // MARK: NSTextFieldDelegate

    /// Returns a call to delegate to let the delegate know that the field was edited once editing is done
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let string = fieldEditor.string
        
        // update color in a bit
        delay(0.2) {
            [weak self] in
            guard let field = self?.fields[control.tag] else { return }
            self?.selectionSetup(field: field)
        }
        
        // call delegate in a bit
        delay(0.1) {
            [weak self] in
            self?.delegate?.hgcell(self!, didEditField: control.tag, withString: string)
        }
        
        return true
    }
    
}
