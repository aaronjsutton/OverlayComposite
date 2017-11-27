//
//  Overlay.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation
import CoreGraphics
import Metal

/// Basic methods for working with Image and Overlay types.
public final class OverlayCore {

	/// ## Overview
	/// Convert a CIImage to UIImage.
	///
	/// ## Example
	///
	/// #### Convert an image:
	///
	/// ```swift
	///	OverlayCore.convert(image: myCiImage) { result in
	///		// access to the converted image result
	/// }
	/// ```
	///
	/// - Parameters:
	///   - image: The image to convert.
	///   - completion: Passes the converted image.
	public class func convert(image: CIImage, completion: @escaping (_ image: UIImage) -> Void) {
		let context: CIContext

		// Check if the devive supports Metal
		if let mtlDevice = MTLCreateSystemDefaultDevice() {
			// Use Metal enhanced context
			context = CIContext.init(mtlDevice: mtlDevice)
		} else {
			// Use default context
			context = CIContext.init()
		}

		var cgImage: CGImage?

		DispatchQueue.global(qos: .userInitiated).async {
			// Create bitmap data
			cgImage = context.createCGImage(image, from: image.extent)
			DispatchQueue.main.async {
				if cgImage != nil {
					completion(UIImage(cgImage: cgImage!))
				} else {
					return
				}
			}
		}
	}
}
