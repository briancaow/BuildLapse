//
//  ContentView.swift
//  Buildlapse
//
//  Created by Brian Cao on 2/6/23.
//

import SwiftUI
import CoreData
import AVFoundation
import ScreenCaptureKit

struct ContentView: View {
    @State private var selection = "1x"
    let speeds = ["1x", "2x", "4x", "8x", "16x"]
    
    var body: some View {
        VStack {
            Picker("timelapse speed", selection: $selection) {
                ForEach(speeds, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200, height: 100)
        }

        Button("Start Recording", action: record);
    }

    private func record(){
        print("recording");
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
