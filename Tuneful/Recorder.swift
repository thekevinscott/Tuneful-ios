//
//  Recorder.swift
//  Tuneful
//
//  Created by Kevin Scott on 7/19/14.
//  Copyright (c) 2014 Kevin Scott. All rights reserved.
//

import Foundation
import AVFoundation

class Recorder : NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    let audioSession = AVAudioSession.sharedInstance()
    let homePath = NSHomeDirectory().stringByAppendingPathComponent("Documents")

    
    init() {
        super.init()
        if (self.audioSession.respondsToSelector("requestRecordPermission:")) {
            self.audioSession.requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    
                    var err : NSError? = nil
                    self.audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &err)
                    
                    if (err) {
                        println("There was an error setting the category")
                        return
                    }
                    
                    self.audioSession.setActive(true, error: &err)
                    if (err) {
                        println("There was an error setting the active")
                        return
                    }

                } else {
                   println("not granted")
                }
            })
        }
    }
    
    func play() {
        let url = NSURL.fileURLWithPath(homePath+"/charlie.mp3")
        var err : NSError? = nil
//        println(url)
        let audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &err)
        if (err) {
            println(err.description)
            return
        }
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        println(audioPlayer.playing)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool)  {
        println("succesS")
    }
    func audioPlayerEndInterruption(player: AVAudioPlayer!, withOptions flags: Int)  {
        println("end interruption")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!)  {
        println(error)
    }
    
    func record() {
        play()
        return
        
        
        /*
        var err : NSError? = nil
        
        
        if (audioSession.respondsToSelector("requestRecordPermission:")) {
            audioSession.requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("granted")
        
                    let path = NSHomeDirectory().stringByAppendingPathComponent("Documents")
                    //                    println(path)
                    
                    
                    let settings = [
                        "AVFormatIDKey" : kAudioFormatMPEG4AAC,
                        "AVSampleRateKey" : 44100.0,
                        "AVNumberOfChannelsKey": 1,
                    ]
                    
                    let now = NSDate().description
                    
                    let url = NSURL.fileURLWithPath(path+"/"+now+".aac")
                    err = nil
                    let recorder = AVAudioRecorder(URL: url, settings: settings, error: &err)
                    if (err) {
                        println("Shit on my face")
                        return
                    }
                    
                    recorder.meteringEnabled = true
                    recorder.delegate = self
                    
                    if (!audioSession.inputAvailable ) {
                        println("fuck my life")
                        return
                    }
                    
                    let interval = NSTimeInterval(1)
                    
                    recorder.recordForDuration(interval)
//                    println(recorder.delegate.audioRecorderBeginInterruption)
                    
                } else{
                    println("not granted")
                }
            })
            
        }
        */
        

    }
    
    func audioRecorderBeginInterruption(recorder: AVAudioRecorder!) {
        println("begin interruption")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("success")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!)  {
        println("error")
    }

    
}