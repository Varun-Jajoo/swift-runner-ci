//
//  ChooseWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 16/01/25.
//

import UIKit
import CoreML
import Vision


class ChooseWorkoutViewController: CommonViewController {

    //MARK: ----------------VARIABLE
    var ratationAngle:CGFloat = 0.0
    
    // Replace with the actual name of your Core ML model
       let modelName = "YourCoreMLModel"
//    var shapeLayers: [CAShapeLayer] = [] // Array to hold dynamic shapes
    
//    let bodyParts: [(name: String, rect: CGRect)] = [
//           ("Head", CGRect(x: 100, y: 50, width: 100, height: 100)),
//           ("Chest", CGRect(x: 100, y: 150, width: 100, height: 100)),
//           ("Abdomen", CGRect(x: 100, y: 250, width: 100, height: 100)),
//           ("Left Arm", CGRect(x: 50, y: 150, width: 50, height: 150)),
//           ("Right Arm", CGRect(x: 150, y: 150, width: 50, height: 150)),
//           ("Left Leg", CGRect(x: 50, y: 300, width: 50, height: 150)),
//           ("Right Leg", CGRect(x: 150, y: 300, width: 50, height: 150)),
//       ]
    
    var bodyParts: [String: CGRect] = [:]
    
    //MARK: -----------------IBOUTLET
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var turnAroundBtn: UIButton!
    @IBOutlet weak var viewworkoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
        
        //--------------------************
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bodyImageTapped(_:)))
//               backImgView.addGestureRecognizer(tapGesture)
//               backImgView.isUserInteractionEnabled = true
        
//        var path = UIBezierPath()
//        path.move(to: CGPointMake(20, 30))
//        path.addLine(to: CGPointMake(40, 30))
//
//        // add as many coordinates you need...
//
//        path.close()
//
//        var layer = CAShapeLayer()
//        layer.path = path.cgPath
//        layer.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5).cgColor
//        layer.isHidden = true
//
//        backImgView.layer.addSublayer(layer)
        
        // Create an empty UIBezierPath
//               var path = UIBezierPath()
//               
//               // Define the start point of the path
//               path.move(to: CGPoint(x: 20, y: 30))
//               
//               // Add a line to a new point
//               path.addLine(to: CGPoint(x: 40, y: 30))
//               
//               // Add more points as needed (for example, a triangle)
//               path.addLine(to: CGPoint(x: 30, y: 50))
//               
//               // Close the path to form a closed shape (triangle)
//               path.close()
//               
//               // Create a CAShapeLayer to display the path
//               let layer = CAShapeLayer()
//               
//               // Set the path of the shape layer to the CGPath of the UIBezierPath
//               layer.path = path.cgPath
//               
//               // Set the fill color (semi-transparent red)
//        layer.fillColor =  UIColor.red.cgColor //UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor
//               
//               // Initially hide the layer
//               layer.isHidden = true
//               
//               // Add the layer to the bodyImage view
//               backImgView.layer.addSublayer(layer)
        
        
        // Add a shape dynamically
//        addShape(at: CGPoint(x: 50, y: 50), width: 100, height: 100)
        
        
        // Add tap gesture recognizer to the image view
//               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bodyImageTapped(_:)))
//               backImgView.addGestureRecognizer(tapGesture)
//               backImgView.isUserInteractionEnabled = true
//
//               // **Crucial Step: Initialize bodyParts (replace with your image analysis logic)**
//               initializeBodyParts()
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                backImgView.addGestureRecognizer(tapGesture)
                backImgView.isUserInteractionEnabled = true
        
        //----------------##############
        
        
        
    }
    
    // Method to add a new shape (e.g., a square)
    
    @objc func imageTapped() {
//          let imagePickerController = UIImagePickerController()
//          imagePickerController.delegate = self
//          imagePickerController.allowsEditing = false
//          present(imagePickerController, animated: true, completion: nil)
      }
    
    
//    func predict(image: UIImage) {
//            guard let model = try? VNCoreMLModel(for: YourCoreMLModel().model) else {
//                print("Error loading Core ML model")
//                return
//            }
//
//            guard let ciImage = CIImage(image: image) else {
//                print("Error converting to CIImage")
//                return
//            }
//
//            let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//            let request = VNCoreMLRequest(model: model) { request, error in
//                guard let results = request.results as? [VNCoreMLObservation] else {
//                    print("Error getting results")
//                    return
//                }
//
//                guard let topPrediction = results.first as? VNCoreMLClassificationObservation else {
//                    print("No predictions found")
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    self.resultLabel.text = "Predicted Body Part: \(topPrediction.identifier)"
//                }
//            }
//
//            try? requestHandler.perform([request])
//        }
    
    func initializeBodyParts() {
            // **This is a placeholder. Replace with your actual image analysis logic**
            // Example: Using a pre-trained machine learning model

            // Assuming you have a function to detect and define body parts:
            if let detectedBodyParts = detectBodyPartsInImage(image: backImgView.image!) {
                bodyParts = detectedBodyParts
            }
        }

        // Example: Simplified body part detection function (replace with your actual implementation)
        func detectBodyPartsInImage(image: UIImage) -> [String: CGRect]? {
            // 1. **Image Preprocessing:** Convert image to grayscale, resize, etc.

            // 2. **Body Part Detection:**
            //    - Use a machine learning model (e.g., Pose Estimation models like MediaPipe, TensorFlow Lite)
            //    - Perform image segmentation
            //    - Implement custom algorithms based on image features (e.g., color, edges)

            // 3. **Create bodyParts dictionary:**
            //    - Based on the detection results, create a dictionary
            //      where keys are body part names (e.g., "head", "left_arm")
            //      and values are the corresponding CGRect objects.

            // Example: Simplified return (replace with actual detection results)
            return [
                "Head": CGRect(x: 100, y: 50, width: 100, height: 100),
                "Chest": CGRect(x: 100, y: 150, width: 100, height: 100),
                // ... other body parts
            ]
        }

        @objc func bodyImageTapped(_ sender: UITapGestureRecognizer) {
            let touchPoint = sender.location(in: backImgView)

            for (name, rect) in bodyParts {
//                print("name of body =", name)
                if rect.contains(touchPoint) {
                    print("name of body =", name)
                    // ... (rest of the code remains the same) ...
                }
            }
        }
    
//    @objc func bodyImageTapped(_ sender: UITapGestureRecognizer) {
//            let touchPoint = sender.location(in: backImgView)
//
//            for (name, rect) in bodyParts {
//                if rect.contains(touchPoint) {
////                    let alert = UIAlertController(title: "Body Part", message: "\(name)", preferredStyle: .alert)
////                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
////                    present(alert, animated: true, completion: nil)
//                    
//                    print("\(name)")
//                    
//                    // Example of indicating color (optional)
//                    let highlightView = UIView(frame: rect)
//                    highlightView.backgroundColor = UIColor.red.withAlphaComponent(0.5) // Adjust color as needed
//                    backImgView.addSubview(highlightView)
//                    
//                    // Remove highlight after a short delay
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        highlightView.removeFromSuperview()
//                    }
//                    
//                    return
//                }
//            }
//        }
    
    // Method to add a new shape dynamically at a given location (circle for example)
    
    // Method to add a new shape dynamically at a given location (circle for example)
//        func addShape(at point: CGPoint) {
//            // Example: Adding a circle with a fixed radius
//            let radius: CGFloat = 30.0
//            let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
//            
//            // Create a new CAShapeLayer for the shape
//            let layer = CAShapeLayer()
//            layer.path = path.cgPath
//            layer.fillColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor  // Red color with transparency
//            layer.isHidden = false  // Show the shape by default
//            
//            // Add the layer to the bodyImage view
//            backImgView.layer.addSublayer(layer)
//            
//            // Store the layer for later reference
//            shapeLayers.append(layer)
//        }
//       func addShape(at point: CGPoint) {
//           // Example: Adding a circle with a fixed radius
//           let radius: CGFloat = 30.0
//           let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
//           
//           // Create a new CAShapeLayer for the shape
//           let layer = CAShapeLayer()
//           layer.path = path.cgPath
//           layer.fillColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor  // Red color with transparency
//           layer.isHidden = false  // Show the shape by default
//           
//           // Add the layer to the bodyImage view
//           backImgView.layer.addSublayer(layer)
//           
//           // Store the layer for later reference
//           shapeLayers.append(layer)
//       }
//        func addShape(at point: CGPoint, width: CGFloat, height: CGFloat) {
//            let path = UIBezierPath(rect: CGRect(x: point.x, y: point.y, width: width, height: height))
//            
//            // Create a new CAShapeLayer for the shape
//            let layer = CAShapeLayer()
//            layer.path = path.cgPath
//            layer.fillColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor
//            layer.isHidden = true  // Initially hide the shape
//            
//            // Add the layer to the bodyImage view
//            backImgView.layer.addSublayer(layer)
//            
//            // Store the layer for later use
//            shapeLayers.append(layer)
//        }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.workout_Library], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func turnAroundBtnActn(_ sender: Any) {
        print("Turn around btn clicked..")
//        self.ratationAngle += 45
        
        self.backImgView.addRotationAnimation(axis: "y", angle: CGFloat.pi, duration: 1.0, isCumulative: true, repeatCount: 0) {
            print("Y-axis rotation animation completed!")
        }
    
    }
    
    @IBAction func viewworkoutBtnActn(_ sender: Any) {
        print("Viewworkout Btn clicked..")
        let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
        vc.workoutNameStr = "Quadriceps"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setupUI(){
        DispatchQueue.main.async {
            self.turnAroundBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.viewworkoutBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.turnAroundBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.viewworkoutBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
 
    
    //------------------************
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//
//        if let touch = touches.first! as? UITouch {
//            // get tapped position
//            let position = touch.location(in: self.backImgView)
//
//            // loop all sublayers
//            for layer in self.backImgView.layer.sublayers! as! [CAShapeLayer] {
//
//                // check if tapped position is inside shape-path
////                if CGPathContainsPoint(layer.path, nil, position, false) {
////                    if (layer.hidden) {
////                        layer.hidden = false
////                    }
////                    else {
////                        layer.hidden = true
////                    }
////                }
//            }
//        }
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            // get tapped position
//            let position = touch.location(in: self.backImgView)
//            
//            // loop all sublayers
//            for layer in self.backImgView.layer.sublayers! as! [CAShapeLayer] {
//                print("layer get ", layer)
////                 check if tapped position is inside shape-path
//                                if CGPathContainsPoint(layer.path, nil, position, false) {
//                                    if (layer.isHidden) {
//                                        layer.isHidden = false
//                                    }
//                                    else {
//                                        layer.isHidden = true
//                                    }
//                                }
//            }
//        }
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // Check if there's a touch event
//        if let touch = touches.first {
//            // Get the location of the touch in the bodyImage view
//            let position = CGPoint(x: 40, y: 30) //touch.location(in: self.backImgView)
//            
//            // Loop through all sublayers of bodyImage
//            for layer in self.backImgView.layer.sublayers as! [CAShapeLayer] {
//                // Check if the tapped position is inside the shape's path
//                if layer.path!.contains(position) {
//                    // Toggle the visibility of the layer
//                    layer.isHidden = !layer.isHidden
//                }
//            }
//        }
//    }
    
    
    // Handle touch events and toggle visibility of the shapes
//       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//           if let touch = touches.first {
//               // Get the location of the touch in the bodyImage view
//               let position = touch.location(in: self.backImgView)
//               
//               // Loop through all stored shape layers
//               for layer in shapeLayers {
//                   // Check if the tapped position is inside the shape's path
//                   if layer.path!.contains(position) {
//                       // Toggle the visibility of the layer
//                       layer.isHidden = !layer.isHidden
//                   }
//               }
//           }
//       }
    
    // Handle touch events and toggle visibility of the shapes
//     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//         if let touch = touches.first {
//             // Get the location of the touch in the bodyImage view
//             let position = touch.location(in: self.backImgView)
//             
//             // Add a new shape at the touched location
//             addShape(at: position)
//             
//             // Loop through all stored shape layers
//             for layer in shapeLayers {
//                 // Check if the tapped position is inside the shape's path
//                 if layer.path!.contains(position) {
//                     // Toggle the visibility of the layer
//                     layer.isHidden = !layer.isHidden
//                 }
//             }
//         }
//     }
    
    
    // Handle single tap events and toggle visibility of the shapes
//        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            if let touch = touches.first {
//                // Get the location of the touch in the bodyImage view
//                let position = touch.location(in: self.backImgView)
//                
//                // Add a new shape at the touched location
//                addShape(at: position)
//                
//                // Loop through all stored shape layers
//                var shapeTapped = false
//                for layer in shapeLayers {
//                    // Check if the tapped position is inside the shape's path
//                    if layer.path!.contains(position) {
//                        // Toggle the visibility of the layer
//                        layer.isHidden = !layer.isHidden
//                        shapeTapped = true
//                    }else{
//                        layer.isHidden = layer.isHidden
//                        
//                    }
//                }
//
////                // If no shape was tapped, add a new shape at the touch location
////                if !shapeTapped {
////                    addShape(at: position)
////                }
//            }
//        }
    
}
