import UIKit
import FacialAuthFramework

class RegistrationViewController: UIViewController {
    
    // MARK: - Properties
    var facialAuth: FacialAuthManager!
    weak var delegate: RegistrationDelegate?
    
    private var currentUserID: String!
    private var userName: String = ""
    private var isCapturing = false
    
    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registro de Usuario"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa tu nombre y luego escanearemos tu rostro"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Tu nombre completo"
        textField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 25
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowRadius = 4
        textField.textAlignment = .center
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let facePreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cameraGuideView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.layer.cornerRadius = 120
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progressTintColor = .systemGreen
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.transform = CGAffineTransform(scaleX: 1, y: 3)
        progress.isHidden = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Listo para comenzar"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Comenzar Registro", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        addTargets()
        generateUserID()
        animateInitialAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        
        // ✅ AJUSTAR PREVIEW LAYER SI EXISTE
        if isCapturing, let previewLayer = facialAuth?.getCameraPreviewLayer() {
            previewLayer.frame = facePreviewContainer.bounds
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Background gradient
        backgroundGradientLayer.colors = [
            UIColor.systemGreen.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.systemBlue.cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // Add UI elements
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(nameTextField)
        view.addSubview(facePreviewContainer)
        view.addSubview(cameraGuideView)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(startButton)
        view.addSubview(cancelButton)
        
        setupConstraints()
    }
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // Instruction
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Name TextField
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            nameTextField.widthAnchor.constraint(equalToConstant: 280),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Face Preview Container
            facePreviewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facePreviewContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            facePreviewContainer.widthAnchor.constraint(equalToConstant: 280),
            facePreviewContainer.heightAnchor.constraint(equalToConstant: 280),
            
            // Camera Guide
            cameraGuideView.centerXAnchor.constraint(equalTo: facePreviewContainer.centerXAnchor),
            cameraGuideView.centerYAnchor.constraint(equalTo: facePreviewContainer.centerYAnchor),
            cameraGuideView.widthAnchor.constraint(equalToConstant: 240),
            cameraGuideView.heightAnchor.constraint(equalToConstant: 240),
            
            // Progress View
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: facePreviewContainer.bottomAnchor, constant: 20),
            progressView.widthAnchor.constraint(equalToConstant: 280),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Status Label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Start Button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20),
            startButton.widthAnchor.constraint(equalToConstant: 280),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel Button
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addTargets() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        nameTextField.delegate = self
    }
    
    private func generateUserID() {
        currentUserID = UUID().uuidString
    }
    
    // MARK: - Button Actions
    @objc private func startButtonTapped() {
        // 🔨 HARDCODED NAME PARA TESTING - Cambia "Juan Pérez Test" por el nombre que quieras
        userName = "Juan Pérez Test"
        
        if !isCapturing {
            startFaceRegistration()
        }
    }
    
    @objc private func cancelButtonTapped() {
        if isCapturing {
            facialAuth.cancel()
        }
        dismiss(animated: true)
    }
    
    @objc private func nameTextFieldChanged() {
        // 🔨 SIEMPRE HABILITADO PARA TESTING
        startButton.isEnabled = true
        startButton.alpha = 1.0
    }
    
    // MARK: - Registration Flow
    private func startFaceRegistration() {
        isCapturing = true
        
        // Update UI for capture mode
        nameTextField.isEnabled = false
        startButton.setTitle("Escaneando...", for: .normal)
        startButton.isEnabled = false
        
        // Show camera preview
        showCameraPreview()
        
        // ✅ CONFIGURAR PREVIEW DE CÁMARA ANTES DE INICIAR
        facialAuth.setupCameraPreview(in: self, previewView: facePreviewContainer)
        
        // Start facial registration
        facialAuth.registerUser(userId: currentUserID, displayName: userName, in: self)
        
        print("📹 RegistrationViewController: Preview configurado y registro iniciado")
    }
    
    private func showCameraPreview() {
        UIView.animate(withDuration: 0.5) {
            self.facePreviewContainer.isHidden = false
            self.cameraGuideView.isHidden = false
            self.progressView.isHidden = false
        }
        
        // ✅ ASEGURAR QUE EL PREVIEW LAYER SE AJUSTE AL FRAME
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let previewLayer = self.facialAuth.getCameraPreviewLayer() {
                previewLayer.frame = self.facePreviewContainer.bounds
                
                print("📺 RegistrationViewController: Preview layer ajustado")
                print("   - Frame actualizado: \(self.facePreviewContainer.bounds)")
            }
        }
    }
    
    private func resetUI() {
        isCapturing = false
        nameTextField.isEnabled = true
        startButton.setTitle("Comenzar Registro", for: .normal)
        startButton.isEnabled = true
        
        UIView.animate(withDuration: 0.5) {
            self.facePreviewContainer.isHidden = true
            self.cameraGuideView.isHidden = true
            self.progressView.isHidden = true
            self.progressView.progress = 0
        }
    }
    
    // MARK: - UI Helper Methods
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.animateStatusUpdate()
        }
    }
    
    private func updateProgress(_ progress: Float) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.progressView.progress = progress
            }
            
            // Animate guide circle color based on progress
            let color = progress > 0.8 ? UIColor.systemGreen : UIColor.systemOrange
            self.cameraGuideView.layer.borderColor = color.cgColor
        }
    }
    
    private func animateStatusUpdate() {
        UIView.animate(withDuration: 0.3, animations: {
            self.statusLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.statusLabel.transform = .identity
            }
        }
    }
    
    private func animateSuccess() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cameraGuideView.layer.borderColor = UIColor.systemGreen.cgColor
            self.cameraGuideView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.cameraGuideView.transform = .identity
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Registro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func animateInitialAppearance() {
        // Initial state
        titleLabel.alpha = 0
        instructionLabel.alpha = 0
        nameTextField.alpha = 0
        startButton.alpha = 0
        cancelButton.alpha = 0
        statusLabel.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        instructionLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        nameTextField.transform = CGAffineTransform(translationX: 0, y: 30)
        startButton.transform = CGAffineTransform(translationX: 0, y: 40)
        
        // Animate in sequence
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.instructionLabel.alpha = 1
            self.instructionLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.nameTextField.alpha = 1
            self.nameTextField.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.startButton.alpha = 1.0 // Always enabled for testing
            self.startButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 0.9, options: .curveEaseOut, animations: {
            self.cancelButton.alpha = 1
            self.statusLabel.alpha = 1
        })
        
        // Initial button state - always enabled for testing
        startButton.isEnabled = true
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - FacialAuthDelegate
extension RegistrationViewController: FacialAuthDelegate {
    
    // ✅ Métodos de registro
    func registrationDidSucceed(userProfile: UserProfile) {
        updateStatus("¡Registro completado exitosamente! ✅")
        animateSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.registrationDidComplete(userName: self.userName)
        }
    }
    
    func registrationDidFail(error: AuthError) {
        updateStatus("Error: \(error.errorDescription ?? "Desconocido") ❌")
        resetUI()
    }
    
    func registrationProgress(_ progress: Float) {
        updateProgress(progress)
        
        if progress < 0.5 {
            updateStatus("Capturando muestras... \(Int(progress * 100))%")
        } else {
            updateStatus("Entrenando modelo... \(Int(progress * 100))%")
        }
        
        print("📊 RegistrationViewController: Progreso \(Int(progress * 100))%")
    }
    
    func trainingDidStart(mode: TrainingMode) {
        updateStatus("Iniciando entrenamiento...")
    }
    
    func trainingProgress(_ progress: Float, epoch: Int, loss: Float, accuracy: Float) {
        updateStatus("Entrenando: Época \(epoch) - Precisión: \(Int(accuracy * 100))%")
    }
    
    func trainingDidComplete(metrics: TrainingMetrics) {
        updateStatus("Entrenamiento completado en \(String(format: "%.1f", metrics.totalTime))s")
    }
    
    func trainingSampleCaptured(sampleCount: Int, totalNeeded: Int) {
        updateStatus("Muestra \(sampleCount)/\(totalNeeded) capturada")
        
        print("📸 RegistrationViewController: Muestra \(sampleCount)/\(totalNeeded)")
    }
    
    func trainingDataValidated(isValid: Bool, quality: Float) {
        if isValid {
            updateStatus("✅ Muestra válida (calidad: \(Int(quality * 100))%)")
        } else {
            updateStatus("⚠️ Mejora posición del rostro")
        }
    }
    
    func authenticationStateChanged(_ state: AuthState) {
        switch state {
        case .scanning:
            updateStatus("Posiciona tu rostro en el círculo")
        case .processing:
            updateStatus("Procesando datos biométricos...")
        default:
            break
        }
    }
    
    // ✅ Métodos faltantes (vacíos porque no aplican para registro)
    func authenticationDidSucceed(userProfile: UserProfile) {}
    func authenticationDidFail(error: AuthError) {}
    func authenticationDidCancel() {}
    func trainingDidFail(error: AuthError) {}
    func trainingDidCancel() {}
}
