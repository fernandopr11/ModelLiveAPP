import SwiftUI

struct ContentView: View {
    var body: some View {
        MainViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ContentView()
}
