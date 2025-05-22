import SwiftUI
import Foundation


struct IrregularBubbleShape: Shape {
    var seed: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
    
        let randomFactor = Double(seed % 100) / 100.0
        

        let controlPoint1Offset = rect.width * 0.4 * (0.7 + randomFactor * 0.3)
        let controlPoint3Offset = rect.width * 0.5 * (0.65 + randomFactor * 0.35)
        

        path.move(to: CGPoint(x: 0, y: rect.height))
        

        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height * 0.25),
            control: CGPoint(x: rect.width * 0.1 * randomFactor, y: rect.height * 0.6)
        )
        
       
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.2),
            control1: CGPoint(x: controlPoint1Offset, y: 0),
            control2: CGPoint(x: rect.width - controlPoint3Offset, y: 0)
        )
        
        // Right edge with a slight curve
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control: CGPoint(x: rect.width - rect.width * 0.15 * randomFactor, y: rect.height * 0.7)
        )
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    // Background colors
    let bgColor = Color(red: 0.95, green: 0.92, blue: 0.89)
    let darkBrown = Color(red: 0.29, green: 0.16, blue: 0.05)
    
    var body: some View {
        ZStack {
            // Background
            bgColor
                .ignoresSafeArea()
            
            // Top irregular bubble shape
            IrregularBubbleShape(seed: 789)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.05)
                .rotationEffect(.degrees(180))
                .ignoresSafeArea()
            
            // Bottom irregular bubble shape
            IrregularBubbleShape(seed: 321)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.95)
                .ignoresSafeArea()
            
            // Content
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                OnboardingPage(
                    title: "Track foods from around the world",
                    subtitle: "BreadCrumb supports diverse cuisines that are often missing in other tracking apps",
                    imageName: "globe",
                    backgroundColor: Color(red: 0.42, green: 0.26, blue: 0.13)
                )
                .tag(0)
                
                // Page 2: Easy Tracking
                OnboardingPage(
                    title: "Simple calorie tracking",
                    subtitle: "Easily log your meals with our extensive food database",
                    imageName: "fork.knife",
                    backgroundColor: Color(red: 0.62, green: 0.41, blue: 0.21)
                )
                .tag(1)
                
                // Page 3: Diverse Cuisines
                OnboardingPage(
                    title: "Cuisines from every culture",
                    subtitle: "Indian, Mexican, Chinese, Middle Eastern, African, and more",
                    imageName: "takeoutbag.and.cup.and.straw.fill",
                    backgroundColor: Color(red: 0.76, green: 0.58, blue: 0.38)
                )
                .tag(2)
                
                // Page 4: Get Started
                VStack {
                    Spacer()
                    
                    Text("Ready to get started?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        isOnboardingComplete = true
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.86, green: 0.72, blue: 0.53))
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 60)
                }
                .background(
                    Color(red: 0.29, green: 0.16, blue: 0.05)
                        .edgesIgnoringSafeArea(.all)
                )
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct OnboardingPage: View {
    var title: String
    var subtitle: String
    var imageName: String
    var backgroundColor: Color
    
    // For background colors
    let bgColor = Color(red: 0.95, green: 0.92, blue: 0.89)
    
    var body: some View {
        ZStack {
            // Background
            bgColor
                .ignoresSafeArea()
            
            // Bubble background shape with the specified background color
            IrregularBubbleShape(seed: Int.random(in: 100...999))
                .fill(backgroundColor)
                .frame(width: UIScreen.main.bounds.width * 1.8, height: UIScreen.main.bounds.height * 0.6)
                .position(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.1)
                .ignoresSafeArea()
            
            // Bottom bubble shape
            IrregularBubbleShape(seed: Int.random(in: 100...999))
                .fill(backgroundColor.opacity(0.7))
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.3)
                .position(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.95)
                .ignoresSafeArea()
            
            // Content
            VStack {
                Spacer()
                
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(subtitle)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                
                Spacer()
                
                // Spacer at the bottom to push content up
                Spacer()
                    .frame(height: 60)
            }
        }
    }
} 
