//
//  ContentView.swift
//  Enhancing Mobility
//
//  Created by Brenden DeLuna on 11/26/24.
//

import SwiftUI
import AVFoundation

struct HomeScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Central Icon
                    VStack {
                        Image(systemName: "wave.3.forward.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                            .accessibilityLabel("Sonar guiding icon")
                        Text("Enhancing Mobility")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityLabel("Enhancing Mobility app")
                    }

                    // Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: NavigationGuideView()) {
                            Text("Start Navigation")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .accessibilityLabel("Start Navigation")
                        }
                        
                        NavigationLink(destination: CalibrationView()) {
                            Text("Calibration")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .accessibilityLabel("Get Help")
                        }

                        NavigationLink(destination: SettingsView()) {
                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .accessibilityLabel("Open Settings")
                        }
                        
                        NavigationLink(destination: HelpView()) {
                            Text("Help")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .accessibilityLabel("Get Help")
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct NavigationGuideView: View {
    @State private var fromText: String = ""
    @State private var toText: String = ""
    @State private var saveRoute: Bool = false
    @StateObject private var routeManager = RouteManager()
    @ObservedObject var settingsManager = SettingsManager()
    @StateObject private var microphoneHandler = MicrophoneHandler()

    var body: some View {
        VStack(spacing: 50) {
            // From Field
            VStack(alignment: .leading) {
                Text("From:")
                    .font(.headline)
                HStack {
                    TextField("Enter starting location", text: $fromText, onEditingChanged: { editing in
                        handleBrailleKeyboardActivation(isEditing: editing)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        microphoneHandler.playMicrophoneSound()
                        print("Microphone button tapped for From")
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                    }
                }
            }

            // To Field
            VStack(alignment: .leading) {
                Text("To:")
                    .font(.headline)
                HStack {
                    TextField("Enter destination", text: $toText, onEditingChanged: { editing in
                        handleBrailleKeyboardActivation(isEditing: editing)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        microphoneHandler.playMicrophoneSound()
                        print("Microphone button tapped for To")
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                    }
                }
            }

            // Save Route Toggle
            HStack {
                Toggle("", isOn: $saveRoute)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                Text("Save route?")
            }

            // Saved Routes Button
            NavigationLink(destination: SavedRoutesView(routeManager: routeManager)) {
                Text("Saved Routes")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()

            // Begin Navigation Button
            Button(action: {
                handleBeginNavigation()
            }) {
                Text("Begin Navigation")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Navigation")
    }

    // Function to handle Braille keyboard activation
    private func handleBrailleKeyboardActivation(isEditing: Bool) {
        guard isEditing, settingsManager.enableBrailleInput else { return }
        UIAccessibility.post(notification: .announcement, argument: "Braille input is enabled. Use VoiceOver's Braille Screen Input to type.")
    }

    // Function to handle the Begin Navigation button
    private func handleBeginNavigation() {
        if saveRoute, !fromText.isEmpty, !toText.isEmpty {
            let route = Route(from: fromText, to: toText)
            routeManager.saveRoute(route)
        }
        print("Begin Navigation tapped")
    }
}


struct CameraView: View {
    var body: some View {
        VStack {
            Text("Camera Screen")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Navigation") // Title at the top
        .edgesIgnoringSafeArea(.all) // Makes the camera view fullscreen
        .background(CameraPreview()) // Custom camera preview view
    }
}

// Camera Preview View
struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        let camera = AVCaptureDevice.default(for: .video)
        let input = try? AVCaptureDeviceInput(device: camera!)
        if let input = input {
            session.addInput(input)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        session.startRunning()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct NavigationGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationGuideView()
    }
}

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager()

    var body: some View {
        NavigationStack {
            Form {
                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    Picker("Text Size", selection: $settingsManager.textSize) {
                        Text("Small").tag(0)
                        Text("Medium").tag(1)
                        Text("Large").tag(2)
                    }
                    Toggle("High Contrast Mode", isOn: $settingsManager.highContrastMode)
                    Toggle("Haptic Feedback", isOn: $settingsManager.hapticFeedback)
                    Toggle("Use Audio Assistance", isOn: $settingsManager.useAudioAssistance)
                    Toggle("Enable Braille Input", isOn: $settingsManager.enableBrailleInput)
                }

                // Audio Section
                Section(header: Text("Audio")) {
                    Toggle("Mute Voice Guidance", isOn: $settingsManager.muteVoiceGuidance)
                }

                // Navigation Section
                Section(header: Text("Navigation")) {
                    Picker("Preferred Route Type", selection: $settingsManager.preferredRouteType) {
                        Text("Shortest Path").tag(0)
                        Text("Easiest Path").tag(1)
                        Text("Wheelchair Accessible").tag(2)
                    }
                    Toggle("Save Routes Automatically", isOn: $settingsManager.autoSaveRoutes)
                    NavigationLink(destination: FrequentDestinationsView(settingsManager: settingsManager)) {
                        Text("Manage Frequent Destinations")
                    }
                }

                // Privacy Section
                Section(header: Text("Privacy")) {
                    Button("Clear All Data") {
                        settingsManager.clearAllData()
                    }
                    Button("Backup Data") {
                        let backup = settingsManager.backupData()
                        print("Backup Data: \(backup)")
                    }
                    Button("Restore Data") {
                        // Example restore logic
                        let sampleBackup: [String: Any] = [
                            "TextSize": 1,
                            "HighContrastMode": true,
                            "HapticFeedback": true,
                            "MuteVoiceGuidance": false,
                            "PreferredRouteType": 0,
                            "AutoSaveRoutes": true,
                            "FrequentDestinations": ["Work", "Home"]
                        ]
                        settingsManager.restoreData(from: sampleBackup)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct CalibrationView: View {
    @State private var isSpeaking = false
    @StateObject private var settingsManager = SettingsManager() // Use the shared manager

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Apple AR Moving Logo Simulation
                Image(systemName: "arkit") // Placeholder for the AR logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.blue)
                    .accessibilityLabel("AR Moving Logo")

                Spacer()

                // Instruction Text
                Text("Move iPhone to calibrate")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibilityLabel("Instruction: Continue to move iPhone")

                Spacer()
            }
            .navigationTitle("Calibration")
            .onAppear {
                if settingsManager.useAudioAssistance {
                    speakInstruction()
                }
            }
        }
    }

    // Function to Play Audio Instructions
    private func speakInstruction() {
        guard !isSpeaking else { return }
        isSpeaking = true
        let utterance = AVSpeechUtterance(string: "Move iPhone around slowly to scan the environment")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        AVSpeechSynthesizer().speak(utterance)
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView()
    }
}

struct HelpView: View {
    var body: some View {
        NavigationView {
            List {
                // Introduction Section
                Section(header: Text("Introduction")) {
                    Text("""
                        The Enhancing Mobility App is designed to assist visually impaired users with indoor navigation. With features such as voice guidance, route saving, and AR-based calibration, the app provides an intuitive and efficient navigation experience.
                        """)
                        .font(.body)
                        .padding(.vertical, 5)
                }
                
                // App Features Section
                Section(header: Text("App Features")) {
                    featuresList
                }

                // Getting Started Section
                Section(header: Text("Getting Started")) {
                    Text("""
                        1. Download and install the app from the App Store.
                        2. Grant permissions for microphone, speech recognition, and camera.
                        3. Launch the app to access its core features from the Home Screen.
                        """)
                        .font(.body)
                        .padding(.vertical, 5)
                }
                
                // Main Screens and Functions Section
                Section(header: Text("Main Screens and Their Functions")) {
                    NavigationLink(destination: HelpDetailsView(title: "Home Screen", content: homeScreenContent)) {
                        Text("Home Screen")
                    }
                    NavigationLink(destination: HelpDetailsView(title: "Navigation Menu", content: navigationMenuContent)) {
                        Text("Navigation Menu")
                    }
                    NavigationLink(destination: HelpDetailsView(title: "Calibration", content: calibrationContent)) {
                        Text("Calibration")
                    }
                    NavigationLink(destination: HelpDetailsView(title: "Settings", content: settingsContent)) {
                        Text("Settings")
                    }
                    NavigationLink(destination: HelpDetailsView(title: "Saved Routes", content: savedRoutesContent)) {
                        Text("Saved Routes")
                    }
                    NavigationLink(destination: HelpDetailsView(title: "Frequent Destinations", content: frequentDestinationsContent)) {
                        Text("Frequent Destinations")
                    }
                }
                
                // FAQs and Troubleshooting Section
                Section(header: Text("FAQs and Troubleshooting")) {
                    NavigationLink(destination: HelpDetailsView(title: "FAQs", content: faqContent)) {
                        Text("FAQs")
                    }
                }
                
                // Contact and Support Section
                Section(header: Text("Contact and Support")) {
                    Text("""
                        - Support Email: support@enhancingmobility.com
                        - Website: www.enhancingmobility.com
                        - Feedback: Use the Help section in the app to submit your feedback.
                        """)
                        .font(.body)
                        .padding(.vertical, 5)
                }
            }
            .navigationTitle("Help")
        }
    }

    // Features List
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("• Voice Guidance: Audio prompts for navigation, including voice input for destinations.")
            Text("• Saved Routes: Save and manage frequently used routes.")
            Text("• Frequent Destinations: Quickly access commonly used locations.")
            Text("• AR Calibration: Calibrate the app for better navigation accuracy.")
            Text("• Customizable Settings: Adjust text size, contrast, feedback, and navigation preferences.")
            Text("• Privacy Features: Backup, restore, and clear your saved data.")
        }
        .font(.body)
        .padding(.vertical, 5)
    }

    // Help Content for Each Section
    private let homeScreenContent = """
    The first screen you see when launching the app. Features buttons to navigate to:
    - Start Navigation: Opens the navigation menu.
    - Calibration: Calibrates the app for improved accuracy.
    - Settings: Adjust preferences and configurations.
    - Help: Provides guidance on using the app.
    """

    private let navigationMenuContent = """
    Features:
    - From/To Fields: Enter starting and destination locations manually or use the microphone button for voice input.
    - Save Route Toggle: Enable this toggle to save the entered route to your saved routes list.
    - Saved Routes Button: View and manage previously saved routes.
    - Begin Navigation: Starts navigation for the entered route.
    - Saved Routes Management:
        - View Saved Routes: Access a list of all saved routes.
        - Delete Routes: Swipe left on a route to delete it.
        - Clear All Routes: Tap the "Clear All Routes" button to remove all saved routes.
    """

    private let calibrationContent = """
    - Displays an AR moving logo and instructions for calibration.
    - Audio Assistance: If enabled, the app audibly guides you to move your iPhone to scan the environment.
    Instructions:
    - Move your iPhone slowly around the environment for accurate calibration.
    """

    private let settingsContent = """
    Accessibility Settings:
    - Adjust text size (Small, Medium, Large).
    - Enable/disable high contrast mode for improved visibility.
    - Toggle haptic feedback for physical confirmation of actions.
    Audio Settings:
    - Mute voice guidance during navigation if needed.
    Navigation Preferences:
    - Select a preferred route type:
        - Shortest Path
        - Easiest Path
        - Wheelchair Accessible
    - Enable/disable automatic route saving.
    - Manage frequent destinations.
    Privacy Settings:
    - Clear all saved data.
    - Backup and restore settings and routes.
    """

    private let savedRoutesContent = """
    - Displays a list of saved routes with options to:
    - Delete individual routes via swipe-to-delete.
    - Clear all routes using the "Clear All Routes" button.
    """

    private let frequentDestinationsContent = """
    Manage a list of commonly used locations:
    - Add new destinations by typing in a text box and tapping the "+" button.
    - Delete destinations using swipe-to-delete.
    """

    private let faqContent = """
    Q: How do I save a route?
    A: Enter the "From" and "To" locations in the Navigation Menu, enable the "Save Route?" toggle, and tap "Begin Navigation."
    
    Q: How do I delete saved routes?
    A: Swipe left on a route in the Saved Routes screen or use the "Clear All Routes" button.
    
    Q: Why isn’t the app providing audio guidance?
    A: Ensure "Use Audio Assistance" is enabled in the Settings menu and that microphone permissions are granted.

    Q: How do I calibrate the app?
    A: Go to Calibration from the Home Screen, and follow the on-screen or voice instructions.
    
    Q: How do I manage frequent destinations?
    A: Navigate to Settings > Manage Frequent Destinations to add or delete destinations.
    """

}

struct HelpDetailsView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .padding()
        }
        .navigationTitle(title)
    }
}


struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}

class MicrophoneHandler: ObservableObject {
    // Play Microphone Activation Sound
    func playMicrophoneSound() {
        AudioServicesPlaySystemSound(1117) // Default Apple microphone activation sound
    }
}

import Foundation

class SettingsManager: ObservableObject {
    @Published var enableBrailleInput: Bool {
            didSet {
                UserDefaults.standard.set(enableBrailleInput, forKey: "EnableBrailleInput")
            }
        }
    
    @Published var textSize: Int {
        didSet { UserDefaults.standard.set(textSize, forKey: "TextSize") }
    }
    @Published var highContrastMode: Bool {
        didSet { UserDefaults.standard.set(highContrastMode, forKey: "HighContrastMode") }
    }
    @Published var hapticFeedback: Bool {
        didSet { UserDefaults.standard.set(hapticFeedback, forKey: "HapticFeedback") }
    }
    @Published var muteVoiceGuidance: Bool {
        didSet { UserDefaults.standard.set(muteVoiceGuidance, forKey: "MuteVoiceGuidance") }
    }
    @Published var preferredRouteType: Int {
        didSet { UserDefaults.standard.set(preferredRouteType, forKey: "PreferredRouteType") }
    }
    @Published var autoSaveRoutes: Bool {
        didSet { UserDefaults.standard.set(autoSaveRoutes, forKey: "AutoSaveRoutes") }
    }
    @Published var frequentDestinations: [String] {
        didSet { UserDefaults.standard.set(frequentDestinations, forKey: "FrequentDestinations") }
    }
    
    @Published var useAudioAssistance: Bool {
            didSet {
                UserDefaults.standard.set(useAudioAssistance, forKey: "UseAudioAssistance")
            }
        }

    init() {
        self.enableBrailleInput = UserDefaults.standard.bool(forKey: "EnableBrailleInput")
        self.useAudioAssistance = UserDefaults.standard.bool(forKey: "UseAudioAssistance")
        textSize = UserDefaults.standard.integer(forKey: "TextSize")
        highContrastMode = UserDefaults.standard.bool(forKey: "HighContrastMode")
        hapticFeedback = UserDefaults.standard.bool(forKey: "HapticFeedback")
        muteVoiceGuidance = UserDefaults.standard.bool(forKey: "MuteVoiceGuidance")
        preferredRouteType = UserDefaults.standard.integer(forKey: "PreferredRouteType")
        autoSaveRoutes = UserDefaults.standard.bool(forKey: "AutoSaveRoutes")
        frequentDestinations = UserDefaults.standard.array(forKey: "FrequentDestinations") as? [String] ?? []
    }

    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: "TextSize")
        UserDefaults.standard.removeObject(forKey: "HighContrastMode")
        UserDefaults.standard.removeObject(forKey: "HapticFeedback")
        UserDefaults.standard.removeObject(forKey: "MuteVoiceGuidance")
        UserDefaults.standard.removeObject(forKey: "PreferredRouteType")
        UserDefaults.standard.removeObject(forKey: "AutoSaveRoutes")
        UserDefaults.standard.removeObject(forKey: "FrequentDestinations")
    }

    func backupData() -> [String: Any] {
        return [
            "TextSize": textSize,
            "HighContrastMode": highContrastMode,
            "HapticFeedback": hapticFeedback,
            "MuteVoiceGuidance": muteVoiceGuidance,
            "PreferredRouteType": preferredRouteType,
            "AutoSaveRoutes": autoSaveRoutes,
            "FrequentDestinations": frequentDestinations
        ]
    }

    func restoreData(from backup: [String: Any]) {
        textSize = backup["TextSize"] as? Int ?? textSize
        highContrastMode = backup["HighContrastMode"] as? Bool ?? highContrastMode
        hapticFeedback = backup["HapticFeedback"] as? Bool ?? hapticFeedback
        muteVoiceGuidance = backup["MuteVoiceGuidance"] as? Bool ?? muteVoiceGuidance
        preferredRouteType = backup["PreferredRouteType"] as? Int ?? preferredRouteType
        autoSaveRoutes = backup["AutoSaveRoutes"] as? Bool ?? autoSaveRoutes
        frequentDestinations = backup["FrequentDestinations"] as? [String] ?? frequentDestinations
    }
}


class RouteManager: ObservableObject {
    @Published var savedRoutes: [Route] = [] {
        didSet {
            saveRoutesToUserDefaults()
        }
    }

    init() {
        loadRoutesFromUserDefaults()
    }

    func saveRoute(_ route: Route) {
        savedRoutes.append(route)
    }

    private func saveRoutesToUserDefaults() {
        let routesData = try? JSONEncoder().encode(savedRoutes)
        UserDefaults.standard.set(routesData, forKey: "SavedRoutes")
    }

    private func loadRoutesFromUserDefaults() {
        if let routesData = UserDefaults.standard.data(forKey: "SavedRoutes"),
           let routes = try? JSONDecoder().decode([Route].self, from: routesData) {
            savedRoutes = routes
        }
    }
}

struct SavedRoutesView: View {
    @ObservedObject var routeManager: RouteManager

    var body: some View {
        VStack {
            // List of Saved Routes
            List {
                if routeManager.savedRoutes.isEmpty {
                    Text("No saved routes yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(routeManager.savedRoutes, id: \.self) { route in
                        VStack(alignment: .leading) {
                            Text("From: \(route.from)")
                                .font(.headline)
                            Text("To: \(route.to)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteRoute) // Enable swipe-to-delete
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Saved Routes")

            // Clear All Button
            if !routeManager.savedRoutes.isEmpty {
                Button(action: {
                    clearAllRoutes()
                }) {
                    Text("Clear All Routes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }

    // Function to delete a single route
    private func deleteRoute(at offsets: IndexSet) {
        routeManager.savedRoutes.remove(atOffsets: offsets)
    }

    // Function to clear all routes
    private func clearAllRoutes() {
        routeManager.savedRoutes.removeAll()
    }
}

struct Route: Hashable, Codable {
    let from: String
    let to: String
}

struct FrequentDestinationsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @State private var newDestination = ""

    var body: some View {
        VStack {
            List {
                ForEach(settingsManager.frequentDestinations, id: \.self) { destination in
                    Text(destination)
                }
                .onDelete(perform: deleteDestination)
            }
            HStack {
                TextField("Add Destination", text: $newDestination)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addDestination) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Frequent Destinations")
    }

    private func addDestination() {
        guard !newDestination.isEmpty else { return }
        settingsManager.frequentDestinations.append(newDestination)
        newDestination = ""
    }

    private func deleteDestination(at offsets: IndexSet) {
        settingsManager.frequentDestinations.remove(atOffsets: offsets)
    }
}
