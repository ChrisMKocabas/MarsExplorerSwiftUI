//
//  FavouritePhotosView.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-22.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

struct MarsImagesView: View {
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var firestoreManager: FirestoreManager
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
                        Button(action: {
                            Task {
                                await addItem()
                            }
                        }) {
                            Text("Save")
                        }
                    }
                }

        }.onAppear() {
            Task {
                await refreshImage()
                firestoreManager.fetchUserPhotos()
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
    
    private func addItem() async {
        if selectedImage != "........" {
            let photo:Photo = apiManager.photosResponse.photos[0]
            saveToCoreData(photo: photo)
            let user = viewModel.user
            print(user!.uid)
            
            let url = URL(string: photo.img_src)!

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error downloading image: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                do {
                    let photoData = Data(data)
                    
                    let db = Firestore.firestore()
                    
                    
                    // Get a reference to the user's document
                    let userDocRef = db.collection("users").document(user?.uid ?? "")
                    
                    // Create a new document with a custom ID in the "photos" collection that includes the user ID
                    let newPhotoDocRef = userDocRef.collection("photos").document("\(photo.id)")
                    
                    // Create a reference to the Firebase Storage bucket using a custom path that includes the user ID and the photo ID
                    let photoRef = Storage.storage().reference(withPath: "images/\(user!.uid.description)/photos/\(photo.id).jpg")
                
                    // Upload the photo data to Firebase Storage
                    photoRef.putData(photoData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo to Firebase Storage: \(error.localizedDescription)")
                        } else {
                            // Get the download URL of the uploaded photo
                            photoRef.downloadURL { (url, error) in
                                if let error = error {
                                    print("Error getting download URL: \(error.localizedDescription)")
                                } else if let url = url {
                                    // Save the photo details and download URL to Firestore
                                    newPhotoDocRef.setData([
                                        "id": photo.id,
                                        "sol": photo.sol,
                                        "img_src": photo.img_src,
                                        "earth_date": photo.earth_date,
                                        "rover": [
                                            "id": photo.rover.id,
                                            "name": photo.rover.name,
                                            "landing_date": photo.rover.landing_date,
                                            "launch_date": photo.rover.launch_date,
                                            "status": photo.rover.status
                                        ],
                                        "camera": [
                                            "id": photo.camera.id,
                                            "name": photo.camera.name,
                                            "rover_id": photo.camera.rover_id,
                                            "full_name": photo.camera.full_name
                                        ],
                                        "download_url": url.absoluteString
                                    ])
                                }
                            }
                        }
                    }
                    
                }
                
            }.resume()
            
            withAnimation {
                displayMessage(message: "Added to favourites!")
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
    
    func saveToCoreData(photo:Photo){
        let newPhoto:CorePhoto = CorePhoto(context: viewContext)
        newPhoto.id = Int64(photo.id)
        newPhoto.sol = Int64(photo.sol)
        newPhoto.img_src = photo.img_src
        newPhoto.earth_date = photo.earth_date
        newPhoto.rover_id = Int64(photo.rover.id)
        newPhoto.rover_landing_date = photo.rover.landing_date
        newPhoto.rover_launch_date = photo.rover.launch_date
        newPhoto.rover_name = photo.rover.name
        newPhoto.rover_status = photo.rover.status
        newPhoto.camera_id = Int64(photo.camera.id)
        newPhoto.camera_full_name = photo.camera.full_name
        newPhoto.camera_name = photo.camera.name
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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


