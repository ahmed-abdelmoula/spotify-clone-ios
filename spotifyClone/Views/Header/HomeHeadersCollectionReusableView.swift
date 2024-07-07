//
//  AlbumCollectionReusableView.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 22/6/2023.
//

import UIKit

class HomeHeadersCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "HomeHeadersCollectionReusableView"
      
      private let headerLabel: UILabel = {
          let label = UILabel()
          label.font = .systemFont(ofSize: 22, weight: .bold)
          label.textColor = .label
          label.numberOfLines = 1
          return label
      }()
      override init(frame: CGRect) {
          super.init(frame: frame)
          addSubview(headerLabel)
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
      override func layoutSubviews() {
          super.layoutSubviews()
          print(height)
          headerLabel.frame = CGRect(
              x: 5,
              y: 2,
              width: width,
              height: height)
      }
      func configure(with title: String) {
          headerLabel.text = title
      }
}
