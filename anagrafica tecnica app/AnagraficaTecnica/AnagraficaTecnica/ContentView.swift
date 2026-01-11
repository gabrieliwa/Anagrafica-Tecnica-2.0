//
//  ContentView.swift
//  AnagraficaTecnica
//
//  Created by Gabriele Giardino on 06/01/26.
//

import Floorplan
import Projects
import SwiftUI

// MARK: - ContentView

/// Root navigation coordinator for the app.
///
/// ## Navigation Architecture
///
/// The app supports two top-level flows:
///
/// ### 1. PlanimetricFlow (FloorplanView)
/// - The floor map is the root surface with overlay UI that swaps based on mode
/// - Browse Mode: pan/zoom the floor plan, browse chrome visible
/// - Room Mode: room selected, room overlay visible, same map instance
/// - The floor plan is persistent ONLY within this flow
///
/// ### 2. ReportsFlow (SurveyReportView)
/// - Standard full-screen navigation, no floor plan background
/// - Accessed via hamburger menu from PlanimetricFlow
/// - Uses conventional push navigation for detail screens
///
/// ## Why No Nested NavigationStacks
/// We use a single NavigationStack at the root to avoid:
/// - View hierarchy "deck of cards" artifacts in Debug View Hierarchy
/// - Multiple navigation bars stacking
/// - State management complexity with nested navigation
///
/// The PlanimetricFlow handles its internal mode transitions using
/// state-driven overlay switching rather than navigation pushes.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ProjectsListView()
                .navigationDestination(for: ProjectRoute.self) { route in
                    // PlanimetricFlow: floor map as root surface
                    FloorplanView(projectName: route.name, uiState: route.uiState)
                }
        }
    }
}

#Preview {
    ContentView()
}
