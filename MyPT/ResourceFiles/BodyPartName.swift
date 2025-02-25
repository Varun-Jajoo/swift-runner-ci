//
//  BodyPartName.swift
//  MyPT
//
//  Created by techsaga corp on 16/01/25.
//


import UIKit
import Vision

// PoseDetectionManager Singleton

@available(iOS 14.0, *)
class PoseDetectionManager {

    // Singleton instance
    static let shared = PoseDetectionManager()

    private var _bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

    var imageView: UIImageView?
    var messageLabel: UILabel?

    // Private initializer to ensure only one instance is created
    private init() {}

    // Computed property to get and set body parts
    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] {
        get {
            return _bodyParts
        }
        set(newBodyParts) {
            _bodyParts = newBodyParts
            updateMessage(with: "Body parts updated!")
        }
    }

    // Function to detect body parts from an image
    func detectBodyParts(in image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Error: Invalid image (could not create CGImage)")
            return
        }

        // Debugging log for image size and format
        print("Image Size: \(image.size), CGImage: \(cgImage.width)x\(cgImage.height)")

        let request = VNDetectHumanBodyPoseRequest { (request, error) in
            if let error = error {
                print("Error detecting body parts: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messageLabel?.text = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let observations = request.results as? [VNHumanBodyPoseObservation], !observations.isEmpty else {
                print("No pose observations found.")
                DispatchQueue.main.async {
                    self.messageLabel?.text = "No body part detected"
                }
                return
            }

            for observation in observations {
                // Convert the recognized points to a dictionary of CGPoint values
                if let recognizedPoints = try? observation.recognizedPoints(.all) {
                    var convertedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

                    for (jointName, recognizedPoint) in recognizedPoints {
                        if recognizedPoint.confidence > 0.5 {  // Consider points with high confidence
                            // Convert normalized coordinates to CGPoint
                            let point = CGPoint(x: recognizedPoint.location.x * CGFloat(image.size.width),
                                                y: (1 - recognizedPoint.location.y) * CGFloat(image.size.height)) // Y is inverted in UIKit
                            convertedPoints[jointName] = point
                        }
                    }
                    self.bodyParts = convertedPoints // Set the converted body parts
                }
            }

            // Handle case when no body parts are detected
            if self.bodyParts.isEmpty {
                DispatchQueue.main.async {
                    self.messageLabel?.text = "No body part detected"
                }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Perform the request
                try handler.perform([request])
            } catch {
                print("Error performing request: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messageLabel?.text = "Error performing request: \(error.localizedDescription)"
                }
            }
        }
    }

    // Function to update message on the label
    private func updateMessage(with text: String) {
        DispatchQueue.main.async {
            self.messageLabel?.text = text
        }
    }
}


//@available(iOS 14.0, *)
//class PoseDetectionManager {
//
//    // Singleton instance
//    static let shared = PoseDetectionManager()
//
//    private var _bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//
//    var imageView: UIImageView?
//    var messageLabel: UILabel?
//
//    // Private initializer to ensure only one instance is created
//    private init() {}
//
//    // Computed property to get and set body parts
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] {
//        get {
//            return _bodyParts
//        }
//        set(newBodyParts) {
//            _bodyParts = newBodyParts
//            updateMessage(with: "Body parts updated!")
//        }
//    }
//
//    // Function to detect body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else {
//            print("Error: Invalid image")
//            return
//        }
//
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            if let error = error {
//                print("Error detecting body parts: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let observations = request.results as? [VNHumanBodyPoseObservation], !observations.isEmpty else {
//                print("No pose observations found.")
//                DispatchQueue.main.async {
//                    self.messageLabel?.text = "No body part detected"
//                }
//                return
//            }
//
//            for observation in observations {
//                // Convert the recognized points to a dictionary of CGPoint values
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    var convertedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//
//                    for (jointName, recognizedPoint) in recognizedPoints {
//                        if recognizedPoint.confidence > 0.5 {  // Consider points with high confidence
//                            // Convert normalized coordinates to CGPoint
//                            let point = CGPoint(x: recognizedPoint.location.x * CGFloat(image.size.width),
//                                                y: (1 - recognizedPoint.location.y) * CGFloat(image.size.height)) // Y is inverted in UIKit
//                            convertedPoints[jointName] = point
//                        }
//                    }
//                    self.bodyParts = convertedPoints // Set the converted body parts
//                }
//            }
//
//            // Handle case when no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel?.text = "No body part detected"
//                }
//            }
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//            } catch {
//                print("Error performing request: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    // Function to update message on the label
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel?.text = text
//        }
//    }
//}


//@available(iOS 14.0, *)
//class PoseDetectionManager {
//
//    // Singleton instance
//    static let shared = PoseDetectionManager()
//
//    private var _bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//
//    var imageView: UIImageView?
//    var messageLabel: UILabel?
//
//    // Private initializer to ensure only one instance is created
//    private init() {}
//
//    // Computed property to get and set body parts
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] {
//        get {
//            return _bodyParts
//        }
//        set(newBodyParts) {
//            _bodyParts = newBodyParts
//            updateMessage(with: "Body parts updated!")
//        }
//    }
//
//    // Function to detect body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//
//            for observation in observations {
//                // Convert the recognized points to a dictionary of CGPoint values
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    // Create a new dictionary to store points as CGPoint
//                    var convertedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//                    
//                    for (jointName, recognizedPoint) in recognizedPoints {
//                        if recognizedPoint.confidence > 0.5 {  // Consider points with high confidence
//                            // Convert normalized coordinates to CGPoint
//                            let point = CGPoint(x: recognizedPoint.location.x * CGFloat(image.size.width),
//                                                y: (1 - recognizedPoint.location.y) * CGFloat(image.size.height)) // Y is inverted in UIKit
//                            convertedPoints[jointName] = point
//                        }
//                    }
//                    self.bodyParts = convertedPoints // Set the converted body parts
//                }
//            }
//
//            // Handle case when no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel?.text = "No body part detected"
//                }
//            }
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to update message on the label
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel?.text = text
//        }
//    }
//}

//@available(iOS 14.0, *)
//class PoseDetectionManager {
//
//    private var _bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//
//    var imageView: UIImageView?
//    var messageLabel: UILabel?
//
//    // Computed property to get and set body parts
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] {
//        get {
//            return _bodyParts
//        }
//        set(newBodyParts) {
//            _bodyParts = newBodyParts
//            updateMessage(with: "Body parts updated!")
//        }
//    }
//
//    // Function to detect body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//
//            for observation in observations {
//                // Convert the recognized points to a dictionary of CGPoint values
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    // Create a new dictionary to store points as CGPoint
//                    var convertedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//                    
//                    for (jointName, recognizedPoint) in recognizedPoints {
//                        if recognizedPoint.confidence > 0.5 {  // Consider points with high confidence
//                            // Convert normalized coordinates to CGPoint
//                            let point = CGPoint(x: recognizedPoint.location.x * CGFloat(image.size.width),
//                                                y: (1 - recognizedPoint.location.y) * CGFloat(image.size.height)) // Y is inverted in UIKit
//                            convertedPoints[jointName] = point
//                        }
//                    }
//                    self.bodyParts = convertedPoints // Set the converted body parts
//                }
//            }
//
//            // Handle case when no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel?.text = "No body part detected"
//                }
//            }
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to update message on the label
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel?.text = text
//        }
//    }
//}


// PoseDetectionManager Singleton
//@available(iOS 14.0, *)
//class PoseDetectionManager {
//    
//    // Shared instance for the Singleton pattern
//    static let shared: PoseDetectionManager = {
//        // This will create a single instance of PoseDetectionManager
//        let instance = PoseDetectionManager()
//        return instance
//    }()
//    
//    private var _bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//    
//    var imageView: UIImageView?
//    var messageLabel: UILabel?
//    
//    // Private initializer to prevent other instances
//    private init() {}
//    
//    // Computed property to get and set body parts
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] {
//        get {
//            return _bodyParts
//        }
//        set(newBodyParts) {
//            _bodyParts = newBodyParts
//            updateMessage(with: "Body parts updated!")
//        }
//    }
//    
//    // Function to detect body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//            
//            for observation in observations {
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    self.bodyParts = recognizedPoints // Set detected body parts
//                }
//            }
//            
//            // Handle case when no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel?.text = "No body part detected"
//                }
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to update message on the label
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel?.text = text
//        }
//    }
//}

//@available(iOS 14.0, *)
//class PoseDetectionManager {
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//    var imageView: UIImageView
//    var messageLabel: UILabel
//
//    // Initializer to pass the UI elements (UIImageView and UILabel)
//    init(imageView: UIImageView, messageLabel: UILabel) {
//        self.imageView = imageView
//        self.messageLabel = messageLabel
//    }
//
//    // Function to start detecting body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//
//            for observation in observations {
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    self.bodyParts = recognizedPoints
//                        .filter { $0.value.confidence > 0.5 }
//                        .mapValues { $0.location }
//                }
//            }
//
//            // Update message if no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "No body part detected"
//                }
//            }
//        }
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to handle taps on the image
//    func handleTap(at touchPoint: CGPoint) {
//        guard let imageSize = imageView.image?.size else { return }
//        let scaleX = imageSize.width / imageView.bounds.width
//        let scaleY = imageSize.height / imageView.bounds.height
//
//        let adjustedPoint = CGPoint(x: touchPoint.x * scaleX, y: touchPoint.y * scaleY)
//        var bodyPartDetected = false
//
//        for (bodyPart, point) in bodyParts {
//            let bodyPoint = CGPoint(x: point.x * imageSize.width, y: (1 - point.y) * imageSize.height)
//            let distance = hypot(adjustedPoint.x - bodyPoint.x, adjustedPoint.y - bodyPoint.y)
//
//            if distance < 30 { // Tolerance for touch point
//                print("Tapped on \(bodyPart.rawValue)")
//                highlightBodyPart(at: adjustedPoint)
//                updateMessage(with: bodyPart.rawValue.rawValue) // Display body part name
//                bodyPartDetected = true
//                break
//            }
//        }
//
//        if !bodyPartDetected {
//            // Show "No body part detected" message
//            updateMessage(with: "No body part detected")
//        }
//    }
//
//    // Function to highlight the detected body part
//    private func highlightBodyPart(at point: CGPoint) {
//        let size: CGFloat = 20
//        let rect = CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size)
//
//        let highlightView = UIView(frame: rect)
//        highlightView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
//        highlightView.layer.cornerRadius = size / 2
//        imageView.addSubview(highlightView)
//
//        // Remove highlight after 1 second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            highlightView.removeFromSuperview()
//        }
//    }
//
//    // Function to update the label with the body part's name
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel.text = text
//        }
//    }
//}


//@available(iOS 14.0, *)
//class PoseDetectionManager {
//    
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//    var imageView: UIImageView
//    var messageLabel: UILabel
//    
//    // Initializer to pass the UI elements (UIImageView and UILabel)
//    init(imageView: UIImageView, messageLabel: UILabel) {
//        self.imageView = imageView
//        self.messageLabel = messageLabel
//    }
//
//    // Function to start detecting body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//            
//            for observation in observations {
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    self.bodyParts = recognizedPoints
//                        .filter { $0.value.confidence > 0.5 }
//                        .mapValues { $0.location }
//                }
//            }
//            
//            // Update message if no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "No body part detected"
//                }
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to handle taps on the image
//    func handleTap(at touchPoint: CGPoint) {
//        guard let imageSize = imageView.image?.size else { return }
//        let scaleX = imageSize.width / imageView.bounds.width
//        let scaleY = imageSize.height / imageView.bounds.height
//        
//        let adjustedPoint = CGPoint(x: touchPoint.x * scaleX, y: touchPoint.y * scaleY)
//        var bodyPartDetected = false
//        
//        for (bodyPart, point) in bodyParts {
//            let bodyPoint = CGPoint(x: point.x * imageSize.width, y: (1 - point.y) * imageSize.height)
//            let distance = hypot(adjustedPoint.x - bodyPoint.x, adjustedPoint.y - bodyPoint.y)
//            
//            if distance < 30 { // Tolerance for touch point
//                print("Tapped on \(bodyPart.rawValue)")
//                highlightBodyPart(at: adjustedPoint)
//                updateMessage(with: bodyPart.rawValue) // Display body part name
//                bodyPartDetected = true
//                break
//            }
//        }
//        
//        if !bodyPartDetected {
//            // Show "No body part detected" message
//            updateMessage(with: "No body part detected")
//        }
//    }
//
//    // Function to highlight the detected body part
//    private func highlightBodyPart(at point: CGPoint) {
//        let size: CGFloat = 20
//        let rect = CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size)
//
//        let highlightView = UIView(frame: rect)
//        highlightView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
//        highlightView.layer.cornerRadius = size / 2
//        imageView.addSubview(highlightView)
//
//        // Remove highlight after 1 second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            highlightView.removeFromSuperview()
//        }
//    }
//
//    // Function to update the label with the body part's name
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel.text = text
//        }
//    }
//}


//@available(iOS 14.0, *)
//class PoseDetectionManager {
//    
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//    var imageView: UIImageView
//    var messageLabel: UILabel
//    
//    // Initializer to pass the UI elements (UIImageView and UILabel)
//    init(imageView: UIImageView, messageLabel: UILabel) {
//        self.imageView = imageView
//        self.messageLabel = messageLabel
//    }
//
//    // Function to start detecting body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//            
//            for observation in observations {
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    self.bodyParts = recognizedPoints
//                        .filter { $0.value.confidence > 0.5 }
//                        .mapValues { $0.location }
//                }
//            }
//            
//            // Update message if no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "No body part detected"
//                }
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to handle taps on the image
//    func handleTap(at touchPoint: CGPoint) {
//        guard let imageSize = imageView.image?.size else { return }
//        let scaleX = imageSize.width / imageView.bounds.width
//        let scaleY = imageSize.height / imageView.bounds.height
//        
//        let adjustedPoint = CGPoint(x: touchPoint.x * scaleX, y: touchPoint.y * scaleY)
//        var bodyPartDetected = false
//        
//        for (bodyPart, point) in bodyParts {
//            let bodyPoint = CGPoint(x: point.x * imageSize.width, y: (1 - point.y) * imageSize.height)
//            let distance = hypot(adjustedPoint.x - bodyPoint.x, adjustedPoint.y - bodyPoint.y)
//            
//            if distance < 30 { // Tolerance for touch point
//                print("Tapped on \(bodyPart.rawValue)")
//                highlightBodyPart(at: adjustedPoint)
//                updateMessage(with: bodyPart.rawValue) // Display body part name
//                bodyPartDetected = true
//                break
//            }
//        }
//        
//        if !bodyPartDetected {
//            // Show "No body part detected" message
//            updateMessage(with: "No body part detected")
//        }
//    }
//
//    // Function to highlight the detected body part
//    private func highlightBodyPart(at point: CGPoint) {
//        let size: CGFloat = 20
//        let rect = CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size)
//
//        let highlightView = UIView(frame: rect)
//        highlightView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
//        highlightView.layer.cornerRadius = size / 2
//        imageView.addSubview(highlightView)
//
//        // Remove highlight after 1 second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            highlightView.removeFromSuperview()
//        }
//    }
//
//    // Function to update the label with the body part's name
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel.text = text
//        }
//    }
//}


//@available(iOS 14.0, *)
//class PoseDetectionManager {
//    
//    var bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
//    var imageView: UIImageView
//    var messageLabel: UILabel
//    
//    // Initializer to pass the UI elements (UIImageView and UILabel)
//    init(imageView: UIImageView, messageLabel: UILabel) {
//        self.imageView = imageView
//        self.messageLabel = messageLabel
//    }
//
//    // Function to start detecting body parts from an image
//    func detectBodyParts(in image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        
//        let request = VNDetectHumanBodyPoseRequest { (request, error) in
//            guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
//            
//            for observation in observations {
//                if let recognizedPoints = try? observation.recognizedPoints(.all) {
//                    self.bodyParts = recognizedPoints
//                        .filter { $0.value.confidence > 0.5 }
//                        .mapValues { $0.location }
//                }
//            }
//            
//            // Update message if no body parts are detected
//            if self.bodyParts.isEmpty {
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "No body part detected"
//                }
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//                DispatchQueue.main.async {
//                    print("Body parts detected: \(self.bodyParts.keys)")
//                }
//            } catch {
//                print("Error detecting body parts: \(error)")
//            }
//        }
//    }
//
//    // Function to handle taps on the image
//    func handleTap(at touchPoint: CGPoint) {
//        guard let imageSize = imageView.image?.size else { return }
//        let scaleX = imageSize.width / imageView.bounds.width
//        let scaleY = imageSize.height / imageView.bounds.height
//        
//        let adjustedPoint = CGPoint(x: touchPoint.x * scaleX, y: touchPoint.y * scaleY)
//        var bodyPartDetected = false
//        
//        for (bodyPart, point) in bodyParts {
//            let bodyPoint = CGPoint(x: point.x * imageSize.width, y: (1 - point.y) * imageSize.height)
//            let distance = hypot(adjustedPoint.x - bodyPoint.x, adjustedPoint.y - bodyPoint.y)
//            
//            if distance < 30 { // Tolerance for touch point
//                print("Tapped on \(bodyPart.rawValue)")
//                highlightBodyPart(at: adjustedPoint)
//                updateMessage(with: bodyPart.rawValue.rawValue) // Display body part name
//                bodyPartDetected = true
//                break
//            }
//        }
//        
//        if !bodyPartDetected {
//            // Show "No body part detected" message
//            updateMessage(with: "No body part detected")
//        }
//    }
//
//    // Function to highlight the detected body part
//    private func highlightBodyPart(at point: CGPoint) {
//        let size: CGFloat = 20
//        let rect = CGRect(x: point.x - size / 2, y: point.y - size / 2, width: size, height: size)
//
//        let highlightView = UIView(frame: rect)
//        highlightView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
//        highlightView.layer.cornerRadius = size / 2
//        imageView.addSubview(highlightView)
//
//        // Remove highlight after 1 second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            highlightView.removeFromSuperview()
//        }
//    }
//
//    // Function to update the label with the body part's name
//    private func updateMessage(with text: String) {
//        DispatchQueue.main.async {
//            self.messageLabel.text = text
//        }
//    }
//}
