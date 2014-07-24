//
//  WaveformImageView.swift
//  Tuneful
//
//  Created by Kevin Scott on 7/20/14.
//  Copyright (c) 2014 Kevin Scott. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation
import UIKit

/*
#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)
*/

let noiseFloor = -50.0

struct TrackInfo {
    let sampleRate : Double
    let channels : Int
}

struct AudioImageData {
    let normalizeMax : Double
    let data : NSMutableData
}

class WaveformImageView {
    
    let image : UIImage = UIImage()
    
    let outputSettingsDict = [
        "AVFormatIDKey": kAudioFormatLinearPCM,
        "AVLinearPCMBitDepthKey": 16,
        "AVLinearPCMIsBigEndianKey": false,
        "AVLinearPCMIsFloatKey": false,
        "AVLinearPCMIsNonInterleaved": false
    ]
    
    init(url: NSURL) {
        let urlA = AVURLAsset.URLAssetWithURL(url, options: nil)
        if let image = renderPNGAudioPictogramLogForAssett(urlA) {
            self.image = image
        }
    }
    
    func extractSampleRateAndChannelCount(songTrack : AVAssetTrack) -> TrackInfo? {

        let formatDesc = songTrack.formatDescriptions
        
        for(var i = 0; i < formatDesc.count; ++i) {
            var item = formatDesc[i] as CMAudioFormatDescription
            var fmtDesc : AudioStreamBasicDescription!
            
            CMAudioFormatDescriptionGetStreamBasicDescription(item).withUnsafePointer {p in
                fmtDesc = p.memory
            }
            
            if (fmtDesc) {
                return TrackInfo(sampleRate: Double(fmtDesc.mSampleRate), channels: Int(fmtDesc.mChannelsPerFrame))

                
                //                NSLog(;@"channels:%u, bytes/packet: %u, sampleRate %f",channelCount, fmtDesc.mBytesPerPacket,sampleRate);
            }
            
        }
        
        return nil
    }
    
    func extractSamplesFromTrack(reader : AVAssetReader, trackInfo : TrackInfo) -> AudioImageData? {
        
        
        let bytesPerSample = 2 * trackInfo.channels;

        let fullSongData : NSMutableData = NSMutableData()

        let samplesPerPixel : Double = trackInfo.sampleRate / 50;
        
        reader.startReading()
        
        
        var totalBytes = 0;
        var normalizeMax = noiseFloor;
        var totalLeft : Double = 0;
        var totalRight : Double = 0;
        var sampleTally : Double = 0;
        

        
        
        while (reader.status == AVAssetReaderStatus.Reading){
            
            let trackOutput: AVAssetReaderTrackOutput = reader.outputs[0] as AVAssetReaderTrackOutput
            
            let sampleBufferRef = trackOutput.copyNextSampleBuffer()
            
            if (sampleBufferRef){
                let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef).takeRetainedValue();
                
                var length = Int(CMBlockBufferGetDataLength(blockBufferRef))
                
                
                totalBytes += length;
                
                
                
                let data = NSMutableData(length: length)
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, UInt(length), data.mutableBytes);
                
                
                var samples = [UInt](count:data.length, repeatedValue:0)
                data.getBytes(&samples, length:data.length)
                
                
                let sampleCount = length / bytesPerSample;
                
                
                func absX(x : Double) -> Double {
                    if x < 0 {
                        return 0 - x
                    } else {
                        return x
                    }
                    
                }
                
                func decibel(amplitude : Double) -> Double {
                    let tempAmp : Double = absX(amplitude)/32767.0
                    let tempLog = log10(tempAmp)
                    return (20.0 * tempLog)
                }
                
                func minMaxX (x : Double ,mn : Double ,mx : Double) -> Double {
                    if ( x <= mn ) {
                        return mn
                    } else if x>=mx {
                        return mx
                    } else {
                        return x
                    }
                }
                
                let noiseFloor = -50.0
                
                for (var i = 0; i < sampleCount; i++) {
                    var left = Double(samples[Int(i)]);
                    left = decibel(left);
                    left = minMaxX(left,Double(noiseFloor),0);
                    
                    totalLeft += Double(left);
                    
                    
                    
                    var right : Double = 0;
                    if (trackInfo.channels==2) {
                        right = Double(samples[Int(i++)]);
                        right = decibel(right);
                        right = minMaxX(right,Double(noiseFloor),0);
                        
                        totalRight += right;
                    }
                    
                    sampleTally++;
                    
                    if (sampleTally > samplesPerPixel) {
                        
                        left = totalLeft / sampleTally;
                        if (left > normalizeMax) {
                            normalizeMax = left;
                        }
                        //                    NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                        
                        fullSongData.appendBytes(bytes : left, length: sizeof(left))
                        
                        if (trackInfo.channels==2) {
                            right = totalRight / sampleTally;
                            
                            if (right > normalizeMax) {
                                normalizeMax = right;
                            }
                            
                            fullSongData.appendBytes(bytes : right, length: sizeof(right))
                        }
                        
                        totalLeft   = 0;
                        totalRight  = 0;
                        sampleTally = 0;
                        
                    }
                }
                
                CMSampleBufferInvalidate(sampleBufferRef);
                
                CFRelease(sampleBufferRef);
            }
        }
        
        if (reader.status == AVAssetReaderStatus.Failed || reader.status == AVAssetReaderStatus.Unknown){
            // Something went wrong. Handle it.
        }
        
        if (reader.status == AVAssetReaderStatus.Completed){
            return AudioImageData(normalizeMax: normalizeMax, data : fullSongData)
        } else {
            return nil
        }
        
        
        
    }
    
    func renderPNGAudioPictogramLogForAssett( songAsset: AVURLAsset ) -> UIImage? {
        var err : NSError?
        
        let reader = AVAssetReader(asset: songAsset, error: &err)
        
        if (err) {
            println("Error: \(err)")
            return nil
        }
        
        let songTrack = songAsset.tracks[0] as AVAssetTrack
        let output = AVAssetReaderTrackOutput(track: songTrack, outputSettings: outputSettingsDict)
        reader.addOutput(output)
        
        
        if let trackInfo = extractSampleRateAndChannelCount(songTrack) {
            
            if let audioData = extractSamplesFromTrack( reader, trackInfo: trackInfo ) {
                var reportBytes: ConstUnsafePointer<()> = audioData.data.bytes
                
                let sampleCount = NSInteger(audioData.data.length / (sizeof(Float32) * 2))
                let imageHeight = 400
                let test = audioImageLogGraph(samples, normalizeMax: audioData.normalizeMax, sampleCount: NSNumber(sampleCount), channelCount: trackInfo.channelCount, imageHeight: imageHeight)
                
                
                
                return UIImagePNGRepresentation(test);
            } else {
                return UIImage()
            }
            

        } else {
            println("no track info")
            return nil
        }
    }
    
    
    func audioImageLogGraph( samples : Float32, normalizeMax : Float32, sampleCount : NSInteger, channelCount : NSInteger, imageHeight : Float) -> UIImage {
    
        let imageSize = CGSizeMake(CGFloat(sampleCount), imageHeight);
        UIGraphicsBeginImageContext(imageSize);
        let context = UIGraphicsGetCurrentContext();
    
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor);
        CGContextSetAlpha(context,1.0);
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize)

        let leftcolor = UIColor.whiteColor().CGColor
        let rightcolor = UIColor.redColor().CGColor
        CGContextFillRect(context, rect);
        CGContextSetLineWidth(context, 1.0);
    
    // take into account channel count
        let halfGraphHeight = (imageHeight / 2) / Float(channelCount) ;
        let centerLeft = halfGraphHeight;
        let centerRight = (halfGraphHeight*3) ;

        // don't know what this does
        let sampleAdjustmentFactor = UInt((Float(imageHeight) / Float(channelCount)) / (Float(normalizeMax) - Float(noiseFloor)) / 2.0);
    
        for (var intSample = 0 ; intSample < sampleCount; intSample++) {

            let left = samples++;
            let pixels = (left - noiseFloor) * sampleAdjustmentFactor;
            CGContextMoveToPoint(context, intSample, centerLeft-pixels);
            CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
            CGContextSetStrokeColorWithColor(context, leftcolor);
            CGContextStrokePath(context);
    
    
            if (channelCount==2) {
                let right = samples++;
                let pixels = (right - noiseFloor) * sampleAdjustmentFactor;
                CGContextMoveToPoint(context, intSample, centerRight - pixels);
                CGContextAddLineToPoint(context, intSample, centerRight + pixels);
                CGContextSetStrokeColorWithColor(context, rightcolor);
                CGContextStrokePath(context);
            }

        }
        
        // Create new image
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Tidy up
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
}