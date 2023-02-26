//
//  ImageInspectorView.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-22.
//

import SwiftUI


struct ImageInspectorView: View {
    
    @ObservedObject var apiManager:APIManager
    @ObservedObject var selectedImage: CorePhoto
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            VStack{
                
                if !selectedImage.isFault {
                    
                    AsyncImage(url:URL(string: selectedImage.img_src!.replacingOccurrences(of: "http://", with: "https://"))) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 400)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity,maxHeight: 400)
                        case .failure(_):
                            Image("no-photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity,maxHeight: 400)
                        @unknown default:
                            EmptyView()
                        }
                    }

                    Text("Image ID: \(selectedImage.id)").frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    if let cameraFullName = selectedImage.camera_full_name {
                        Text("Camera: \(cameraFullName) - Cam-ID: \(selectedImage.camera_id)").frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    }
                    Text("Sol: \(selectedImage.sol)").frame(maxWidth: .infinity, alignment: .leading).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    Text("Earth Date: \(selectedImage.earth_date!)").frame(maxWidth: .infinity, alignment: .leading)  .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    
                    Spacer()
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done")
                    }).padding(.vertical, 40)
                 
                    Spacer()
                } else {
                    Text("Image ID: No favourites found!")
                    Text("Selected No favourites found!")
                    Text("Sol: No favourites found!")
                    Text("Earth Date: No favourites found!")
                    Text("Image ID:  No favourites found!")
                }
            }.navigationTitle("Image Inspector")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
        }

    }
}

struct ImageInspectorView_Previews: PreviewProvider {
    static var previews: some View {
        let corePhoto = CorePhoto(context: PersistenceController.preview.container.viewContext)
        corePhoto.id = 123
        corePhoto.sol = 456
        corePhoto.earth_date = "2022-01-01"
        corePhoto.img_src = "https://example.com/image.jpg"
        corePhoto.camera_full_name = "Front Camera"
        corePhoto.camera_id = 1

        return NavigationView {
            ImageInspectorView(apiManager: APIManager(), selectedImage: corePhoto)
        }
    }
}


