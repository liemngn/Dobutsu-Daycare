//
//  ContentView.swift
//  myvirtualpet
//
//  Created by Liem Nguyen on 11/5/21.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State var started = false
    @State var leaveGame = false
    @State var isDog = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            StartScreen(started: $started, isDog: $isDog)
            
            if started {
                ARViewContainer(isDog: self.isDog)
                BackToMainMenu(leaveGame: $leaveGame, started: $started)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var isDog: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // Load the "Box" scene from the "Experience" Reality File
        // Add the box anchor to the scene
        if isDog {
            let dogAnchor = try! Experience.loadDog()
            arView.scene.anchors.append(dogAnchor)
        }
        else {
            let catAnchor = try! Experience.loadCat()
            arView.scene.anchors.append(catAnchor)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

/*struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}*/

struct BackToMainMenu: View {
    @Binding var leaveGame: Bool
    @Binding var started: Bool
    
    var body: some View {
        Button(action: {
            leaveGame = true
        }) {
            Image(systemName: "arrow.left.circle.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .font(.title)
            .background(Color.white)
            .clipShape(Circle())
        }.padding()
        .alert("Exit to Main Menu?", isPresented: $leaveGame) {
            Button(role: .destructive) {
                started = false
            } label: {
                Text("Exit")
            }
        }
    }
}

struct StartScreen: View {
    @Binding var started: Bool
    @Binding var isDog: Bool
    @State var choosingPet = false
    @State var petConfirmed = false
    @State var dogSelected = false
    @State var catSelected = false
    @State var chosenPet = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Background()
            VStack {
                Image("dd")
                    .resizable()
                    .frame(width: 350, height: 300)
                Image("logo")
                    .resizable()
                    .frame(width: 250, height: 150)
                    .offset(x: 0, y: -40)
                    .padding(.bottom, 25)
                StartScreenButtons(started: $started, choosingPet: $choosingPet, petConfirmed: $petConfirmed)
            
                if choosingPet {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 30) {
                            Button(action: {
                                chosenPet = "dog"
                                choosingPet = true
                                petConfirmed = true
                                dogSelected = true
                                catSelected = false
                                isDog = true
                            }) {
                                Image("choose_dog")
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1, contentMode: .fit)
                                .cornerRadius(12)
                            }.background(dogSelected ? Color.white : Color.gray)
                            
                            Button(action: {
                                chosenPet = "cat"
                                choosingPet = true
                                petConfirmed = true
                                catSelected = true
                                dogSelected = false
                                isDog = false
                            }) {
                                Image("choose_cat")
                                .resizable()
                                .frame(height: 80)
                                .aspectRatio(1/1, contentMode: .fit)
                                .cornerRadius(12)
                            }.background(catSelected ? Color.white : Color.gray)
                        }
                    }
                    .frame(alignment: .bottom)
                    .padding()
                    .background(Color.black.opacity(0.5))
                }
            }
        }
    }
}

struct Background: View {
    @State var animating = false
    
    var itemsPerRow = 5
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<getRows()) { row in
                HStack(spacing: 0) {
                    ForEach(0..<itemsPerRow) { _ in
                        Image(getImg(row))
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(
                                width: UIScreen.main.bounds.width/CGFloat(itemsPerRow),
                                height: UIScreen.main.bounds.width/CGFloat(itemsPerRow)
                            )
                            .opacity(animating ? 1 : 0)
                            .animation(
                                .linear(duration: Double.random(in: 2.0...3.0))
                                .repeatForever(autoreverses: true)
                            )
                    }
                }
            }
        }
        .onAppear() {
            animating = true
        }
        .background(.white)
    }
    
    func getImg(_ row: Int) -> String {
        var img: String = ""
        let roll = Int.random(in: 0...9)
        
        switch roll {
        case 0:
            img = "dog"
        case 1:
            img = "dog_paw"
        case 2:
            img = "bone"
        case 3:
            img = "collar"
        case 4:
            img = "bowl"
        case 5:
            img = "scratch_post"
        case 6:
            img = "cat_butt"
        case 7:
            img = "cat_paw"
        case 8:
            img = "cat"
        case 9:
            img = "dog_and_cat"
        default:
            break;
        }
        
        return img
    }
    
    func getRows() -> Int {
        return Int(UIScreen.main.bounds.height/(UIScreen.main.bounds.width/CGFloat(itemsPerRow)))
    }
}

struct StartScreenButtonsStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 215, height: 65)
            .foregroundColor(.white)
            .background(Color(red: 1, green: 0.70, blue: 0.25))
            .cornerRadius(100)
            .overlay(RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.black, lineWidth: 4))
    }
}

struct StartScreenButtons: View {
    @Binding var started: Bool
    @Binding var choosingPet: Bool
    @Binding var petConfirmed: Bool
    @State var showAlert = false
    
    var body: some View {
        Button(action: {
            if petConfirmed {
                started = true
                choosingPet = false
            } else {
                showAlert = true
            }
        }) {
            Text("Play")
                .font(.title)
                .fontWeight(.bold)
        }
        .buttonStyle(StartScreenButtonsStyle())
        .alert("Please select a pet.", isPresented: $showAlert) {
            Button("Okay") {}
        }
        
        Button(action: {
            choosingPet = true
        }) {
            Text("Choose Pet")
                .font(.title)
                .fontWeight(.bold)
        }
        .buttonStyle(StartScreenButtonsStyle())
        .padding(.top, 15)
        .padding(.bottom, 15)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
