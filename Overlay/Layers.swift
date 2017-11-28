//
//  OLLayers.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation

/// ## Overview
/// Overlay works using the concept of _layered images_.
/// Each layer represents an individual image that can then be added atop another layer.
/// You can think of this like layers in Photoshop, or similar image editor.
///
/// These images can then be used by [OverlayRenderer](OverlayRenderer.html) to create a composite image.
///
/// ### Create a new Layers object:
///
/// ```swift
///		let layers = [0: image1, 1: image2]
///
///		guard let layers = try? Layers(with: layers) else {
/// 		return
///  	}
///	```
///
/// # Examples
///
/// ## Inspecting Layers
/// ```swift
/// layers.count
/// ```
/// The number of layers.
///
/// ```swift
/// layers.top
/// ```
/// The number of the top most layer.
///
/// ## Manipulating Layers
///
/// ### Accessing layers:
/// ```swift
///		layers.layer(0)
/// ```
/// Returns a `UIImage` of layer 0.
///
/// ### Appending layers:
/// ```swift
///		try? layers.appendLayer(myImage)
/// ```
/// Appends `myImage` to the top of the layer stack.
///
/// ### Inserting layers:
/// ```swift
///		try? layers.insertLayer(myImage, at: 0)
/// ```
/// Inserts `myImage` at layer number 0.
///
/// ### Removing layers:
/// ```swift
///		layers.removeLayer(2)
/// ```
/// Removes layer 2.
///
/// ### Updating layers:
/// ```swift
///		layers.updateLayer(4, with: myNewImage)
/// ```
/// Replaces the contents of layer 4 with `myNewImage`.
///
/// ## Asset Catalog
/// Layers also supports the [UIImage](https://developer.apple.com/documentation/uikit/uiimage/1624146-init)
/// `init(named:)` functionality.
/// You can use this to easily reference images from the Asset Catalog:
///
/// ```swift
///  	// Create a layers object
///		let layers = [0: "ImageAsset1", 1: "ImageAsset2"]
///
///		guard let layers = try? Layers(named: layers) else {
/// 		return
///  	}
///
///  try? layers.updateLayer(1, named: "ImageAsset3")
/// // Replace layer 1 with "ImageAsset3"
///	```
///
/// An [error](../Structs/OverlayError/ErrorType.html#/s:7Overlay0A5ErrorV0B4TypeO13imageNotFoundA2EmF)
/// will be thrown if the image could not be located.
public final class Layers {

	internal var images: [Int: CIImage] = [:]

	/// The number of layers. 
	public var count: Int {
		return images.count
	}

	/// The index of the highest layer.
	public var top: Int {
		return count - 1
	}

	// MARK: - Initializers

	/// Create a collection of layers from images stored in the asset catalog.
	/// Pass a dictionary to specify the order of the images, starting at 0.
	/// ## Example
	///
	/// Pass a dictionary of images and layers:
	///
	/// ```swift
	///		let layers = [0: "Image 1", 1: "Image 2"]
	/// ```
	///
	/// **Note:** Ensure layers are in proper order, otherwise an error will be thrown.
	///
	/// - Parameter images: The images to be composited, ordered by layer.
	/// - Throws: Errors if the layers could not be organized
	public init(named images: [Int: String]) throws {
		// Validate dictionary
		if !Layers.isLayerDictionary(images) {
			throw OverlayError(.invalidDictionary)
		}

		// Validate images
		for (layer, image) in images {
			// Get the image from the asset catalog
			guard let uiImage = UIImage(named: image) else {
				throw OverlayError(.imageNotFound, imageName: image)
			}
			// Convert the image to CIImage
			guard let ciImage = CIImage(image: uiImage) else {
				throw OverlayError(.invalidImage, imageName: image)
			}
			// Add the image to the registry
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	/// Create a collection of layers from UIImage objects.
	/// Pass a dictionary to specify the order of the images, starting at 0.
	/// ## Example
	///
	/// Create a dictionary of images and layers:
	///
	/// ```swift
	///		let layers = [0: image1, 1: image2]
	/// ```
	///
	/// **Note:** Ensure layers are in proper order, otherwise an error will be thrown.
	///
	/// - Parameter images: The UIImages and their corresponding layer numbers
	/// - Throws: Errors if the layers could not be organized
	public init(with images: [Int: UIImage]) throws {
		// Validate dictionary
		if !Layers.isLayerDictionary(images) {
			throw OverlayError(.invalidDictionary)
		}

		// Validate images
		for (layer, image) in images {
			// Convert the image to CIImage
			guard let ciImage = CIImage(image: image) else {
				throw OverlayError(.invalidImage)
			}
			// Add the image to the registry
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	// MARK: - Layer Operations

	/// Render out a single layer.
	///
	/// - Parameters:
	///   - layer: The layer the render.
	///   - completion: Passes the completed render.
	public func layer(_ layer: Int, completion: ((_ image: UIImage) -> Void)? = nil) {
		guard let image = images[layer] else {
			return
		}
		OverlayRenderer.convert(image: image) { result in
			completion?(result)
		}
	}

	/// `init(named:)` wrapper for appendLayer(_:)
	///
	/// - Parameter image: The image to append.
	/// - Throws: An error if the image could not be read or found.
	public func appendLayer(named image: String) throws {
		// Get the image from the asset catalog
		guard let uiImage = UIImage(named: image) else {
			throw OverlayError(.imageNotFound, imageName: image)
		}
		do {
			try appendLayer(uiImage)
		} catch let error {
			throw error
		}
	}

	/// Append a layer to the end of the dictionary, making it the topmost image.
	///
	/// - Parameter image: The image to append.
	/// - Throws: An error if the image could not be created.
	public func appendLayer(_ image: UIImage) throws {
		// Convert the image
		guard let ciImage = CIImage(image: image) else {
			throw OverlayError(.invalidImage)
		}
		// Append the image
		images.updateValue(ciImage, forKey: images.count)
	}

	/// `init(named:)` wrapper for insertLayer(_:at:)
	///
	/// - Parameters:
	///   - named: The layer to insert.
	///   - layer: The layer to insert it at. All other layers will be moved up, no layers will be overwritten
	/// - Throws: An error if the image could not be read or found.
	public func insertLayer(named image: String, at layer: Int) throws {
		// Get the image from the asset catalog
		guard let uiImage = UIImage(named: image) else {
			throw OverlayError(.imageNotFound, imageName: image)
		}
		do {
			try insertLayer(uiImage, at: layer)
		} catch let error {
			throw error
		}
	}

	/// Insert a layer at a given index.
	/// If the layer given is too high, the layer is appended.
	///
	/// - Parameters:
	///   - image: The image to insert.
	///   - layer: The layer to insert it at. All other layers will be moved up, no layers will be overwritten.
	/// - Throws: An error if the image could not be read.
	public func insertLayer(_ image: UIImage, at layer: Int) throws {
		if layer > count {
			do {
				try appendLayer(image)
			} catch let error {
				throw error
			}
			return
		}
		// Convert the image
		guard let ciImage = CIImage(image: image) else {
			throw OverlayError(.invalidImage)
		}

		// Insert the image
		var updatedImages: [Int: CIImage] = [:]
		for (key, image) in images where key < layer {
			updatedImages.updateValue(image, forKey: key)
		}
		for (key, image) in images where key >= layer {
			updatedImages.updateValue(image, forKey: key + 1)
		}
		updatedImages.updateValue(ciImage, forKey: layer)
		images = updatedImages
	}

	/// Remove a given layer.
	///
	/// - Parameter layer: The layer to remove
	public func removeLayer(_ layer: Int) {
		// Make sure the layer exisits before doing changes
		guard images[layer] != nil else {
			return
		}
		// Remove the layer
		images.removeValue(forKey: layer)
		// Shift all the layers down
		var updatedImages: [Int: CIImage] = [:]
		for (key, image) in images where key < layer {
			updatedImages.updateValue(image, forKey: key)
		}
		for (key, image) in images where key > layer {
			updatedImages.updateValue(image, forKey: key - 1)
		}
		images = updatedImages
	}

	/// `init(named:)` wrapper for updateLayer(_:with:)
	///
	/// - Parameters:
	///   - layer: The layer to modify.
	///   - image: The name of the image.
	/// - Throws: Error if image was not found or error occurred.
	public func updateLayer(_ layer: Int, named image: String) throws {
		// Get the image from the asset catalog
		guard let uiImage = UIImage(named: image) else {
			throw OverlayError(.imageNotFound, imageName: image)
		}
		do {
			try updateLayer(layer, with: uiImage)
		} catch let error {
			throw error
		}
	}

	/// Replace a layer's contents. Does nothing if a layer does not exist.
	///
	/// - Parameters:
	///   - layer: The layer to modify.
	///   - image: The image to replace with.
	/// - Throws: An error if the image could not be read
	public func updateLayer(_ layer: Int, with image: UIImage) throws {
		// Convert the image
		guard let ciImage = CIImage(image: image) else {
			throw OverlayError(.invalidImage)
		}
		if images[layer] != nil {
			// Update the layer
			images.updateValue(ciImage, forKey: layer)
		}
	}

	/// Switch the contents of two layers.
	///
	/// - Parameters:
	///   - first: The first layer.
	///   - second: The second layer.
	public func swapLayers(_ first: Int, _ second: Int) {
		guard let swap = images[second] else {
			return
		}
		guard images[first] != nil else {
			return
		}
		images.updateValue(images[first]!, forKey: second)
		images.updateValue(swap, forKey: first)
	}

	// MARK: - Helpers

	/// Validate a layer dictionary.
	///
	/// - Parameter dictionary: The dictionary to validate
	/// - Returns: False if the dictionary is invalid
	public class func isLayerDictionary(_ dictionary: [Int: Any]) -> Bool {
		let total = dictionary.count - 1
		for index in 0...total where dictionary[index] == nil {
			return false
		}
		return true
	}
}
