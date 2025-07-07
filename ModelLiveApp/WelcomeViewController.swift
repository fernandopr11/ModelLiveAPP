import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    var userName: String = ""
    
    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    private let particlesView = FloatingParticlesView()
    
    private let successIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        imageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "¡Bienvenido!"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Autenticación facial completada exitosamente"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let securityIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: "shield.checkered", withConfiguration: config)
        
        return imageView
    }()
    
    private let securityLabel: UILabel = {
        let label = UILabel()
        label.text = "Autenticación Segura"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let encryptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Datos encriptados con AES-256"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continuar a la App", for: .normal)
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
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cerrar Sesión", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addTargets()
        configureContent()
        animateEntrance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
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
        
        // Add floating particles
        setupFloatingParticles()
        
        // Add UI elements
        view.addSubview(successIconImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(nameLabel)
        view.addSubview(messageLabel)
        view.addSubview(timeLabel)
        view.addSubview(statsContainer)
        view.addSubview(continueButton)
        view.addSubview(logoutButton)
        
        // Add stats content
        statsContainer.addSubview(securityIconImageView)
        statsContainer.addSubview(securityLabel)
        statsContainer.addSubview(encryptionLabel)
        
        setupConstraints()
    }
    
    private func setupFloatingParticles() {
        particlesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(particlesView)
        
        NSLayoutConstraint.activate([
            particlesView.topAnchor.constraint(equalTo: view.topAnchor),
            particlesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            particlesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            particlesView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Success Icon
            successIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            successIconImageView.widthAnchor.constraint(equalToConstant: 120),
            successIconImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Welcome Label
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: successIconImageView.bottomAnchor, constant: 30),
            
            // Name Label
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Message Label
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Time Label
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            
            // Stats Container
            statsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsContainer.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),
            statsContainer.widthAnchor.constraint(equalToConstant: 300),
            statsContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Security Icon
            securityIconImageView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 20),
            securityIconImageView.centerYAnchor.constraint(equalTo: statsContainer.centerYAnchor),
            securityIconImageView.widthAnchor.constraint(equalToConstant: 30),
            securityIconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            // Security Label
            securityLabel.leadingAnchor.constraint(equalTo: securityIconImageView.trailingAnchor, constant: 12),
            securityLabel.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 20),
            securityLabel.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -20),
            
            // Encryption Label
            encryptionLabel.leadingAnchor.constraint(equalTo: securityIconImageView.trailingAnchor, constant: 12),
            encryptionLabel.topAnchor.constraint(equalTo: securityLabel.bottomAnchor, constant: 4),
            encryptionLabel.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -20),
            
            // Continue Button
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),
            continueButton.widthAnchor.constraint(equalToConstant: 280),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Logout Button
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func addTargets() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    private func configureContent() {
        nameLabel.text = userName
        
        // Set current time
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy - HH:mm"
        formatter.locale = Locale(identifier: "es_ES")
        timeLabel.text = formatter.string(from: Date())
    }
    
    // MARK: - Button Actions
    @objc private func continueButtonTapped() {
        animateButtonPress(continueButton)
        
        // Simulate navigation to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showMainAppSimulation()
        }
    }
    
    @objc private func logoutButtonTapped() {
        animateButtonPress(logoutButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Animation Methods
    private func animateEntrance() {
        // Initial state
        successIconImageView.alpha = 0
        welcomeLabel.alpha = 0
        nameLabel.alpha = 0
        messageLabel.alpha = 0
        timeLabel.alpha = 0
        statsContainer.alpha = 0
        continueButton.alpha = 0
        logoutButton.alpha = 0
        
        successIconImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        welcomeLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        nameLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        messageLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        statsContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        continueButton.transform = CGAffineTransform(translationX: 0, y: 40)
        
        // Animate entrance sequence
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            self.successIconImageView.alpha = 1
            self.successIconImageView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.welcomeLabel.alpha = 1
            self.welcomeLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.nameLabel.alpha = 1
            self.nameLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.9, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.messageLabel.alpha = 1
            self.messageLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 1.1, options: .curveEaseOut, animations: {
            self.timeLabel.alpha = 1
        })
        
        UIView.animate(withDuration: 0.6, delay: 1.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            self.statsContainer.alpha = 1
            self.statsContainer.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 1.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.continueButton.alpha = 1
            self.continueButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 1.7, options: .curveEaseOut, animations: {
            self.logoutButton.alpha = 1
        })
        
        // Success icon pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startSuccessPulseAnimation()
        }
    }
    
    private func startSuccessPulseAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.successIconImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
    }
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
    
    private func showMainAppSimulation() {
        let alert = UIAlertController(
            title: "¡Éxito!",
            message: "En una app real, aquí navegarías a la pantalla principal de tu aplicación.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Entendido", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Status Bar
extension WelcomeViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
