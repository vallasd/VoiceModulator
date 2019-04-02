//
//  DecisionBoard.swift
//  VoiceModulator
//
//  Created by David Vallas on 10/26/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Cocoa

protocol DecisionBoardDelegate: AnyObject {
    func decisionboardQuestion(_ db: DecisionBoard) -> String
    func decisionboard(_ db: DecisionBoard, didChoose: Bool)
}

/// lets DecisionBoardDelegate decide what action to perform after DidChoose is called.  Default is .End, so implement this protocol if you want the Decision Board to do something else besides remove itself
protocol DecisionBoardDelegateProgressable: DecisionBoardDelegate {
    func decisionboardNavAction(_ db: DecisionBoard) -> NavAction
}

/// lets DecisionBoardDelegate display options with a cancel button
protocol DecisionBoardDelegateCancelable: DecisionBoardDelegate {
    func decisionboardCanCancel(_ db: DecisionBoard) -> Bool
}

class DecisionBoard: NSViewController, NavControllerReferable {
    
    /// a context that will allow the Decision Board to execute
    fileprivate var context: DecisionBoardDelegate! {
        didSet {
            if let c = context as? DecisionBoardDelegateProgressable { contextProgressable = c }
            if let c = context as? DecisionBoardDelegateCancelable { contextCancelable = c }
        }
    }
    
    fileprivate weak var contextProgressable: DecisionBoardDelegateProgressable?
    fileprivate weak var contextCancelable: DecisionBoardDelegateCancelable?
    
    /// reference to the Nav Controller
    weak var nav: NavController?
    
    /// the text field that contains the decision question posed to the user ( like ... Do you want to delete items? )
    @IBOutlet weak var question: NSTextField!
    
    @IBAction func yesPressed(_ sender: NSButton) {
        context?.decisionboard(self, didChoose: true)
        performAction()
    }
    
    @IBAction func noPressed(_ sender: NSButton) {
        context?.decisionboard(self, didChoose: false)
        performAction()
    }
    
    fileprivate func performAction() {
        
        /// default action is End if we do not have a DecisionBoardDelegateCancelable delegate.
        let navAction = contextProgressable?.decisionboardNavAction(self) ?? .end
        
        switch navAction {
        case .end: nav?.end()
        case .pop: nav?.pop()
        case .home: nav?.home()
        default: break // do nothing
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // load question to board from the delegate
        let dQuestion = context.decisionboardQuestion(self)
        question.stringValue = dQuestion
    }
}

extension DecisionBoard: BoardInstantiable {
    
    static var storyboard: String { return "Board" }
    static var nib: String { return "DecisionBoard" }
}

extension DecisionBoard: BoardRetrievable {
    
    func contextForBoard() -> AnyObject { return context }
    
    func set(context: AnyObject) {
        // assign context if it is of type DecisionBoard
        if let c = context as? DecisionBoardDelegate { self.context = c; return }
        HGReport.shared.report("DecisionBoard Context \(context) not valid", type: .error)
    }
}

extension DecisionBoard: NavControllerRegressable {
    
    func navcontrollerRegressionTypes(_ nav: NavController) -> [RegressionType] {
        let canCancel = contextCancelable?.decisionboardCanCancel(self) ?? false
        if canCancel { return [.cancel] }
        return [] // we do not want a cancel option
    }
    
    func navcontroller(_ nav: NavController, hitRegressWithType: RegressionType) {
        // do nothing
    }
}

