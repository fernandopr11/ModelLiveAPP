import UIKit
import FacialAuthFramework

class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FaceAuth"
        label.font = UIFont.systemFont(ofSize: 42, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Autenticación Facial Avanzada"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let faceIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.alpha = 0.6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Usar SF Symbol para el ícono de cara
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .thin)
        imageView.image = UIImage(systemName: "face.dashed", withConfiguration: config)
        
        return imageView
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Registrar Nuevo Usuario", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar Sesión", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Listo para comenzar"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let floatingParticlesView = FloatingParticlesView()
    
    // MARK: - FacialAuth Properties
    private var facialAuth: FacialAuthManager!
    private var currentUserID: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFacialAuth()
        addButtonTargets()
        animateInitialAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemIndigo
        
        // Configurar gradiente de fondo
        setupBackgroundGradient()
        
        // Agregar partículas flotantes
        setupFloatingParticles()
        
        // Agregar elementos UI
        setupUIElements()
        
        // Layout constraints
        setupConstraints()
    }
    
    private func setupBackgroundGradient() {
        backgroundGradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor,
            UIColor.systemBlue.cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupFloatingParticles() {
        floatingParticlesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingParticlesView)
        
        NSLayoutConstraint.activate([
            floatingParticlesView.topAnchor.constraint(equalTo: view.topAnchor),
            floatingParticlesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            floatingParticlesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            floatingParticlesView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupUIElements() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(faceIconImageView)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        view.addSubview(statusLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            // Subtitle
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            // Face Icon
            faceIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            faceIconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            faceIconImageView.widthAnchor.constraint(equalToConstant: 120),
            faceIconImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Register Button
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: faceIconImageView.bottomAnchor, constant: 60),
            registerButton.widthAnchor.constraint(equalToConstant: 280),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Login Button
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 280),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Status Label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupFacialAuth() {
       
        let config = AuthConfiguration(
            debugMode: true,
            logMetrics: true,
            trainingMode: .standard,
            enableLiveTraining: true,
            maxTrainingSamples: 10
        )
        
        facialAuth = FacialAuthManager(configuration: config)
        facialAuth.delegate = self
        
        updateStatus("Inicializando sistema...")
        facialAuth.initialize()
    }
    
    private func addButtonTargets() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func updateGradientFrame() {
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Button Actions
    @objc private func registerButtonTapped() {
        animateButtonPress(registerButton)
        presentRegistrationFlow()
    }
    
    @objc private func loginButtonTapped() {
        animateButtonPress(loginButton)
        presentLoginFlow()
    }
    
    // MARK: - Navigation Methods
    private func presentRegistrationFlow() {
        let registrationVC = RegistrationViewController()
        registrationVC.facialAuth = facialAuth
        registrationVC.delegate = self
        
        let navController = UINavigationController(rootViewController: registrationVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func presentLoginFlow() {
        let loginVC = LoginViewController()
        loginVC.facialAuth = facialAuth
        loginVC.delegate = self
        
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func presentWelcomeScreen(userName: String) {
        let welcomeVC = WelcomeViewController()
        welcomeVC.userName = userName
        welcomeVC.modalPresentationStyle = .fullScreen
        present(welcomeVC, animated: true)
    }
    
    // MARK: - UI Helper Methods
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
            self.animateStatusUpdate()
        }
    }
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform.identity
            }
        }
    }
    
    private func animateStatusUpdate() {
        UIView.animate(withDuration: 0.3, animations: {
            self.statusLabel.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.statusLabel.alpha = 1.0
            }
        }
    }
    
    private func animateInitialAppearance() {
        // Animar elementos uno por uno
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        faceIconImageView.alpha = 0
        registerButton.alpha = 0
        loginButton.alpha = 0
        statusLabel.alpha = 0
        
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -50)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        faceIconImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        registerButton.transform = CGAffineTransform(translationX: 0, y: 50)
        loginButton.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 1.0, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            self.faceIconImageView.alpha = 0.6
            self.faceIconImageView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.8, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.registerButton.alpha = 1
            self.registerButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.loginButton.alpha = 1
            self.loginButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 1.2, options: .curveEaseOut, animations: {
            self.statusLabel.alpha = 1
        })
    }
}

// MARK: - FacialAuthDelegate
extension MainViewController: FacialAuthDelegate {
    
    // Métodos obligatorios que faltan:
    func authenticationDidSucceed(userProfile: UserProfile) {
        // No aplica para main view
    }
    
    func authenticationDidFail(error: AuthError) {
        // No aplica para main view
    }
    
    func authenticationDidCancel() {
        // No aplica para main view
    }
    
    func registrationDidSucceed(userProfile: UserProfile) {
        // No aplica para main view
    }
    
    func registrationDidFail(error: AuthError) {
        // No aplica para main view
    }
    
    func registrationProgress(_ progress: Float) {
        // No aplica para main view
    }
    
    // El método que ya tienes:
    func authenticationStateChanged(_ state: AuthState) {
        switch state {
        case .idle:
            updateStatus("Listo para comenzar")
        case .initializing:
            updateStatus("Inicializando sistema...")
        case .cameraReady:
            updateStatus("Sistema listo ✨")
        case .scanning:
            updateStatus("Escaneando rostro...")
        case .processing:
            updateStatus("Procesando...")
        case .success:
            updateStatus("¡Éxito! ✅")
        case .failed:
            updateStatus("Error ❌")
        case .cancelled:
            updateStatus("Operación cancelada")
        default:
            break
        }
    }
}

// MARK: - Registration/Login Delegates
extension MainViewController: RegistrationDelegate, LoginDelegate {
    
    func registrationDidComplete(userName: String) {
        dismiss(animated: true) {
            self.presentWelcomeScreen(userName: userName)
        }
    }
    
    func loginDidComplete(userName: String) {
        dismiss(animated: true) {
            self.presentWelcomeScreen(userName: userName)
        }
    }
}

// MARK: - Protocols
protocol RegistrationDelegate: AnyObject {
    func registrationDidComplete(userName: String)
}

protocol LoginDelegate: AnyObject {
    func loginDidComplete(userName: String)
}
