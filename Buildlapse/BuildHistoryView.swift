//
//  BuildHistoryView.swift
//  Buildlapse
//
//  Created by Brian Cao on 2/12/23.
//

import SwiftUI
import Foundation

struct BuildHistoryView : View {
    
    var body: some View {
        
        return HStack(spacing: 2) {
                   ForEach(0..<52) { row in
                       VStack(spacing: 2) {
                           ForEach(0..<7) { column in
                               let isGreen = arc4random_uniform(2) == 0
                               Text("")
                                   .frame(width: 10, height: 10)
                                   .background(isGreen ? Color.green : Color.gray)
                           }
                       }
                   }
               }
    }
}
