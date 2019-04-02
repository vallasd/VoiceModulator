//
//  BoardHandler.swift
//  VoiceModulator
//
//  Created by David Vallas on 7/16/15.
//  Copyright © 2015 Phoenix Labs.
//
//  All Rights Reserved.

import Foundation

// MARK: Enums
extension String {

	/// returns HGErrorTypes.  Logs error and returns Info if not a valid Int.
	var hGErrorType: HGErrorType {
 		switch self {
		case "Info": return .info 
		case "Warn": return .warn 
		case "Error": return .error 
		case "Alert": return .alert 
		case "Assert": return .assert 
		default:
			HGReport.shared.report("int: |\(self)| is not enum |HGErrorType| mapable, using Info", type: .error)
		}
		return .info
	}
}
