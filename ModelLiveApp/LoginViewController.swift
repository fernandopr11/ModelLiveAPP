import UIKit
import FacialAuthFramework

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    var facialAuth: FacialAuthManager!
    weak var delegate: LoginDelegate?
    
    private var isScanning = false
    private var registeredUsers: [(id: String, name: String)] = []
    
    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Iniciar Sesión"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Selecciona tu usuario y escanea tu rostro"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userSelectionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let noUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay usuarios registrados\nRegístrate primero"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.cornerRadius = 120
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Selecciona un usuario para continuar"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Escanear Rostro", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.isEnabled = false
        button.alpha = 0.6
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
    
    private var selectedUserID: String?
    private var selectedUserName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupTableView()
        addTargets()
        loadRegisteredUsers()
        animateInitialAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        
        // ✅ AJUSTAR PREVIEW LAYER SI EXISTE
        if isScanning, let previewLayer = facialAuth?.getCameraPreviewLayer() {
            previewLayer.frame = facePreviewContainer.bounds
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Background gradient
        backgroundGradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemIndigo.cgColor,
            UIColor.systemPurple.cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // Add UI elements
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(userSelectionContainer)
        view.addSubview(noUsersLabel)
        view.addSubview(facePreviewContainer)
        view.addSubview(cameraGuideView)
        view.addSubview(statusLabel)
        view.addSubview(scanButton)
        view.addSubview(cancelButton)
        
        // Add table view to container
        userSelectionContainer.addSubview(userTableView)
        
        setupConstraints()
    }
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTableView() {
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    // MARK: - Setup Constraints (MÉTODO CORREGIDO)
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
            
            // User Selection Container
            userSelectionContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userSelectionContainer.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            userSelectionContainer.widthAnchor.constraint(equalToConstant: 320),
            userSelectionContainer.heightAnchor.constraint(equalToConstant: 200),
            
            // User Table View
            userTableView.topAnchor.constraint(equalTo: userSelectionContainer.topAnchor),
            userTableView.leadingAnchor.constraint(equalTo: userSelectionContainer.leadingAnchor),
            userTableView.trailingAnchor.constraint(equalTo: userSelectionContainer.trailingAnchor),
            userTableView.bottomAnchor.constraint(equalTo: userSelectionContainer.bottomAnchor),
            
            // No Users Label
            noUsersLabel.centerXAnchor.constraint(equalTo: userSelectionContainer.centerXAnchor),
            noUsersLabel.centerYAnchor.constraint(equalTo: userSelectionContainer.centerYAnchor),
            
            // Face Preview Container
            facePreviewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facePreviewContainer.topAnchor.constraint(equalTo: userSelectionContainer.bottomAnchor, constant: 30),
            facePreviewContainer.widthAnchor.constraint(equalToConstant: 240),
            facePreviewContainer.heightAnchor.constraint(equalToConstant: 240),
            
            // Camera Guide
            cameraGuideView.centerXAnchor.constraint(equalTo: facePreviewContainer.centerXAnchor),
            cameraGuideView.centerYAnchor.constraint(equalTo: facePreviewContainer.centerYAnchor),
            cameraGuideView.widthAnchor.constraint(equalToConstant: 200),
            cameraGuideView.heightAnchor.constraint(equalToConstant: 200),
            
            // ✅ FIX: Status Label ahora va DEBAJO del facePreviewContainer
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: facePreviewContainer.bottomAnchor, constant: 30), // ✅ CAMBIO AQUÍ
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // ✅ FIX: Scan Button ahora va DEBAJO del statusLabel
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30), // ✅ CAMBIO AQUÍ
            scanButton.widthAnchor.constraint(equalToConstant: 280),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            
            // ✅ FIX: Cancel Button ahora va DEBAJO del scanButton
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20), // ✅ CAMBIO AQUÍ
            cancelButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // ✅ SEGURIDAD
        ])
    }
    
    private func addTargets() {
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadRegisteredUsers() {
        print("🔍 LoginViewController: Cargando usuarios registrados...")
        
        do {
            let userIds = try facialAuth.getAllRegisteredUsers()
            
            registeredUsers = userIds.compactMap { userId in
                do {
                    if let profile = try facialAuth.getUserProfileInfo(userId: userId) {
                        return (id: userId, name: profile.displayName)
                    }
                    return nil
                } catch {
                    print("❌ Error obteniendo perfil de \(userId): \(error)")
                    return nil
                }
            }
            
            print("✅ LoginViewController: \(registeredUsers.count) usuarios encontrados:")
            for user in registeredUsers {
                print("   - \(user.name) (\(user.id))")
            }
            
        } catch {
            print("❌ LoginViewController: Error cargando usuarios: \(error)")
            registeredUsers = []
        }
        
        updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if self.registeredUsers.isEmpty {
                self.userSelectionContainer.isHidden = true
                self.noUsersLabel.isHidden = false
                self.scanButton.isEnabled = false
                self.scanButton.alpha = 0.6
                self.statusLabel.text = "No hay usuarios registrados"
            } else {
                self.userSelectionContainer.isHidden = false
                self.noUsersLabel.isHidden = true
                self.userTableView.reloadData()
            }
        }
    }
    
    // MARK: - Button Actions
    @objc private func scanButtonTapped() {
        guard let userID = selectedUserID, let userName = selectedUserName else {
            showAlert("Por favor selecciona un usuario")
            return
        }
        
        if !isScanning {
            startFaceAuthentication(userID: userID, userName: userName)
        }
    }
    
    @objc private func cancelButtonTapped() {
        if isScanning {
            facialAuth.cancel()
        }
        dismiss(animated: true)
    }
    
    // MARK: - Authentication Flow
    private func startFaceAuthentication(userID: String, userName: String) {
        isScanning = true
        
        // Update UI for scanning mode
        scanButton.setTitle("Escaneando...", for: .normal)
        scanButton.isEnabled = false
        userTableView.isUserInteractionEnabled = false
        
        // Show camera preview
        showCameraPreview()
        
        // ✅ CONFIGURAR PREVIEW DE CÁMARA ANTES DE AUTENTICAR
        facialAuth.setupCameraPreview(in: self, previewView: facePreviewContainer)
        
        // Start facial authentication
        facialAuth.authenticateUser(userId: userID, in: self)
        
        print("📹 LoginViewController: Preview configurado y autenticación iniciada")
    }
    
    private func showCameraPreview() {
        UIView.animate(withDuration: 0.5) {
            self.facePreviewContainer.isHidden = false
            self.cameraGuideView.isHidden = false
            self.userSelectionContainer.alpha = 0.5
        }
        
        // ✅ ASEGURAR QUE EL PREVIEW LAYER SE AJUSTE AL FRAME
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let previewLayer = self.facialAuth.getCameraPreviewLayer() {
                previewLayer.frame = self.facePreviewContainer.bounds
                
                print("📺 LoginViewController: Preview layer ajustado")
                print("   - Frame actualizado: \(self.facePreviewContainer.bounds)")
            }
        }
    }
    
    private func resetUI() {
        isScanning = false
        scanButton.setTitle("Escanear Rostro", for: .normal)
        scanButton.isEnabled = selectedUserID != nil
        userTableView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.5) {
            self.facePreviewContainer.isHidden = true
            self.cameraGuideView.isHidden = true
            self.userSelectionContainer.alpha = 1.0
        }
    }
    
    // MARK: - UI Helper Methods
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.animateStatusUpdate()
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
    
    private func animateError() {
        UIView.animate(withDuration: 0.1, animations: {
            self.cameraGuideView.layer.borderColor = UIColor.systemRed.cgColor
            self.cameraGuideView.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.cameraGuideView.transform = CGAffineTransform(translationX: -10, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.cameraGuideView.transform = .identity
                    self.cameraGuideView.layer.borderColor = UIColor.systemBlue.cgColor
                })
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func animateInitialAppearance() {
        // Initial state
        titleLabel.alpha = 0
        instructionLabel.alpha = 0
        userSelectionContainer.alpha = 0
        scanButton.alpha = 0
        cancelButton.alpha = 0
        statusLabel.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        instructionLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        userSelectionContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        scanButton.transform = CGAffineTransform(translationX: 0, y: 40)
        
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
            self.userSelectionContainer.alpha = 1
            self.userSelectionContainer.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.scanButton.alpha = 0.6 // Initially disabled
            self.scanButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 0.9, options: .curveEaseOut, animations: {
            self.cancelButton.alpha = 1
            self.statusLabel.alpha = 1
        })
    }
}

// MARK: - TableView DataSource & Delegate
extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let user = registeredUsers[indexPath.row]
        cell.configure(with: user.name, isSelected: selectedUserID == user.id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = registeredUsers[indexPath.row]
        selectedUserID = user.id
        selectedUserName = user.name
        
        // Update UI
        scanButton.isEnabled = true
        scanButton.alpha = 1.0
        updateStatus("Usuario seleccionado: \(user.name)")
        
        // Reload table to update selection
        tableView.reloadData()
        
        // Animate selection
        UIView.animate(withDuration: 0.3) {
            self.scanButton.backgroundColor = UIColor.systemBlue
        }
    }
}

// MARK: - FacialAuthDelegate
extension LoginViewController: FacialAuthDelegate {
    
    // ✅ Métodos de autenticación
    func authenticationDidSucceed(userProfile: UserProfile) {
        updateStatus("¡Autenticación exitosa! ✅")
        animateSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.loginDidComplete(userName: self.selectedUserName ?? "Usuario")
        }
    }
    
    func authenticationDidFail(error: AuthError) {
        updateStatus("Error: \(error.errorDescription ?? "Autenticación fallida") ❌")
        animateError()
        resetUI()
    }
    
    func authenticationDidCancel() {
        updateStatus("Autenticación cancelada")
        resetUI()
    }
    
    func authenticationStateChanged(_ state: AuthState) {
        switch state {
        case .scanning:
            updateStatus("Posiciona tu rostro en el círculo")
        case .processing:
            updateStatus("Verificando identidad...")
        case .authenticating:
            updateStatus("Autenticando...")
        default:
            break
        }
    }
    
    // ✅ Métodos de registro (vacíos porque no aplican para login)
    func registrationDidSucceed(userProfile: UserProfile) {}
    func registrationDidFail(error: AuthError) {}
    func registrationProgress(_ progress: Float) {}
    
    // ✅ Métodos de entrenamiento (vacíos porque no aplican para login)
    func trainingDidStart(mode: TrainingMode) {}
    func trainingProgress(_ progress: Float, epoch: Int, loss: Float, accuracy: Float) {}
    func trainingDidComplete(metrics: TrainingMetrics) {}
    func trainingDidFail(error: AuthError) {}
    func trainingDidCancel() {}
    func trainingSampleCaptured(sampleCount: Int, totalNeeded: Int) {}
    func trainingDataValidated(isValid: Bool, quality: Float) {}
    
    // ✅ Métodos opcionales
    func cameraPermissionRequired() {
        updateStatus("Se requiere permiso de cámara")
    }
    
    func metricsUpdated(_ metrics: AuthMetrics) {
        // Métricas opcionales - no hacer nada
    }
}

// MARK: - Custom Table View Cell
class UserTableViewCell: UITableViewCell {
    
    private let userIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGreen
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(userIconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            userIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userIconImageView.widthAnchor.constraint(equalToConstant: 30),
            userIconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.leadingAnchor.constraint(equalTo: userIconImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with name: String, isSelected: Bool) {
        nameLabel.text = name
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            contentView.layer.cornerRadius = 8
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = highlighted ?
                UIColor.white.withAlphaComponent(0.1) :
                (self.checkmarkImageView.isHidden ? .clear : UIColor.white.withAlphaComponent(0.15))
        }
    }
}
