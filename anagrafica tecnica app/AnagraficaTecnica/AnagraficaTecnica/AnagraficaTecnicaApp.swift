//
//  AnagraficaTecnicaApp.swift
//  AnagraficaTecnica
//
//  Created by Gabriele Giardino on 06/01/26.
//

import Core
import CoreData
import SwiftUI

enum AppBootstrapError: Error {
    case missingModel
    case invalidModel
}

final class AppBootstrap {
    let coreDataStack: CoreDataStack
    let demoSeedResult: DemoSeedResult

    init() {
        do {
            let model = try Self.loadModel()
            coreDataStack = try CoreDataStack(name: "AnagraficaTecnicaModel", model: model)
            let seeder = DemoDataSeeder()
            demoSeedResult = try seeder.seedIfNeeded(context: coreDataStack.container.viewContext)
        } catch {
            fatalError("App bootstrap failed: \(error)")
        }
    }

    private static func loadModel() throws -> NSManagedObjectModel {
        guard let url = Bundle.main.url(forResource: "AnagraficaTecnicaModel", withExtension: "momd") else {
            throw AppBootstrapError.missingModel
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            throw AppBootstrapError.invalidModel
        }
        return model
    }
}

@main
struct AnagraficaTecnicaApp: App {
    private let bootstrap = AppBootstrap()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, bootstrap.coreDataStack.container.viewContext)
        }
    }
}
