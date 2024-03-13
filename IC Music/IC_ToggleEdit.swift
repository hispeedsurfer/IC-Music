//
//  IC_ToggleEdit.swift
//  IC Music
//
//  Created by Andreas Franke on 10.03.24.
//

import SwiftUI

struct IC_ToggleEdit: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isEditable: Bool
    
    var body: some View {
        Toggle(isEditable ? "Edit Mode" : "Read Mode", isOn: $isEditable)
            .onChange(of: isEditable) {
                if !isEditable && viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
    }
}

#Preview {
    IC_ToggleEdit(isEditable: .constant(true))
}
