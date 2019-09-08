//
//  Magnetic.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

@objc public protocol MagneticDelegate: class {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node)
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node)
}

let NodeStrokeWidth: CGFloat = 2

@objcMembers open class Magnetic: SKScene {
    
    /**
     The field node that accelerates the nodes.
     */
    open lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        self.addChild(field)
        return field
    }()
    
    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true
    
    open var isDragging: Bool = false
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.compactMap { $0 as? Node }.filter { $0.isSelected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?
    
    override open var size: CGSize {
        didSet {
            configure()
        }
    }
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .clear
        scaleMode = .aspectFill
        configure()
    }
    
    func configure() {
        let strength = Float(max(size.width, size.height))
        let radius = strength.squareRoot() * 400
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(radius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        
        magneticField.region = SKRegion(radius: radius)
        magneticField.minimumRadius = radius
        magneticField.strength = strength * 30
        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    open func addNode(_ node: SKNode) {
        super.addChild(node)
        let speed = physicsWorld.speed
        physicsWorld.speed = 0
        let action = SKAction.run {
            let movingYAction = SKAction.moveTo(y: self.size.height - node.frame.height / 2, duration: 0.4)
            let showAction = SKAction.group([movingYAction])
            node.run(showAction)
        }
        let wait = SKAction.wait(forDuration: 0.4)
        let sequence = SKAction.sequence([action, wait])
        run(sequence) {
            self.physicsWorld.speed = speed
        }
    }
    
    open func removeChild(node: SKNode, completion: (() -> Void)? = nil) {
        let speed = physicsWorld.speed
        physicsWorld.speed = 0
        
        node.physicsBody = nil
        let action = SKAction.run {
            let point = CGPoint(x: node.frame.width / 2, y: self.size.height)
            let movingXAction = SKAction.moveTo(x: point.x, duration: 0.2)
            let movingYAction = SKAction.moveTo(y: point.y, duration: 0.4)
            let resize = SKAction.scale(to: 0.3, duration: 0.4)
            let throwAction = SKAction.group([movingXAction, movingYAction, resize])
            node.run(throwAction) { [unowned node] in
                node.removeFromParent()
            }
        }
        run(action) {
            self.physicsWorld.speed = speed
            completion?()
        }
    }
    
    open func removeAllChilds(isFast: Bool = false, completion: (() -> Void)? = nil) {
        let speed = physicsWorld.speed
        physicsWorld.speed = 0
        let sortedNodes = children.compactMap { $0 as? Node }.sorted { node, nextNode in
            let distance = node.position.distance(from: magneticField.position)
            let nextDistance = nextNode.position.distance(from: magneticField.position)
            return distance < nextDistance && node.isSelected
        }
        var actions = [SKAction]()
        for (index, node) in sortedNodes.enumerated() {
            node.physicsBody = nil
            let action = SKAction.run { [unowned node] in
                let point = CGPoint(x: self.size.width / 2, y: self.size.height + 40)
                let movingXAction = SKAction.moveTo(x: point.x, duration: isFast ? 0.1 : 0.2)
                let movingYAction = SKAction.moveTo(y: point.y, duration: isFast ? 0.2 : 0.4)
                let resize = SKAction.scale(to: 0.3, duration: 0.4)
                let throwAction = SKAction.group([movingXAction, movingYAction, resize])
                node.run(throwAction) { [unowned node] in
                    node.removeFromParent()
                }
            }
            actions.append(action)
            let delay = SKAction.wait(forDuration: TimeInterval(index) * 0.002)
            actions.append(delay)
        }
        run(.sequence(actions)) {
            self.physicsWorld.speed = speed
            completion?()
        }
    }
    
}

extension Magnetic {
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previous = touch.previousLocation(in: self)
        guard location.distance(from: previous) != 0 else { return }
        
        isDragging = true
        
        moveNodes(location: location, previous: previous)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        defer { isDragging = false }
        guard !isDragging, let node = node(at: location) else { return }
        
        if node.isSelected {
            node.isSelected = false
            magneticDelegate?.magnetic(self, didDeselect: node)
        } else {
            if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                selectedNode.isSelected = false
                magneticDelegate?.magnetic(self, didDeselect: selectedNode)
            }
            node.isSelected = true
            magneticDelegate?.magnetic(self, didSelect: node)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
}

extension Magnetic {
    open func moveNodes(location: CGPoint, previous: CGPoint) {
        let x = location.x - previous.x
        let y = location.y - previous.y
        
        for node in children {
            let distance = node.position.distance(from: location)
            let acceleration: CGFloat = 8 * pow(distance, 1/2)
            let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
            node.physicsBody?.applyForce(direction)
        }
    }
    
    open func node(at point: CGPoint) -> Node? {
        return nodes(at: point).compactMap { $0 as? Node }.filter { $0.path!.contains(convert(point, to: $0)) }.first
    }
}

extension CGFloat {
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
