import SwiftUI
import UIKit

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var isPressed: Bool = false
    @State private var selectedGenre: String = ""
    
    private let genres = ["Action", "Rex", "Comedy", "Drama", "Fantasy", "Horror", "Romance"]
    private let angleOffset: Double = 0 // Base angle offset for all genres

    // Define custom rotation angles for each genre
    private let customAngles: [Double] = [-180, -75, 30, -230, -130, -30, 80]
    
    // Define custom radius for each genre
    private let customRadii: [Double] = [100, 90, 90, 90, 90, 90, 90] // Adjust radius for specific genres if needed
    
    private func calculateSelectedGenre(finalRotation: Double) {
        let normalizedRotation = finalRotation.truncatingRemainder(dividingBy: 360)
        let angleStep = 360.0 / Double(genres.count)
        
        for index in 0..<genres.count {
            let startAngle = angleStep * Double(index)
            let endAngle = angleStep * Double(index + 1)
            if startAngle <= normalizedRotation && normalizedRotation < endAngle {
                selectedGenre = genres[index]
                return
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(selectedGenre)
                .font(.largeTitle)
                .padding()
                .offset(y: 190) // Move the selected word down
                .scaleEffect(selectedGenre.isEmpty ? 1 : 1.2) // Bounce effect
                .opacity(selectedGenre.isEmpty ? 0 : 1) // Fade-in effect
                .animation(
                    .easeInOut(duration: 0.4)
                    .repeatCount(1, autoreverses: true)
                    .delay(0.1), value: selectedGenre
                )
            
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
                        let textAngle = -angle + customAngles[index]
                        
                        Text(genre)
                            .font(.headline)
                            .rotationEffect(.degrees(textAngle)) // Rotate text to fit around the circle and apply individual angle
                            .position(
                                x: radius + textRadius * CGFloat(cos(angle * .pi / 180)),
                                y: radius + textRadius * CGFloat(sin(angle * .pi / 180))
                            )
                            .fixedSize() // Prevents text from being truncated
                    }
                }
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Change outline color to white
                .rotationEffect(.degrees(rotation))
                .animation(.easeOut(duration: 3.0), value: rotation) // Smooth decelerating rotation animation
                
                // Red line at the top of the wheel
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: 50)
                    .offset(y: -125) // Adjust the position to move it down
                
                // Spinner Button
                Button(action: {
                    // Trigger haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let spin = Double.random(in: 0..<360)
                        withAnimation(.easeOut(duration: 3.0)) {
                            rotation += spin + 3600 // Spin multiple times
                            isPressed = false
                        }
                        
                        // Calculate the final genre after the wheel stops spinning
                        let finalRotation = rotation + spin + 3600
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            calculateSelectedGenre(finalRotation: finalRotation)
                        }
                    }
                }) {
                    Text("Roll")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle()) // Make the button circular
                        .frame(width: 80, height: 80) // Set the button's frame to be a square
                        .scaleEffect(isPressed ? 0.8 : 1.0) // Scale down when pressed
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 + 250) // Fixed position for the button
            }
        }
        .edgesIgnoringSafeArea(.all) // Extend content to the edges of the screen
    }
}

#Preview {
    ContentView()
}
