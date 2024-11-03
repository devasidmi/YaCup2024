//
//  ProjectData.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 03.11.2024.
//

import CoreData

final class ProjectData: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var cardsData: Data?
    @NSManaged var createdAt: Date
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "createdAt")
    }
}
