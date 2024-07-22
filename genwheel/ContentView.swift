import SwiftUI
import UIKit

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var isPressed: Bool = false
    
    private let genres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Romance"]
    private let angleOffset: Double = 0 // Base angle offset for all genres

    // Define custom rotation angles for each genre
    private let customAngles: [Double] = [-180, -75, 30, -230, -130, -30, 80]
    
    // Define custom radius for each genre
    private let customRadii: [Double] = [100, 90, 90, 90, 90, 90, 90] // Adjust radius for specific genres if needed
    
    var body: some View {
        VStack {
            ZStack {
                // The wheel
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let radius = size / 2
                    let angleStep = 360.0 / Double(genres.count)
                    
                    ForEach(0..<genres.count, id: \.self) { index in
                        let angle = angleStep * Double(index) + angleOffset
                        let genre = genres[index]
                        let textRadius = customRadii[index] // Use custom radius for each genre
                        
                        Text(genre)
                            .font(.headline)
                            .rotationEffect(.degrees(-angle + customAngles[index])) // Rotate text to fit around the circle and apply individual angle
                            .position(
                                x: radius + textRadius * CGFloat(cos(angle * .pi / 180)),
                                y: radius + textRadius * CGFloat(sin(angle * .pi / 180))
                            )
                            .fixedSize() // Prevents text from being truncated
                    }
                }
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .rotationEffect(.degrees(rotation))
                .animation(.easeInOut(duration: 1.0), value: rotation) // Smooth rotation animation
                
                // Spinner Button
                VStack {
                    Spacer()
                    Button(action: {
                        // Trigger haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPressed = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let spin = Double.random(in: 0..<360)
                            withAnimation(.easeInOut(duration: 1.0)) {
                                rotation += spin + 3600 // Spin multiple times
                                isPressed = false
                            }
                        }
                    }) {
                        Text("pin")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .scaleEffect(isPressed ? 0.8 : 1.0) // Scale down when pressed
                    }
                    .padding()
                }
            }
        }
        .background(Color.white) // Set background to white
        .edgesIgnoringSafeArea(.all) // Extend content to the edges of the screen
    }
}

#Preview {
    ContentView()
}
