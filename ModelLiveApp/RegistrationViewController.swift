import UIKit
import FacialAuthFramework

class RegistrationViewController: UIViewController {
    
    // MARK: - Properties
    var facialAuth: FacialAuthManager!
    weak var delegate: RegistrationDelegate?
    
    private var currentUserID: String!
    private var userName: String = ""
    private var isCapturing = false
    private var existingUserNames: [String] = [];
    
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
        loadExistingUserNames();
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
        
        // Setup text field
        setupTextField()
        
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
    
    // ✅ NUEVO MÉTODO: Cargar nombres existentes para validación
    private func loadExistingUserNames() {
        print("📋 RegistrationViewController: Cargando nombres existentes...")
        
        do {
            let userIds = try facialAuth.getAllRegisteredUsers()
            existingUserNames = []
            
            for userId in userIds {
                if let profile = try facialAuth.getUserProfileInfo(userId: userId) {
                    let name = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // ✅ DEBUG: Ver qué displayName tiene cada perfil
                    print("🔍 Debug - userId: \(userId)")
                    print("🔍 Debug - displayName en perfil: '\(profile.displayName)'")
                    print("🔍 Debug - nombre procesado: '\(name)'")
                    
                    if !name.isEmpty && !name.hasPrefix("Usuario ") { // ✅ Filtrar los "Usuario XXXX"
                        existingUserNames.append(name.lowercased())
                    }
                }
            }
            
            print("✅ RegistrationViewController: \(existingUserNames.count) nombres válidos cargados")
            for name in existingUserNames {
                print("   - \(name)")
            }
            
        } catch {
            print("❌ RegistrationViewController: Error cargando nombres: \(error)")
            existingUserNames = []
        }
    }
    
    // ✅ VALIDAR NOMBRE ÚNICO
    private func validateUserName(_ name: String) -> (isValid: Bool, message: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Verificar que no esté vacío
        guard !trimmedName.isEmpty else {
            return (false, "Por favor ingresa tu nombre")
        }
        
        // Verificar longitud mínima
        guard trimmedName.count >= 2 else {
            return (false, "El nombre debe tener al menos 2 caracteres")
        }
        
        // Verificar longitud máxima
        guard trimmedName.count <= 50 else {
            return (false, "El nombre no puede tener más de 50 caracteres")
        }
        
        // Verificar que no contenga solo números
        guard !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: trimmedName)) else {
            return (false, "El nombre no puede contener solo números")
        }
        
        // Verificar que no exista ya (case insensitive)
        let nameLower = trimmedName.lowercased()
        guard !existingUserNames.contains(nameLower) else {
            return (false, "Ya existe un usuario con este nombre")
        }
        
        return (true, "Nombre válido")
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
        guard let inputName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inputName.isEmpty else {
            showAlert("Por favor ingresa tu nombre")
            return
        }
        
        // ✅ VALIDAR NOMBRE ANTES DE CONTINUAR
        let validation = validateUserName(inputName)
        guard validation.isValid else {
            showAlert(validation.message)
            return
        }
        
        userName = inputName // ✅ USAR EL NOMBRE REAL DEL USUARIO
        
        print("📝 RegistrationViewController: Iniciando registro con nombre: '\(userName)'")
        
        if !isCapturing {
            startFaceRegistration()
        }
    }
    
    // ✅ VALIDACIÓN EN TIEMPO REAL
    @objc private func nameTextFieldChanged() {
        guard let inputName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            updateButtonState(false, message: "Ingresa tu nombre")
            return
        }
        
        let validation = validateUserName(inputName)
        updateButtonState(validation.isValid, message: validation.message)
    }

    // ✅ NUEVO MÉTODO: Actualizar estado del botón con feedback visual
    private func updateButtonState(_ isEnabled: Bool, message: String) {
        startButton.isEnabled = isEnabled
        
        UIView.animate(withDuration: 0.3) {
            if isEnabled {
                self.startButton.alpha = 1.0
                self.startButton.backgroundColor = UIColor.systemGreen
                self.statusLabel.text = "✅ \(message)"
                self.statusLabel.textColor = .white
            } else {
                self.startButton.alpha = 0.6
                self.startButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.6)
                
                // Mostrar mensaje de error si no está vacío
                if !message.isEmpty && message != "Ingresa tu nombre" {
                    self.statusLabel.text = "⚠️ \(message)"
                    self.statusLabel.textColor = UIColor.systemYellow
                } else {
                    self.statusLabel.text = "Ingresa tu nombre para continuar"
                    self.statusLabel.textColor = UIColor.white.withAlphaComponent(0.7)
                }
            }
        }
    }
    
    @objc private func cancelButtonTapped() {
        if isCapturing {
            facialAuth.cancel()
        }
        dismiss(animated: true)
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
            self.startButton.alpha = 0.6 // ✅ INICIALMENTE DESHABILITADO
            self.startButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 0.9, options: .curveEaseOut, animations: {
            self.cancelButton.alpha = 1
            self.statusLabel.alpha = 1
        })
        
        // ✅ ESTADO INICIAL DEL BOTÓN
        startButton.isEnabled = false
        statusLabel.text = "Ingresa tu nombre para continuar"
    }
    
    private func setupTextField() {
        nameTextField.delegate = self
        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no
        nameTextField.returnKeyType = .done
        nameTextField.clearButtonMode = .whileEditing
        
        // ✅ PLACEHOLDER MEJORADO
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Tu nombre completo",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        // ✅ PADDING INTERNO
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        nameTextField.rightViewMode = .always
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // ✅ SI EL NOMBRE ES VÁLIDO, ACTIVAR EL BOTÓN AUTOMÁTICAMENTE
        if startButton.isEnabled {
            startButtonTapped()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // ✅ PERMITIR SOLO LETRAS, ESPACIOS Y ALGUNOS CARACTERES ESPECIALES
        let allowedCharacters = CharacterSet.letters.union(CharacterSet.whitespaces).union(CharacterSet(charactersIn: "áéíóúüñÁÉÍÓÚÜÑ'-"))
        let characterSet = CharacterSet(charactersIn: string)
        
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // ✅ ANIMACIÓN SUTIL AL EMPEZAR A EDITAR
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // ✅ VOLVER AL TAMAÑO NORMAL
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.transform = .identity
        }
    }
}

// MARK: - FacialAuthDelegate
extension RegistrationViewController: FacialAuthDelegate {
    
    // ✅ Métodos de registro
    func registrationDidSucceed(userProfile: UserProfile) {
        print("🎉 RegistrationViewController: registrationDidSucceed EJECUTADO para \(userProfile.displayName)")
        
        updateStatus("¡Registro completado exitosamente! ✅")
        updateProgress(1.0) // ✅ ASEGURAR QUE LLEGUE A 100%
        animateSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("🚀 RegistrationViewController: Llamando a delegate?.registrationDidComplete")
            self.delegate?.registrationDidComplete(userName: self.userName)
        }
    }
    
    
    func registrationDidFail(error: AuthError) {
        print("❌ RegistrationViewController: registrationDidFail EJECUTADO - \(error)")
        updateStatus("Error: \(error.errorDescription ?? "Desconocido") ❌")
        resetUI()
    }
    
    func registrationProgress(_ progress: Float) {
        print("📊 RegistrationViewController: registrationProgress EJECUTADO - \(Int(progress * 100))%")
        
        updateProgress(progress)
        
        if progress < 0.5 {
            let samples = Int(progress * 20)
            updateStatus("📸 Capturando muestras... \(samples)/10")
        } else {
            let trainingPercent = Int((progress - 0.5) * 200)
            updateStatus("🏋️ Entrenando modelo... \(trainingPercent)%")
        }
    }
    
    func trainingDidStart(mode: TrainingMode) {
        updateStatus("Iniciando entrenamiento...")
    }
    
  
    func trainingProgress(_ progress: Float, epoch: Int, loss: Float, accuracy: Float) {
        // ✅ SEGUNDA MITAD DEL PROGRESO (50-100%)
        let totalProgress = 0.5 + (progress * 0.5)
        updateProgress(totalProgress)
        
        updateStatus("🏋️ Entrenando: Época \(epoch) - \(Int(accuracy * 100))% precisión")
        
        // ✅ CAMBIAR COLOR SEGÚN PROGRESO DE ENTRENAMIENTO
        if progress > 0.8 {
            cameraGuideView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            cameraGuideView.layer.borderColor = UIColor.systemPurple.cgColor
        }
    }
    
    func trainingDidComplete(metrics: TrainingMetrics) {
        updateStatus("Entrenamiento completado en \(String(format: "%.1f", metrics.totalTime))s")
    }
    
    func trainingSampleCaptured(sampleCount: Int, totalNeeded: Int) {
        print("📸 RegistrationViewController: trainingSampleCaptured EJECUTADO - \(sampleCount)/\(totalNeeded)")
        
        let progress = Float(sampleCount) / Float(totalNeeded) * 0.5
        updateProgress(progress)
        
        updateStatus("📸 Muestra \(sampleCount)/\(totalNeeded) capturada")
        
        // Cambiar color del guide
        if sampleCount == totalNeeded {
            cameraGuideView.layer.borderColor = UIColor.systemPurple.cgColor
            updateStatus("🎉 ¡Muestras capturadas! Entrenando...")
        } else if sampleCount > totalNeeded / 2 {
            cameraGuideView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            cameraGuideView.layer.borderColor = UIColor.systemOrange.cgColor
        }
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
