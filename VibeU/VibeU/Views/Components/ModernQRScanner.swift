import SwiftUI
import AVFoundation

// MARK: - Modern QR Scanner with Liquid Glass (iOS 26)
struct ModernQRScanner: View {
    let onDismiss: () -> Void
    let onScanned: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var cameraPermissionDenied = false
    @State private var scannerActive = true
    
    var body: some View {
        ZStack {
            // Camera Preview
            if scannerActive {
                QRCameraView(onScanned: handleScan, onPermissionDenied: {
                    cameraPermissionDenied = true
                })
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Overlay UI
            VStack {
                // Header
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    Text("QR Tara")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Scan Area
                ZStack {
                    // Outer frame
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 260, height: 260)
                    
                    // Corner highlights
                    ScannerCorners()
                        .frame(width: 260, height: 260)
                    
                    // Scanning Animation
                    ScanningLine()
                        .frame(width: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                
                Spacer()
                
                // Instructions
                VStack(spacing: 12) {
                    Text("VibeU QR Kodunu Tara")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Text("Arkadaşının profilini açmak için QR kodunu çerçeveye hizala")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 80)
            }
            
            // Permission Denied Overlay
            if cameraPermissionDenied {
                permissionDeniedView
            }
        }
    }
    
    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 70, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Kamera İzni Gerekli")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text("QR kod taramak için kamera erişimine ihtiyacımız var. Lütfen ayarlardan izin verin.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                Button {
                    openSettings()
                } label: {
                    Text("Ayarlara Git")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    onDismiss()
                } label: {
                    Text("Vazgeç")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.95))
    }
    
    // MARK: - Functions
    
    private func handleScan(_ code: String) {
        // Parse vibeu://profile/{userId}
        if code.hasPrefix("vibeu://profile/") {
            let userId = String(code.dropFirst("vibeu://profile/".count))
            
            // Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            scannerActive = false
            onScanned(userId)
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - QR Camera View
struct QRCameraView: UIViewRepresentable {
    let onScanned: (String) -> Void
    let onPermissionDenied: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        context.coordinator.setup(in: view, onScanned: onScanned, onPermissionDenied: onPermissionDenied)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var onScanned: ((String) -> Void)?
        var hasProcessed = false
        
        func setup(in view: UIView, onScanned: @escaping (String) -> Void, onPermissionDenied: @escaping () -> Void) {
            self.onScanned = onScanned
            
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.configureSession(in: view)
                }
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            self.configureSession(in: view)
                        } else {
                            onPermissionDenied()
                        }
                    }
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    onPermissionDenied()
                }
            @unknown default:
                break
            }
        }
        
        private func configureSession(in view: UIView) {
            let session = AVCaptureSession()
            session.sessionPreset = .high
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                print("❌ Camera setup failed")
                return
            }
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }
            
            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = view.bounds
            preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(preview)
            
            self.previewLayer = preview
            self.session = session
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !hasProcessed else { return }
            
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let value = object.stringValue else { return }
            
            hasProcessed = true
            session?.stopRunning()
            onScanned?(value)
        }
    }
}

// MARK: - Scanner Corners
struct ScannerCorners: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let size: CGFloat = 35
            let thickness: CGFloat = 4
            
            ZStack {
                // Top Left
                Path { p in
                    p.move(to: CGPoint(x: 0, y: size))
                    p.addLine(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: size, y: 0))
                }
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                
                // Top Right
                Path { p in
                    p.move(to: CGPoint(x: w - size, y: 0))
                    p.addLine(to: CGPoint(x: w, y: 0))
                    p.addLine(to: CGPoint(x: w, y: size))
                }
                .stroke(Color.purple, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                
                // Bottom Left
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h - size))
                    p.addLine(to: CGPoint(x: 0, y: h))
                    p.addLine(to: CGPoint(x: size, y: h))
                }
                .stroke(Color.purple, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                
                // Bottom Right
                Path { p in
                    p.move(to: CGPoint(x: w - size, y: h))
                    p.addLine(to: CGPoint(x: w, y: h))
                    p.addLine(to: CGPoint(x: w, y: h - size))
                }
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            }
        }
    }
}

// MARK: - Scanning Line Animation
struct ScanningLine: View {
    @State private var animating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .cyan.opacity(0.8), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 3)
            .shadow(color: .cyan, radius: 10)
            .offset(y: animating ? 110 : -110)
            .animation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true),
                value: animating
            )
            .onAppear {
                animating = true
            }
    }
}

#Preview {
    ModernQRScanner(onDismiss: {}, onScanned: { _ in })
}
