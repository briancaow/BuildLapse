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
        
        self.url = URL(fileURLWithPath: "./\(filename).mp4")
        self.aperture = try! Aperture(destination: url)
        
        let fileManager: FileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        print(currentDirectory)
    }
    
    var body: some View {
        TabView(selection: $tabSelection){
            VStack{
                Text("Build History")
                BuildHistoryView()
            }
            .tabItem{
                Text("Home")
            }
            .tag(0)
            
            VStack {

                Text(isRecording ? "Recording destop. Press stop to download recording." : "not recording")
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
            .tag(1)
            
        }
        .padding()
        
   
    }
    
    func startRecord() {
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

    func endRecording() {
        isRecording = false
        aperture.stop()
        setbuf(__stdoutp, nil)
        
        moveFileToDownloads();
        //RunLoop.current.run()
        print("Recording completed successfully")
    }
    
    func moveFileToDownloads() {
        
        let fileManager = FileManager.default
        let downloadsFolderURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let destinationURL = downloadsFolderURL.appendingPathComponent("\(filename).mp4")
        print(destinationURL)
        do {
            try fileManager.moveItem(at: url, to: destinationURL)
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

