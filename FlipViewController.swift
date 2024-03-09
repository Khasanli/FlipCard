//
//  FlipViewController.swift
//  FlipYCard
//
//  Created by Khayala Hasanli on 09.03.24.
//

import UIKit

class FlipViewController: UIViewController {

    let flipView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let frontSideView : UIView = {
        let view = UIView()
        view.backgroundColor = .frontColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backSideView : UIView = {
        let view = UIView()
        view.backgroundColor = .backColor
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setGradientColor()
        setupFlipView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.presentBottomSheetAction()
        })
    }
 
    func setGradientColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.darkBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.zPosition = -170
    }
   
    func setupFlipView() {
        view.addSubview(flipView)
        flipView.addSubview(frontSideView)
        flipView.addSubview(backSideView)
        
        NSLayoutConstraint.activate([
            flipView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            flipView.widthAnchor.constraint(equalToConstant: 283),
            flipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flipView.heightAnchor.constraint(equalToConstant: 170),
            
            frontSideView.widthAnchor.constraint(equalTo: flipView.widthAnchor),
            frontSideView.heightAnchor.constraint(equalTo: flipView.heightAnchor),
            frontSideView.centerXAnchor.constraint(equalTo: flipView.centerXAnchor),
            frontSideView.centerYAnchor.constraint(equalTo: flipView.centerYAnchor),
            
            backSideView.widthAnchor.constraint(equalTo: flipView.widthAnchor),
            backSideView.heightAnchor.constraint(equalTo: flipView.heightAnchor),
            backSideView.centerXAnchor.constraint(equalTo: flipView.centerXAnchor),
            backSideView.centerYAnchor.constraint(equalTo: flipView.centerYAnchor)
        ])
        
        flipView.layer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
        frontSideView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    @objc func presentBottomSheetAction() {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        bottomSheetVC.modalTransitionStyle = .coverVertical
        bottomSheetVC.delegate = self
        self.present(bottomSheetVC, animated: true, completion: nil)
    }

}

class BottomSheetViewController: UIViewController {
    
    weak var delegate: BottomSheetDelegate?

    private let maxHeight: CGFloat = 500
    private let minHeight: CGFloat = 250
    private var originalPosition: CGPoint!
    private var currentPositionTouched: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 20
        self.view.backgroundColor = .white
        
        let line = UIView()
        line.backgroundColor = .darkGray
        line.layer.cornerRadius = 2
        line.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(line)
        line.widthAnchor.constraint(equalToConstant: 100).isActive = true
        line.heightAnchor.constraint(equalToConstant: 4).isActive = true
        line.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        line.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true

        setupPanGesture()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGesture(gesture:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame.origin.y = UIScreen.main.bounds.size.height - self.maxHeight
    }
    
    @objc func handleDismissPanGesture(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: view)
        
        if gesture.state == .changed {
            let newPosY = view.frame.origin.y + translation.y
            
            if newPosY <= UIScreen.main.bounds.size.height - maxHeight {
                view.frame.origin.y = UIScreen.main.bounds.size.height - maxHeight
            } else if newPosY >= UIScreen.main.bounds.size.height - minHeight {
                view.frame.origin.y = UIScreen.main.bounds.size.height - minHeight
            } else {
                view.frame.origin.y = newPosY
            }
        
            let percentage = (UIScreen.main.bounds.height - view.frame.origin.y - minHeight) / (maxHeight - minHeight)
            delegate?.didPanBottomSheet(percentage: percentage, duration: 0.1)
            gesture.setTranslation(.zero, in: view)
            
        } else if gesture.state == .ended {
            
            UIView.animate(withDuration: 0.3) {
                if self.view.frame.origin.y < UIScreen.main.bounds.size.height - self.maxHeight / 1.5 {
                    self.view.frame.origin.y = UIScreen.main.bounds.size.height - self.maxHeight
                } else {
                    self.view.frame.origin.y = UIScreen.main.bounds.size.height - self.minHeight
                }
            }
            
            let percentage = (UIScreen.main.bounds.height - view.frame.origin.y - minHeight) / (maxHeight - minHeight)
            delegate?.didPanBottomSheet(percentage: percentage, duration: 0.5)
        }
    }
}

protocol BottomSheetDelegate: AnyObject {
    func didPanBottomSheet(percentage: CGFloat, duration: CGFloat)
}

extension FlipViewController: BottomSheetDelegate {
    func didPanBottomSheet(percentage: CGFloat, duration: CGFloat) {
        
        let angle = percentage * .pi
        let alphaFront = percentage
        let alphaBack = 1.0 - percentage
        self.backSideView.isHidden = percentage > 0.5
        self.frontSideView.isHidden = percentage < 0.5

        UIView.animate(withDuration: duration) {
            self.flipView.layer.transform = CATransform3DMakeRotation(angle, 1, 0, 0)
            self.frontSideView.alpha = alphaFront
            self.backSideView.alpha = alphaBack
        }
    }
}

extension UIColor {
    static let darkBlue = UIColor(red: 0.102, green: 0.173, blue: 0.200, alpha: 1)
    static let frontColor = UIColor(red: 0.451, green: 0.507, blue: 0.725, alpha: 1)
    static let backColor = UIColor(red: 0.725, green: 0.511, blue: 0.468, alpha: 1)
}
