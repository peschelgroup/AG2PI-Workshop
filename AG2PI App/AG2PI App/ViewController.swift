//
//  ViewController.swift
//  AG2PI App
//
//  Created by Joshua Peschel on 8/19/21.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("The ViewController has loaded.")
        
        startMyCamaera()
        
    }

    func startMyCamaera() {
        
        // Part I: AVCaptureSession configuration and running (4 steps)
        
        // Step 1: Specify AVCaptureSession
        let myCaptureSession = AVCaptureSession()
        
        // Step 2: Specify the capture device
        guard let myCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // Step 3: Specify and add the capture input
        guard let myInput = try? AVCaptureDeviceInput(device: myCaptureDevice) else { return }
        myCaptureSession.addInput(myInput)
        
        // Step 4: Start AVCaptureSession
        myCaptureSession.startRunning()
        
        // Part II: Add camera output to app display (2 steps)
        
        // Step 1: Define the preview layer
        let myPreviewLayer = AVCaptureVideoPreviewLayer(session: myCaptureSession)
        
        // Step 2: Add preview layer to the ViewController view
        view.layer.addSublayer(myPreviewLayer)
        myPreviewLayer.frame = view.frame
        
        // Part III: Gain access to the camera video data
        //Step 1: Specify and add the capture device output
        let myDataOutput = AVCaptureVideoDataOutput()
        myDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "myVideoQueue"))
        myCaptureSession.addOutput(myDataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print("My camera captured a frame:", Date())
        
        // Step 1: Get the image data in the sample buffer
        guard let myPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Step 2: Define the model you wish to use on the data
        guard let myModel = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        // Step 3: Define a request for the model
        let myRequest = VNCoreMLRequest(model: myModel) {
            (finishedReq, err) in
            //print(finishedReq.results) // Gives results printout
            
            guard let myResults = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let myFirstObservation = myResults.first else { return }
            
            print(myFirstObservation.identifier, myFirstObservation.confidence)
            
        }
        
        // Step 4: Facilitate the request from the model
        try? VNImageRequestHandler(cvPixelBuffer: myPixelBuffer, options: [:]).perform([myRequest])
        
    }
    

}

