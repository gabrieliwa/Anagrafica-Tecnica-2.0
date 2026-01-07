//
//  ContentView.swift
//  AnagraficaTecnica
//
//  Created by Gabriele Giardino on 06/01/26.
//

import Floorplan
import Projects
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ProjectsListView()
                .navigationDestination(for: ProjectRoute.self) { route in
                    FloorplanView(projectName: route.name, uiState: route.uiState)
                }
        }
    }
}

#Preview {
    ContentView()
}
