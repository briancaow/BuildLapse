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
    let filename: String
    let url: URL
    let aperture: Aperture
    
    @State var tabSelection: Int = 0
    @State var isRecording: Bool = false
    
    init(filename: String) {
        self.filename = filename
        
        self.url = URL(fileURLWithPath: "./tmp/\(filename).mp4")
        self.aperture = try! Aperture(destination: url)
        
        let fileManager: FileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        print(currentDirectory)
    }
    
    var body: some View {
        TabView(selection: $tabSelection){
            VStack {

                Text(isRecording ? "🔴 Recording desktop. Press stop to download recording." : "not recording")
                HStack {
                    Button("Record") {
                        startRecord()
                    }
                    .disabled(filename == "")
                    
                    Button("Stop Record") {
                        endRecording()
                    }
                    .disabled(filename == "")
                    
                }
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
        moveFileToDownloads()
        
        //RunLoop.current.run()
        
        print("Recording completed successfully")
    }
    
    private func adjustPlayBackSpeed() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        task.arguments = ["-i", "./tmp/\(filename).mp4", "-filter:v", "''setpts=0.05*PTS''", "./tmp/output.mp4"]
        
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
    }
    
    private func moveFileToDownloads() {
        
        let fileManager = FileManager.default
        let downloadsFolderURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationURL = downloadsFolderURL.appendingPathComponent("output.mp4")
        print(destinationURL)
        do {
            try fileManager.moveItem(at: URL(fileURLWithPath: "./tmp/output.mp4"), to: destinationURL)
            print("File moved to Downloads folder.")
        } catch {
            print("Error: \(error)")
        }
        
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(filename: "filename")
    }
}

