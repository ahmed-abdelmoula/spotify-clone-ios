//
//  CategoryCollectionViewCell.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 23/6/2023.
//

import UIKit
import SDWebImage
class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        return label
    }()

    let imageView  : UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.contentMode = .scaleToFill
//        imageView.contentMode = .center to work
//        let config = UIImage.SymbolConfiguration(pointSize: 50 , weight: .regular)
//        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: config)
        return imageView

    }()
    
    private let colors: [UIColor] = [
        .systemPink, .systemPurple, .systemRed, .systemGreen, .systemBlue, .systemTeal,
        .systemBrown, .systemGray , .systemYellow, .systemOrange,
        .darkGray
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        contentView.backgroundColor = colors.randomElement()

    }
    required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds

        label.frame = CGRect(
            x: 10,
            y:  contentView.height / 2,
            width: contentView.width,
            height: contentView.height / 2 + 20 ) // the label always stop at the middle of the higth
        // if Height is 50 the label will be at 25 and if you want the increase label to be at 30 or 40 to you to add or simply div 1.5
//        imageView.frame = CGRect(x: contentView.width / 2 ,
//                                 y: 0,
//                                 width: contentView.width / 2,
//                                 height: contentView.height / 2 )
                
        
                imageView.addSubview(label)


    }

    
    func update(with category : Category) {
        label.text = category.name
        imageView.sd_setImage(with: URL(string: category.icons.first?.url ?? "" ) , completed: nil )
        
    }
}
