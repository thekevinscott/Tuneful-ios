//
//  Recorder.swift
//  Tuneful
//
//  Created by Kevin Scott on 7/19/14.
//  Copyright (c) 2014 Kevin Scott. All rights reserved.
//

import Foundation
import AVFoundation

class Recorder : NSObject {

    var recorder: AVAudioRecorder?
    var outputFileURL : NSURL?
    var delegate: AVAudioRecorderDelegate!
    var timer : NSTimer?

    
    init() {
        recorder = nil
    }
    
    func prepareToRecord() {
//        println("prepare to record")
        var pathComponents: [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        pathComponents.append("\(NSDate().description).m4a")
        outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        var recordSetting = NSMutableDictionary()
        recordSetting.setValue(kAudioFormatMPEG4AAC, forKey: AVFormatIDKey)
        recordSetting.setValue(44100.0, forKey: AVSampleRateKey)
        recordSetting.setValue(2, forKey: AVNumberOfChannelsKey)
        
        recorder = AVAudioRecorder(URL: outputFileURL, settings: recordSetting, error: nil)
        recorder!.delegate = delegate
        recorder!.meteringEnabled = true
        recorder!.prepareToRecord()
    }
/*
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool)  {
        println("success")
    }
    func audioPlayerEndInterruption(player: AVAudioPlayer!, withOptions flags: Int)  {
        println("end interruption")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!)  {
        println(error)
    }
*/
    
    func record() {
        self.prepareToRecord()

        var err : NSError? = nil
        
        if !recorder!.recording {
            println("begin recording")
            var session = AVAudioSession.sharedInstance()
            session.setActive(true, error: nil)
            recorder!.record()
            let aSelector : Selector = "audioLevels"

            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)

//            NSTimer.scheduledTimerWithTimeInterval(0.01, invocation: self, repeats: true)
        } else {

           
//            recorder.pause()
            stop()
        }
    }
    func audioLevels() {
//        println("audio levels")
        recorder!.updateMeters()
        let averagePower = recorder!.averagePowerForChannel(0)
        
        println("Average input: \(averagePower)")

    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
            println("stop recording")         
        recorder!.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
}
