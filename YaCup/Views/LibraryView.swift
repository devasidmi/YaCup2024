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
    @State private var isEditProjectDialogShown = false
    @State private var newProjectName = ""
    @State private var projectToEdit: ProjectData?
    @State private var editedProjectName = ""
    @State private var projectToDelete: ProjectData?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectData.createdAt, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<ProjectData>
    
    private func addProject() {
        isNewProjectDialogShown = true
    }
    
    private func createProject() {
        let newProject = ProjectData(context: viewContext)
        newProject.name = newProjectName.isEmpty ? "???" : newProjectName
        newProject.createdAt = Date()
        
        let initialCards = [CardData()]
        newProject.cardsData = try! JSONEncoder().encode(initialCards)
        
        try? viewContext.save()
        
        newProjectName = ""
    }
    
    private func deleteProject(_ project: ProjectData) {
        project.prepareForDeletion()
        viewContext.delete(project)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? viewContext.save()
        }
    }
    
    private func renameProject() {
        if let project = projectToEdit {
            project.name = editedProjectName.isEmpty ? "Untitled" : editedProjectName
            try? viewContext.save()
        }
        editedProjectName = ""
        projectToEdit = nil
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
                            .contextMenu {
                                Button(action: {
                                    projectToEdit = project
                                    editedProjectName = project.name
                                    isEditProjectDialogShown = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    projectToDelete = project
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
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
            .alert("Edit Project", isPresented: $isEditProjectDialogShown) {
                TextField("Project name", text: $editedProjectName)
                Button("Cancel", role: .cancel) {
                    projectToEdit = nil
                    editedProjectName = ""
                }
                Button("Save") {
                    renameProject()
                }
            } message: {
                Text("Enter a new name for your project")
            }
            .alert("Delete Project", isPresented: .init(
                get: { projectToDelete != nil },
                set: { if !$0 { projectToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    projectToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let project = projectToDelete {
                        deleteProject(project)
                    }
                    projectToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this project? This action cannot be undone.")
            }
            .navigationDestination(for: ProjectData.self) { project in
                EditorView(project: project)
            }
            .navigationTitle("Projects")
            .id(locale)
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
