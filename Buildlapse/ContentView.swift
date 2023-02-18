//
//  ContentView.swift
//  Buildlapse
//
//  Created by Brian Cao on 2/6/23.
//

import SwiftUI
import Aperture
import Foundation
import AVFoundation

struct ContentView: View {
    
    var url: URL
    var aperture: Aperture
    
    @State var tabSelection: Int = 0
    @State var isRecording: Bool = false
    @State var filename: String = ""
    
    let speeds:Array<Double> = [1.25, 1.5, 1.75, 2, 4, 8, 16, 32]
    @State private var selectedSpeedIndex = 0
    
    init() {
        
        self.url = URL(fileURLWithPath: "./tmp/recording.mp4")
        self.aperture = try! Aperture(destination: url)
        
        let fileManager: FileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        print(currentDirectory)
    }
    
    var body: some View {
        TabView(selection: $tabSelection){
            VStack {
                Text(isRecording ? "🔴 Recording desktop. Press stop to download recording." : "not recording")
                
                TextField("File Name", text: $filename)
                .frame(maxWidth: 200)
                
                Picker("Playback Speed", selection: $selectedSpeedIndex) {
                    ForEach(Int(0)..<Int(speeds.count)) { index in
                        Text("\(Int(floor(speeds[index]))).\(Int((speeds[index] - floor(speeds[index]))*100))x")
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
                
                Button(isRecording ? "Stop" : "Record") {
                    if(isRecording) {
                        endRecording()
                    } else {
                        startRecord()
                    }
                }
                .disabled(filename == "")
                    
            }
            .tabItem{
                Text("Record")
            }
            .tag(0)
            
            VStack{
                Text("Build History")
                BuildHistoryView()
            }
            .tabItem{
                Text("Stats")
            }
            .tag(1)
            
        }
        .padding()
        
    }
    
    private func startRecord() {
        isRecording = true
        aperture.onFinish = {
            switch $0 {
            case .success(let warning):
                print("Finished recording:", url.path)

                if let warning = warning {
                    print("Warning:", warning.localizedDescription)
                }

                //exit(0)
            case .failure(let error):
                print(error)
                exit(1)
            }
        }
        
        aperture.start()

        print("Available screens:", Aperture.Devices.screen().map(\.name).joined(separator: ", "))
    }

    private func endRecording() {
        isRecording = false
        aperture.stop()
        
        setbuf(__stdoutp, nil)
        
        
        adjustPlayBackSpeed()
        let startTime = CMTime(seconds: 0, preferredTimescale: 1)
        let videoDuration = getVideoDuration(url: URL(fileURLWithPath: "./tmp/timelapsed.mp4"))
        let endTime = CMTime(seconds: videoDuration/(speeds[selectedSpeedIndex]), preferredTimescale: 1)
        trimVideo(sourceURL: URL(fileURLWithPath: "./tmp/timelapsed.mp4"), destinationURL: URL(fileURLWithPath: "./tmp/output.mp4"), startTime: startTime, endTime: endTime) { error in
            if let error = error {
                print("Error trimming video: \(error)")
            } else {
                print("Video trimmed successfully!")
            }
        }
        
        
        //RunLoop.current.run()
        
        print("Recording completed successfully")
    }
    
    private func adjustPlayBackSpeed() {
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        task.arguments = ["-i", "./tmp/recording.mp4", "-filter:v", "setpts=\(1.0/speeds[selectedSpeedIndex])*PTS", "./tmp/timelapsed.mp4"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Error: \(error)")
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        
        print("Output: \(output)")
        print("Error: \(error)")
        
        // Remove recording file
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: "./tmp/recording.mp4")
        } catch {
            print("Error: \(error)")
        }

    }
    
    private func trimVideo(sourceURL: URL, destinationURL: URL, startTime: CMTime, endTime: CMTime, completion: @escaping (Error?) -> ()) {
        let asset = AVAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = AVFileType.mp4
        
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(nil)
                moveFileToDownloads()
                
                // Remove timelapse file
                let fileManager = FileManager.default
                
                do {
                    try fileManager.removeItem(atPath: "./tmp/timelapsed.mp4")
                } catch {
                    print("Error: \(error)")
                }
                
            } else if let error = exportSession.error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    private func getVideoDuration(url: URL) -> Double {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    private func moveFileToDownloads() {
        
        let fileManager = FileManager.default
        let downloadsFolderURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationURL = downloadsFolderURL.appendingPathComponent(getUniqueFileName("/\(filename).mp4"))
    
        print(destinationURL)
        do {
            try fileManager.moveItem(at: URL(fileURLWithPath: "./tmp/output.mp4"), to: destinationURL)
            print("File moved to Downloads folder.")
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    private func getUniqueFileName(_ fileName: String) -> String {
        let fileManager = FileManager.default
        let downloadsDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        var name = fileName
        var suffix = 1
        
        var fileURL = downloadsDirectory.appendingPathComponent(fileName)
        while fileManager.fileExists(atPath: fileURL.path) {
            let fileExtension = (fileName as NSString).pathExtension
            let nameWithoutExtension = (fileName as NSString).deletingPathExtension
            
            name = "\(nameWithoutExtension)_\(suffix).\(fileExtension)"
            suffix += 1
            
            let newFileURL = downloadsDirectory.appendingPathComponent(name)
            fileURL = newFileURL
        }
        
        return name
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

