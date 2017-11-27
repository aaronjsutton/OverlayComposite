Pod::Spec.new do |s|
  s.name         = "OverlayComposite"
  s.version      = "1.0.0"
  s.summary      = "An asynchronous, multithreaded, image compositing framework written in Swift."
  s.description  = """Overlay works using the concept of layered images.
  Each layer represents an individual image that can then be added atop another layer.
  You can think of this like layers in Photoshop, or similar image editor."""
  s.homepage     = "https://docs.aaronjsutton.com/overlay/"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "Aaron Sutton" => "aaronjsutton@icloud.com" }
  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/aaronjsutton/Overlay.git", :tag => "#{s.version}" }
  s.source_files  = "Overlay/", "Overlay/**/*.{h,m}"
  s.exclude_files = ""
end
