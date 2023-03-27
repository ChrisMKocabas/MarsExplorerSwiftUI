//
//  FavouritePhotosView.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-22.
//

import SwiftUI

struct MarsImagesView: View {
    
    @ObservedObject var apiManager:APIManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    

    var dateClosedRange: ClosedRange<Date> {
        let components = DateComponents(year: 2004, month: 1, day: 1)
        let min = Calendar.current.date(from: components)!
        let max = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return min...max
    }

    @State var selectedImage = ""
    @State var numberOfImages = "Number of images: 0"
    

    var body: some View {
  
        ZStack{
            VStack{
                
                Spacer()
                
                //Asynchronous Image View
                
                AsyncImage(url:URL(string: selectedImage.replacingOccurrences(of: "http://", with: "https://"))) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 350)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity,maxHeight: 350)
                    case .failure(_):
                        Image("no-photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .greatestFiniteMagnitude,maxHeight: 350)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                
                //Rover Picker
                Picker("Pick a rover", selection: $apiManager.selectedRover.projectedValue) { // 3
                    
                    ForEach($apiManager.roverList.projectedValue, id: \.self) { item in // 4
                        Text("\(item.wrappedValue.capitalized)") // 5
                    }
                }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal,20).padding( .vertical, 20)
                    .onChange(of: $apiManager.selectedRover.wrappedValue) { newValue in
                        Task {
                            await refreshImage()
                        }
                    }
                
                //Date Picker
                DatePicker(
                    selection: $apiManager.selectedDate.projectedValue,
                    in: dateClosedRange,
                    displayedComponents: [ .date],
                    label: { Text("Date") }
                ).padding(.horizontal, 50)
                    .onChange(of: $apiManager.selectedDate.wrappedValue) { newValue in
                        Task {
                            await refreshImage()
                        }
                    }
                
                //Number of Images Display
                Text(numberOfImages).frame(maxWidth: .infinity, alignment: .leading).padding()
                
                //Image Picker
                Picker("Image", selection: $selectedImage) {
                    
                    ForEach(apiManager.photosResponse.photos, id: \.img_src) { photo in
                        Text("\(photo.id)").tag(photo.img_src)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
 
                
                Spacer()
                
            }   .navigationTitle("Explore Mars")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                       .navigationBarItems(leading:
                           Button(action: {
                               self.presentationMode.wrappedValue.dismiss()
                           }, label: {
                               Text("Back")
                           })
                       )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addItem) {
                            Text("Save")
                        }
                    }
                }

        }.onAppear() {
            Task {
                await refreshImage()
            }
        }
        

        
    }
    
    func refreshImage() async -> Void {
            do {
                try await apiManager.fetchPhotos()
                 if (apiManager.photosResponse.photos.count > 0)
                {selectedImage = apiManager.photosResponse.photos[0].img_src
                 numberOfImages = "Number of images: \(apiManager.photosResponse.photos.count)"
                 }
                else {
                    selectedImage = "........"
                    numberOfImages = "Number of images: 0"
                }
            } catch {
                
            }
    }
    
    private func addItem() {
        if selectedImage != "........" {
            withAnimation {
                let newPhoto:CorePhoto = CorePhoto(context: viewContext)
                newPhoto.id = Int64(apiManager.photosResponse.photos[0].id)
                newPhoto.sol = Int64(apiManager.photosResponse.photos[0].sol)
                newPhoto.img_src = apiManager.photosResponse.photos[0].img_src
                newPhoto.earth_date = apiManager.photosResponse.photos[0].earth_date
                newPhoto.rover_id = Int64(apiManager.photosResponse.photos[0].rover.id)
                newPhoto.rover_landing_date = apiManager.photosResponse.photos[0].rover.landing_date
                newPhoto.rover_launch_date = apiManager.photosResponse.photos[0].rover.launch_date
                newPhoto.rover_name = apiManager.photosResponse.photos[0].rover.name
                newPhoto.rover_status = apiManager.photosResponse.photos[0].rover.status
                newPhoto.camera_id = Int64(apiManager.photosResponse.photos[0].camera.id)
                newPhoto.camera_full_name = apiManager.photosResponse.photos[0].camera.full_name
                newPhoto.camera_name = apiManager.photosResponse.photos[0].camera.name
                do {
                    try viewContext.save()
                    displayMessage(message: "Added to favourites!")
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        } else {
            displayMessage(message: "Please select an image first!")
        }
    }
    
    func displayMessage(message : String) {
        self.numberOfImages = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.numberOfImages = "Number of images: \(apiManager.photosResponse.photos.count)"
        }
    }
        

}



struct MarsImagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarsImagesView(apiManager: APIManager())
        }
    }
}


