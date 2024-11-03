//
//  LibraryView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var coordinator: ViewCoordinator
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectData.createdAt, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<ProjectData>
    
    private func addProject() {
        let newProject = ProjectData(context: viewContext)
        newProject.name = "Untitled"
        
        let initialCards = [CardData()]
        newProject.cardsData = try! JSONEncoder().encode(initialCards)
        
        try? viewContext.save()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(projects, id: \.objectID) { project in
                            NavigationLink(value: project) {
                                ProjectCard(project: project)
                            }
                        }
                    }.padding()
                }
                
                VStack {
                    Spacer()
                    Button(action: addProject) {
                        Capsule()
                            .fill(Color.yellow)
                            .frame(height: 50)
                            .overlay(
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create New")
                                        .fontWeight(.semibold)
                                }
                                    .foregroundColor(.black)
                            )
                            .padding(.horizontal, 32)
                            .padding(.bottom, 16)
                    }
                }
            }
            .sheet(isPresented: $coordinator.isSettingsPresented) {
                SettingsView().environment(\.colorScheme, colorScheme)
            }
            .navigationDestination(for: ProjectData.self) { project in
                EditorView(project: project)
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        coordinator.openSettings()
                    }) {
                        Image(systemName: "gearshape").foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
