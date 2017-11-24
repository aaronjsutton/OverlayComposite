//
//  OLCore.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation
import CoreGraphics

/// Basic methods for working with Image and Overlay types. 
class OLCore {

	/// Generate bitmaps and create a UIImage for a CIImage
	///
	/// - Parameter image: The CIImage to convert
	/// - Returns: The converted UIImage, nil if error occurred
	public class func convert(image: CIImage) -> UIImage? {
		// Create a new render context
		let context = CIContext.init()
		// Create bitmap data
		guard let cgImage = context.createCGImage(image, from: image.extent) else {
			return nil
		}
		// Convert CGImage to UIImage and return
		return UIImage(cgImage: cgImage)
	}
	
}
