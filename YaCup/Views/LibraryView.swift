//
//  LibraryView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    @ObservedObject var coordinator: ViewCoordinator
    @State private var isNewProjectDialogShown = false
    @State private var newProjectName = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectData.createdAt, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<ProjectData>
    
    private func addProject() {
        isNewProjectDialogShown = true
    }
    
    private func createProject() {
        let newProject = ProjectData(context: viewContext)
        newProject.name = newProjectName.isEmpty ? "Untitled" : newProjectName
        newProject.createdAt = Date()
        
        let initialCards = [CardData()]
        newProject.cardsData = try! JSONEncoder().encode(initialCards)
        
        try? viewContext.save()
        
        newProjectName = ""
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
                                    Text("Create new")
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
                SettingsView()
                    .environment(\.colorScheme, colorScheme)
                    .environment(\.locale, locale)
            }
            .alert("New Project", isPresented: $isNewProjectDialogShown) {
                TextField("Project name", text: $newProjectName)
                Button("Cancel", role: .cancel) { }
                Button("Create") {
                    createProject()
                }
            } message: {
                Text("Enter a name for your new project")
            }
            .navigationDestination(for: ProjectData.self) { project in
                EditorView(project: project)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Projects")
                        .font(.largeTitle)
                        .bold()
                }
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
