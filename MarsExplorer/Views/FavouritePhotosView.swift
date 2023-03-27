//
//  ContentView.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-21.
//

import SwiftUI
import CoreData

struct FavouritePhotosView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var apiManager = APIManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CorePhoto.id, ascending: true)],
        animation: .default)
    
    private var photos: FetchedResults<CorePhoto>
    
    @State private var selectedSegmentIndex = 0
     
     var filteredPhotos: [CorePhoto] {
         switch selectedSegmentIndex {
         case 0:
             return photos.filter { $0.rover_name == "Curiosity" }
         case 1:
             return photos.filter { $0.rover_name == "Opportunity" }
         case 2:
             return photos.filter { $0.rover_name == "Spirit" }
         case 3:
             return photos.filter {$0.rover_name == $0.rover_name }
         default:
             return photos.filter { $0.rover_name == $0.rover_name }
         }
     }

    var body: some View {
        
        
        NavigationView {
            
            VStack {
                
                Text("Filters favourites by: ").padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Picker("Rover", selection: $selectedSegmentIndex) {
                    Text("Curiosity").tag(0)
                    Text("Opportunity").tag(1)
                    Text("Spirit").tag(2)
                    Text("All").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle()).padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                
                
                List {
                    ForEach(filteredPhotos) { item in
                        NavigationLink {
                            ImageInspectorView(apiManager: apiManager, selectedImage: item)
                        } label: {
                            HStack(alignment: .center){
                                VStack(alignment: .leading, spacing: 10){
                                    Text("Image ID: \(item.id)")
                                    Text("Earth Date: \(String(describing: item.earth_date!))")
                                }
                                
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Text("Rover: ")
                                    Text("\(item.rover_name ?? "")")
                                }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                               
                            }
                            
                            
                            
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                
            } .navigationBarTitle("Favurite Photos")
                .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(
                            destination: MarsImagesView(apiManager: apiManager),
                        label: {
                                Image(systemName: "plus")
                        })
                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
                    
//                }
            }
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredPhotos[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct FavouritePhotosView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePhotosView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
