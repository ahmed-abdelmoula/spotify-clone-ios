//
//  LabelReusableVIew.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 28/6/2023.
//

import UIKit
struct LabelReusableViewModel {
    let label : String
    let buttonName : String
}
protocol LabelReusableViewDelegate: AnyObject {
    func actionLabelViewDidTapButton(_ actionView: LabelReusableView)
}

class LabelReusableView: UIView {
    weak var  delegate : LabelReusableViewDelegate?
  
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button: UIButton = {
       let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        addSubview(label)
        addSubview(button)
        button.addTarget(self, action: #selector(didTapIn), for: .touchUpInside)
    }
    @objc func didTapIn () {
        delegate?.actionLabelViewDidTapButton(self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-45)
        button.frame = CGRect(x: 0, y: label.bottom + 5 , width: width, height: 40)
    }
    
    func configure (with model : LabelReusableViewModel ) {
        label.text = model.label
        button.setTitle(model.buttonName, for: .normal)
        
    }

}
