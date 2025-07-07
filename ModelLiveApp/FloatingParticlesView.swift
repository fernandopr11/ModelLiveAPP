import UIKit

class FloatingParticlesView: UIView {
    
    private var particles: [CAShapeLayer] = []
    private var displayLink: CADisplayLink?
    private let particleCount = 15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupParticles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupParticles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        repositionParticles()
    }
    
    private func setupParticles() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // Crear partículas
        for _ in 0..<particleCount {
            let particle = createParticle()
            layer.addSublayer(particle)
            particles.append(particle)
        }
        
        // Iniciar animación
        startAnimation()
    }
    
    private func createParticle() -> CAShapeLayer {
        let particle = CAShapeLayer()
        let size = CGFloat.random(in: 3...8)
        
        // Crear círculo
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size))
        particle.path = path.cgPath
        
        // Color aleatorio en tonos azules/púrpuras
        let colors: [UIColor] = [
            .systemBlue.withAlphaComponent(0.3),
            .systemPurple.withAlphaComponent(0.3),
            .systemIndigo.withAlphaComponent(0.3),
            .white.withAlphaComponent(0.2)
        ]
        particle.fillColor = colors.randomElement()?.cgColor
        
        // Posición inicial aleatoria
        particle.position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )
        
        // Propiedades de animación personalizadas
        particle.setValue(CGFloat.random(in: 0.5...2.0), forKey: "speed")
        particle.setValue(CGFloat.random(in: -1...1), forKey: "directionX")
        particle.setValue(CGFloat.random(in: -1...1), forKey: "directionY")
        
        return particle
    }
    
    private func repositionParticles() {
        for particle in particles {
            // Reposicionar dentro de los nuevos bounds
            let currentPosition = particle.position
            if currentPosition.x > bounds.width || currentPosition.y > bounds.height {
                particle.position = CGPoint(
                    x: CGFloat.random(in: 0...bounds.width),
                    y: CGFloat.random(in: 0...bounds.height)
                )
            }
        }
    }
    
    private func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateParticles))
        displayLink?.add(to: .current, forMode: .common)
        displayLink?.preferredFramesPerSecond = 60
    }
    
    @objc private func updateParticles() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        for particle in particles {
            let speed = particle.value(forKey: "speed") as? CGFloat ?? 1.0
            let directionX = particle.value(forKey: "directionX") as? CGFloat ?? 1.0
            let directionY = particle.value(forKey: "directionY") as? CGFloat ?? 1.0
            
            var newPosition = particle.position
            newPosition.x += directionX * speed * 0.5
            newPosition.y += directionY * speed * 0.3
            
            // Wrap around edges
            if newPosition.x > bounds.width + 10 {
                newPosition.x = -10
            } else if newPosition.x < -10 {
                newPosition.x = bounds.width + 10
            }
            
            if newPosition.y > bounds.height + 10 {
                newPosition.y = -10
            } else if newPosition.y < -10 {
                newPosition.y = bounds.height + 10
            }
            
            particle.position = newPosition
            
            // Subtle opacity animation
            let time = CACurrentMediaTime()
            let opacity = 0.1 + 0.3 * sin(time * Double(speed) + Double(particle.position.x * 0.01))
            particle.opacity = Float(opacity)
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
