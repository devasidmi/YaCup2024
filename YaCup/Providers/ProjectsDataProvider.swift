//
//  ProjectsDataCotroller.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 03.11.2024.
//

import CoreData

final class ProjectsDataProvider {
    static let shared = ProjectsDataProvider()
    
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "YaCup")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
