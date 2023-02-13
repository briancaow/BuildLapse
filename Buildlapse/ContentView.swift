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
    
    let url: URL
    let aperture: Aperture
    let fileManager: FileManager
    @State var tabSelection: Int = 0
    
    
    init() {
        self.url = URL(fileURLWithPath: "./screen-recording.mp4")
        self.aperture = try! Aperture(destination: url)
        self.fileManager = FileManager.default
        
        let currentDirectory = fileManager.currentDirectoryPath
        
        print(currentDirectory)
    }
    
    var body: some View {
        TabView(selection: $tabSelection){
            Text("Home")
            .tabItem{
                Text("Home")
            }
            .tag(0)
            
 
            HStack{
                Button("Record", action: startRecord)
                Button("stop", action: endRecording)
            }
            .tabItem{
                Text("Record")
            }
            .tag(1)
            
        }
        
   
    }
    
    func startRecord() {
        self.aperture.onFinish = {
            switch $0 {
            case .success(let warning):
                print("Finished recording:", url.path)

                if let warning = warning {
                    print("Warning:", warning.localizedDescription)
                }

                exit(0)
            case .failure(let error):
                print(error)
                exit(1)
            }
        }
        
        aperture.start()

        print("Available screens:", Aperture.Devices.screen().map(\.name).joined(separator: ", "))
    }

    func endRecording() {
        aperture.stop()
        setbuf(__stdoutp, nil)
        RunLoop.current.run()
        print("Recording completed successfully")
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

