//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

@objcMembers open class Node: SKShapeNode {
    
    public lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = "Lato-Regular"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.width = self.frame.width - 18
        label.separator = " "
        label.position = CGPoint(x: frame.midX, y: frame.midY - 15)
        addChild(label)
        return label
    }()
    
    public lazy var image: SKSpriteNode = {
        let image = SKSpriteNode()
        image.size = CGSize(width: 50, height: 50)
        image.position = CGPoint(x: frame.midX, y: frame.midY + 22)
        addChild(image)
        return image
    }()
    
    public var userInfo: Any?
    
    open var clone: Node {
        return Node(text: text, image: icon, color: strokeColor, path: path, userInfo: userInfo)
    }
    
    /**
     The text displayed by the node.
     */
    open var text: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    /**
     The icon displayed by the node.
     */
    open var icon: UIImage? {
        didSet {
            image.texture = icon.map({ SKTexture(image: $0) })
        }
    }
    
    /**
     The color of the node.
     
     Also blends the color with the image.
     */
    open var color: UIColor = .clear {
        didSet {
            self.lineWidth = NodeStrokeWidth
            self.glowWidth = 1
            self.strokeColor = color
        }
    }
    
    /**
     The selection state of the node.
     */
    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                selectedAnimation()
            } else {
                deselectedAnimation()
            }
        }
    }
    
    /**
     Creates a node with a custom path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - path: The path of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public init(text: String?, image: UIImage?, color: UIColor, path: CGPath?, marginScale: CGFloat = 1.01, userInfo: Any?) {
        super.init()
        self.path = path
        if let path = path {
            self.physicsBody = {
                var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
                let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
                body.allowsRotation = false
                body.friction = 0
                body.linearDamping = 3
                return body
            }()
        }
        self.fillColor = Colors.newNavigationBarBackground
        self.userInfo = userInfo
        configure(text: text, image: image, color: color)
    }
    
    /**
     Creates a node with a circular path.
     
     - Parameters:
        - text: The text of the node.
        - image: The image of the node.
        - color: The color of the node.
        - radius: The radius of the node.
        - marginScale: The margin scale of the node.
     
     - Returns: A new node.
     */
    public convenience init(text: String?, image: UIImage?, color: UIColor, radius: CGFloat, marginScale: CGFloat = 1.1, userInfo: Any? = nil) {
        let path = SKShapeNode(circleOfRadius: radius).path
        self.init(text: text, image: image, color: color, path: path, marginScale: marginScale, userInfo: userInfo)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(text: String?, image: UIImage?, color: UIColor) {
        self.text = text
        self.icon = image
        self.color = color
    }
    
    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }
    
    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        run(.scale(to: 4/3, duration: 0.2))
    }
    
    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        run(.scale(to: 1, duration: 0.2))
    }
    
    /**
     The animation to execute when the node is removed.
     
     - important: You must call the completion block.
     
     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.fadeOut(withDuration: 0.2), completion: completion)
    }
    
}
