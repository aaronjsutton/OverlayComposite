//
//  OLError.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation

/// Errors thrown by Overlay classes
public struct OLError: Error {

	/// The type of error that occurred
	public enum ErrorType: String {
		/// The specified image was not found
		case imageNotFound = "was not found"
		/// The specified image could not be converted into CIImage
		case invalidImage = "is invalid"
		/// The layer dictionary is not valid
		case invalidDictionary = "invalid layer dictionary"
	}

	/// The description of the error in String format
	public let description: String

	/// Optional image name to include in the error throw
	public let imageName: String? = nil

	/// Create a new error object
	///
	/// - Parameters:
	///   - kind: The type of error
	///   - imageName: An optional image name
	public init(_ kind: ErrorType, imageName: String? = nil) {
		if imageName != nil {
			description = imageName! + ": " + kind.rawValue
		} else {
			description = kind.rawValue
		}
	}
}
