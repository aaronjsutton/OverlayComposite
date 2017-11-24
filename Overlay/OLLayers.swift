//
//  OLLayers.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation

/// This object represents a collection of images to be composited
///
/// Images are ordered by layer
public final class OLLayers {

	public var images: [Int: CIImage] = [:]

	/// Create a collection of layers from images stored in the asset catalog.
	/// Pass a dictionary to specify the order of the images, starting at 0.
	/// ## Example
	///
	/// `let layers = [0: "Image 1", 1: "Image 2"]`
	/// **Note:** Ensure layers are in proper order, otherwise an error will be thrown
	///
	/// - Parameter images: The images to be composited, ordered by layer
	/// - Throws: Errors if the layers could not be organized
	public init?(from images: [Int: String]) throws {
		// Validate dictionary
		do {
			try OLLayers.isLayerDictionary(images)
		} catch let error {
			throw error
		}

		// Validate images
		for (layer, image) in images {
			guard let uiImage = UIImage(named: image) else {
				throw OLError(.imageNotFound, imageName: image)
			}
			guard let ciImage = CIImage(image: uiImage) else {
				throw OLError(.invalidImage, imageName: image)
			}
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	/// Validate a dictionary, ensuring it is in proper layered order
	///
	/// - Parameter dictionary: The dictionary to validate
	/// - Throws: An error if the dictionary is invalid
	public class func isLayerDictionary(_ dictionary: [Int: String]) throws {
		let total = dictionary.count - 1
		for index in 0...total {
			if dictionary[index] == nil {
				throw OLError(.invalidDictionary)
			}
		}
	}
}
