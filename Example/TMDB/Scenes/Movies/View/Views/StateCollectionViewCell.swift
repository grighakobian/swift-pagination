//
//  StateCollectionViewCell.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import UIKit

final class StateCollectionViewCell: UICollectionViewCell {
    
    lazy var stackView = makeStackView()
    lazy var messageLabel = makeMessageLabel()
    lazy var retryButton = makeRetryButton()
    lazy var activityIndicator = makeActivityIndicator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func bind(state: LoadingState) {
        switch state {
        case .loading:
            messageLabel.isHidden = true
            retryButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .failed(let error):
            messageLabel.isHidden = false
            retryButton.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            messageLabel.text = error.localizedDescription
        }
    }
    
    private func commonInit() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)
        stackView.addArrangedSubview(activityIndicator)
        
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: -24.0).isActive = true
    }
}

// MARK: - View Factory

extension StateCollectionViewCell {
    
    private func makeStackView()-> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = 24.0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func makeActivityIndicator()->UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    
    private func makeMessageLabel()->InsetLabel {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        label.textInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return label
    }
    
    private func makeRetryButton()-> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 20)
        return button
    }
    
}
