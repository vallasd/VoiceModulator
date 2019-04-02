//
//  NSNavigationController.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/16/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

/// structure that allows a user to create a board.
struct BoardData {
    let storyboard: String
    let nib: String
    let context: AnyObject?
}

enum BoardLocation {
    case bottomLeft
    case bottomCenter
}

/// structure that allows a user to create a board.
enum NavAction {
    case none
    case pop
    case end
    case home
}

// types that increase stack depth
enum ProgressionType {
    
    case next
    case finished
    
    init(int: Int) {
        switch int {
        case 900: self = .next
        case 901: self = .finished
        default:
            HGReport.shared.report("Int: |\(int)| is not ProgressionType mapable, returning .Next", type: .error)
            self = .next
        }
    }
    
    var string: String {
        switch self {
        case .next: return "Next"
        case .finished: return "Finished"
        }
    }
    
    var int: Int {
        switch self {
        case .next: return 900
        case .finished: return 901
        }
    }
    
    static func isValid(_ tag: Int) -> Bool {
        if tag == 900 || tag == 901 { return true }
        return false
    }
}

// types that decrease stack depth
enum RegressionType {
    
    case cancel
    case back
    case home
    
    init(int: Int) {
        switch int {
        case 800: self = .cancel
        case 801: self = .back
        case 802: self = .home
        default:
            HGReport.shared.report("Int: |\(int)| is not RegressionType mapable, returning .Cancel", type: .error)
            self = .cancel
        }
    }
    
    var string: String {
        switch self {
        case .cancel: return "Cancel"
        case .back: return "Back"
        case .home: return "Home"
        }
    }
    
    var int: Int {
        switch self {
        case .cancel: return 800
        case .back: return 801
        case .home: return 802
        }
    }
    
    static func isValid(_ tag: Int) -> Bool {
        if tag >= 800 && tag <= 802 { return true }
        return false
    }
}

// MARK: BoardNav Protocols

/// protocol that allows a board to be instantiated from a NIB
protocol BoardInstantiable {
    static var storyboard: String { get }
    static var nib: String { get }
}

extension BoardInstantiable {
    static var boardData: BoardData { return BoardData(storyboard: self.storyboard, nib: self.nib, context: nil) }
    static func boardData(withContext context: AnyObject) -> BoardData { return BoardData(storyboard: self.storyboard, nib: self.nib, context: context) }
}

/// protocol that allows a board to be set or retrieved
protocol BoardRetrievable: BoardInstantiable {
    func contextForBoard() -> AnyObject
    func set(context: AnyObject)
}

extension BoardRetrievable {
    func boardData() -> BoardData { return BoardData(storyboard: type(of: self).storyboard, nib: type(of: self).nib, context: contextForBoard()) }
}

/// protocol which allows object to define the nav controller regression buttons.  [CANCEL || BACK] will be used as Cancel.  If two buttons are used, Nav Controller will not use progression buttons.  Note, by default, the Nav Controller will assume that the user wants a CANCEL button.
protocol NavControllerRegressable {
    func navcontrollerRegressionTypes(_ nav: NavController) -> [RegressionType]
    func navcontroller(_ nav: NavController, hitRegressWithType: RegressionType)
}

/// protocol which allows object to define the nav controller progression buttons.  If FINISHED is defined, nav controller will auto dismiss itself after hitProgressWithType is called.  If NEXT is defined, object conforming to protocol needs to push the next Board Info when hitProgressWithType is called.
protocol NavControllerProgessable {
    func navcontrollerProgressionType(_ nav: NavController) -> ProgressionType
    func navcontroller(_ nav: NavController, hitProgressWithType progressionType: ProgressionType)
}

/// protocol that allows a Nav Controller's NSViewController to gain reference to the nav controller when it is added to the stack.
protocol NavControllerReferable {
    var nav: NavController? { get set }
}

/// protocol that allows another object to handle delegation methods from nav controller (like dismiss)
protocol NavControllerDelegate: AnyObject {
    func navcontrollerShouldDismiss(_ nav: NavController)
    func navcontrollerRect() -> CGRect
}

class NavController: NSViewController {
    
    // MARK: Variables
    
    @IBOutlet weak var container: NSView!
    @IBOutlet weak var buttonA: NSButton!
    @IBOutlet weak var buttonB: NSButton!
    @IBOutlet var AConstraint: NSLayoutConstraint!
    @IBOutlet var BConstraint: NSLayoutConstraint!
    
    weak var delegate: NavControllerDelegate?
    
    /// board data that should be loaded when viewDidLoad is called.  Set this and the initial controller will be pushed at the appropriate time
    var loadData: BoardData?
    
    /// reference to the current view controller being displayed
    var currentVC: NSViewController? = nil
    
    /// stack that holds references to the BoardData
    fileprivate(set) var boardStack: [BoardData] = []
    
    /// tells us if this is the first View Controller in the Navigation Controller
    var onRootVC: Bool { return boardStack.count == 1 ? true : false }
    
    // MARK: Public functions

    /// enables the ability for the navigation controller to progress forward (Finish or Next)
    func disableProgression() {
        if ProgressionType.isValid(buttonA.tag) { buttonA.isEnabled = false }
        if ProgressionType.isValid(buttonB.tag) { buttonB.isEnabled = false }
    }
    
    /// disables the ability for the navigation controller to progress forward (Finish or Next)
    func enableProgression() {
        if ProgressionType.isValid(buttonA.tag) { buttonA.isEnabled = true }
        if ProgressionType.isValid(buttonB.tag) { buttonB.isEnabled = true }
    }
    
    /// pushes new boardType onto stack.  Do not use this for the first board, just set loadData for first board.
    func push(_ boardData: BoardData) {
        saveCurrentBoardContext()
        removeTopView()
        boardStack.append(boardData)
        setCurrentVC(withBoardData: boardData)
        updateButtons()
        addTopView()
    }
    
    /// pops the top most view controller from the navigation controller, if the stack is empty, ends() the navigation controller
    func pop() {
        
        if onRootVC {
            end()
            return
        }
        
        // pop from stack
        removeTopView()
        boardStack.removeLast()
        setCurrentVC(withBoardData: boardStack.last!)
        updateButtons()
        addTopView()
    }
    
    /// attempts to remove the navigation controller from the screen.  A call is made to the nav controller delegates that the controller wants to be dismissed.
    func end() {
        boardStack.removeAll()
        currentVC?.view.removeFromSuperview()
        currentVC = nil
        delegate?.navcontrollerShouldDismiss(self)
    }
    
    func home() {
        print("NOT IMPLEMENTED YET")
    }
    
    /// action that is run when back button is pressed.  Will pop top controller from stack.  If last controller, dismisses nav controller
    @IBAction func buttonPressed(_ sender: NSButton) {
        
        let tag = sender.tag
        
        if ProgressionType.isValid(tag) {
            
            // define ProgressionType and Notify currentVC if it is NavControllerProgessable
            let type = ProgressionType(int: tag)
            
            if let vc = currentVC as? NavControllerProgessable {
                vc.navcontroller(self, hitProgressWithType: type)
            }
            
            switch type {
            case .next: break
            case .finished: end()
            }
        }
        
        if RegressionType.isValid(tag) {
            
            // define ProgressionType and Notify currentVC if it is NavControllerProgessable
            let type = RegressionType(int: tag)
            
            if let vc = currentVC as? NavControllerRegressable {
                vc.navcontroller(self, hitRegressWithType: type)
            }
            
            switch type {
            case .cancel: end()
            case .back: pop()
            case .home: home()
            }
        }
    }
    
    /// creates NSViewController from a board type.  Sets delegates as appropriate.
    fileprivate func setCurrentVC(withBoardData boardData: BoardData) {
        
        // create and assign new currentVC
        let storyboard = NSStoryboard(name: NSStoryboard.Name(boardData.storyboard), bundle: nil)
        currentVC = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(boardData.nib)) as? NSViewController
        
        // check success of VC instantiation from nib
        if currentVC == nil {
            HGReport.shared.report("Nav Controller, currentVC was not properly instantiated from BoardData", type: .error)
            return
        }
        
        // update context if necessary
        if let context = boardData.context {
            if let saveableVC = currentVC as? BoardRetrievable {
                saveableVC.set(context: context)
            } else {
                HGReport.shared.report("Nav Controller, attempting to set context for NSViewController that is not BoardRetrievable", type: .error)
            }
        }
        
        // assign nav reference to NavControllerReferable
        if var ncr = currentVC as? NavControllerReferable {
            ncr.nav = self
        }
    }
    
    /// removes top view from container
    fileprivate func removeTopView() {
        currentVC?.view.removeFromSuperview()
    }
    
    /// adds top view to container
    fileprivate func addTopView() {
        if let view = currentVC?.view {
            view.resize(inParent: container)
        }
    }
    
    // MARK: Navigation State Persistence
    
    func saveCurrentBoardContext() {
        if let vc = currentVC as? BoardRetrievable {
            let vcIndex = boardStack.count - 1
            boardStack[vcIndex] = vc.boardData()
        }
    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        
        // make background transparent
        view.backgroundColor(HGColor.clear)
        
        // load initial data for the Nav Controller
        if let ld = loadData { push(ld) }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        currentVC?.view.resize(inParent: container)
        
        // add background panel
        view.addPanel(insets: 10)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        boardStack.removeAll()
    }
}

// MARK: Button Update

extension NavController {
    
    /// top level update Button Titles that handles all cases
    fileprivate func updateButtons() {
        
        // performs multiple analysis to determine the proper buttons to be displayed on nav controller
        updateButtonsForBoard()
        
        // enables progression on buttons
        enableProgression()
    }
    
    /// updates button titles and display based on multiple aspects that affect the state of the nav controller.  The Nav controller has two buttons (A and B), we assign them tasks, maybe hide them, depending on what the nav controller delegates (NavControllerProgessable / NavControllerRegressable) tells us to do.
    fileprivate func updateButtonsForBoard() {
        
        // tags to be used on buttons, currently set to 0
        var atag = 0
        var btag = 0
        
        // determine progression and regression types asked from currentVC
        let progressVC = currentVC as? NavControllerProgessable
        let regressVC = currentVC as? NavControllerRegressable
        let progressType = progressVC?.navcontrollerProgressionType(self)
        let regressTypes = regressVC?.navcontrollerRegressionTypes(self)
        
        let asksNext = progressType == .next ? true : false
        let asksFinished = progressType == .finished ? true : false
        
        var asksCancel = true // default is for a cancel button
        var asksHome = false
        
        if let rt = regressTypes {
            asksCancel = rt.contains(.cancel) || rt.contains(.back) ? true : false
            asksHome = rt.contains(.home) ? true : false
        }
        
        // we determine four possible button types that could be needed (at most 2 of 4 will be needed because these are two mutually exclusive sets)
        let needsBack = !onRootVC
        let needsFinish = asksFinished ? true : false
        let needsNext = asksNext ? true : false
        let needsCancel = asksCancel && !needsBack
        let needsHome = asksHome && !onRootVC
        
        // needsBack and needsCancel are mutually exclusive and tags are always assigned to buttonA if they are needed
        if needsBack { atag = RegressionType.back.int }
        if needsCancel { atag = RegressionType.cancel.int }
        
        // check if we need HOME
        if atag == 0 && needsHome { atag = RegressionType.home.int }
        else if btag == 0 && needsHome { btag = RegressionType.home.int }
        
        // needsFinish and needsNext are mutually exclusive and tags are are assigned to first available button ( A if available or B ).  Not if we already used two regressions (like back and home), we will not have a button for a Progression (we allow just two buttons)
        if atag == 0 {
            if needsFinish { atag = ProgressionType.finished.int }
            if needsNext { atag = ProgressionType.next.int }
        } else if btag == 0 {
            if needsFinish { btag = ProgressionType.finished.int }
            if needsNext { btag = ProgressionType.next.int }
        }
        
        // hide buttons that did not get new types, else make sure they are unhidden
        buttonA.isHidden = atag == 0 ? true : false
        buttonB.isHidden = btag == 0 ? true : false
        
        // set titles and tags for buttons that are not hidden
        if atag != 0 { buttonA.title = string(fromTag: atag); buttonA.tag = atag }
        if btag != 0 { buttonB.title = string(fromTag: btag); buttonB.tag = btag }
        
        // if there are two buttons (we have a btype) - move buttonA left, else move buttonA center *** buttonB always stays right
        if btag == 0 { buttonACenter() }
        else { buttonALeft() }
    }
    
    
    /// creates a string given the tag number presented
    func string(fromTag tag: Int) -> String {
    
        if ProgressionType.isValid(tag) {
            return ProgressionType(int: tag).string
        }
        if RegressionType.isValid(tag) {
            return RegressionType(int: tag).string
        }
        
        HGReport.shared.report("\(tag) is Not A Regression or Progression Type Tag", type: .error)
        return ""
    }

    
}


// MARK: Determine Button Locations

extension NavController {
    
    /// sets buttonA button on left side on nav controller
    fileprivate func buttonALeft() {
        self.view.removeConstraint(AConstraint)
        AConstraint = NSLayoutConstraint(item: buttonA, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20.0)
        self.view.addConstraint(AConstraint)
    }
    
    /// sets buttonA in center of nav controller
    fileprivate func buttonACenter() {
        self.view.removeConstraint(AConstraint)
        AConstraint = NSLayoutConstraint(item: buttonA, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0.0)
        self.view.addConstraint(AConstraint)
    }
    
}


