//
//  TableSelectionBoard.swift
//  VoiceModulator
//
//  Created by David Vallas on 9/3/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

protocol SelectionBoardDelegate: HGTableDisplayable {
    var selectionBoard: SelectionBoard? { get set }
    func selectionboard(_ sb: SelectionBoard, didChooseLocation loc: HGTableLocation)
}

protocol SelectionBoardNoSelectionDelegate: HGTableDisplayable {
    func selectionBoardDidNotChooseLocation(_ sb: SelectionBoard)
}

/// Board that allows class to select
class SelectionBoard: NSViewController, NavControllerReferable {
    
    /// function that updates the selection board
    func update() {
        hgtable.update()
    }
    
    /// will make SelectionBoard finish or move to next without a field selected.
    var automaticNext = false {
        didSet {
            updateProgression()
        }
    }
    
    /// reference to the HGTable
    var hgtable: HGTable!
    
    /// This object is the context that handle delegation of the Selection Board and HGTable
    fileprivate var context: SelectionBoardDelegate? { didSet { loadSelectionBoardIfReady() } }
    
    /// This object lets delegate know if nothing was selected
    fileprivate var noSelectionDelegate: SelectionBoardNoSelectionDelegate?
    
    /// the default progression is to finish.  If we want to implement a Next progression, we would need a boardData for the next controller (need to implement this logic later if needed *** nextData for selectionBoard, handled by delegate.
    fileprivate var progressionType: ProgressionType = .finished
    
    @IBOutlet fileprivate weak var boardtitle: NSTextField!
    @IBOutlet fileprivate weak var tableview: HGTableView?
    
    /// NavControllerReferable
    weak var nav: NavController?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // HGTable is dependent on Tableview size when loading, we want to make sure that the tableview is layed out initially before setting HGTable
        loadSelectionBoardIfReady()
        updateProgression()
    }
    
    fileprivate func updateProgression() {
        if automaticNext { nav?.enableProgression() }
        else if hgtable.selectedLocation != nil { nav?.enableProgression() }
        else { nav?.disableProgression() }
    }
    
    fileprivate func loadSelectionBoardIfReady() {
    
        // check if not ready and return if so
        if context == nil || tableview == nil {
            return
        }
        
        // load context and init hgtable
        context!.selectionBoard = self
        hgtable = HGTable(tableview: tableview!, delegate: context!, selectionTrackingDelegate: self)
    }
    
}

extension SelectionBoard: BoardInstantiable {
    
    static var storyboard: String { return "Board" }
    static var nib: String { return "SelectionBoard" }
}

extension SelectionBoard: BoardRetrievable {
    
    
    func contextForBoard() -> AnyObject {
        return context!
    }
    
    
    func set(context: AnyObject) {
        
        // optional delegate for selection board
        if let delegate = context as? SelectionBoardNoSelectionDelegate {
            self.noSelectionDelegate = delegate
        }
        
        // assign context if it is of type SelectionBoardDelegate
        if let context = context as? SelectionBoardDelegate {
            self.context = context;
            return
        }
        
        HGReport.shared.report("selection board context |\(context)| not valid", type: .error)
    }
}

extension SelectionBoard: NavControllerProgessable {
    
    func navcontrollerProgressionType(_ nav: NavController) -> ProgressionType {
        return progressionType
    }
    
    func navcontroller(_ nav: NavController, hitProgressWithType: ProgressionType) {
        if let loc = hgtable.selectedLocation {
            context?.selectionboard(self, didChooseLocation: loc)
        } else {
            noSelectionDelegate?.selectionBoardDidNotChooseLocation(self)
        }
    }
}

extension SelectionBoard: HGTableSelectionTrackable {
    
    func hgtable(_ table: HGTable, selectedLocationChangedTo: HGTableLocation) {
        updateProgression()
    }
    
    func hgtableLocationDeselected(_ table: HGTable) {
        updateProgression()
    }
}



