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
    
    @State var tabSelection: Int = 0
    
    var body: some View {
        TabView(selection: $tabSelection){
   
            RecordView()
            .tabItem{
                Text("Record")
            }
            .tag(0)
            
            BuildHistoryView()
            .tabItem{
                Text("Stats")
            }
            .tag(1)
            
        }
        .padding()
        
    }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

