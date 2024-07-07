//
//  AlbumSearchCellViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 26/6/2023.
//

import UIKit
import SDWebImage

struct SearchResultCellViewModel {
    let title  : String
    let imageURL : String?
    let description : String?
}

class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"

    var iconView : UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .thin)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconView)
        contentView.addSubview(label)
        contentView.addSubview(descriptionLabel)
        contentView.clipsToBounds = true // to make nothing overflow
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height - 10 
        iconView.frame = CGRect(x: 0, y: 0, width: imageSize , height: imageSize )
        iconView.layer.cornerRadius = imageSize / 2
        iconView.layer.masksToBounds = true
        label.frame = CGRect(x: iconView.right + 10 ,
                             y: 0,
                             width: contentView.width - iconView.width - 10,
                             height: contentView.height/2)
        descriptionLabel.frame = CGRect(x: iconView.right + 10 ,
                             y: label.bottom ,
                             width: contentView.width - iconView.width - 10,
                             height: contentView.height/2)
 

    }
    // this important so at every search query initialize every things to nil or we will
    // see in the place same old value before we start a new search 
    override func prepareForReuse() {
         super.prepareForReuse()
         iconView.image = nil
         label.text = nil
        descriptionLabel.text = nil
     }
  
    func configure(with model : SearchResultCellViewModel) {
        label.text = model.title
        descriptionLabel.text = model.description
        iconView.sd_setImage(with: URL(string: model.imageURL ?? "") ,placeholderImage: UIImage(systemName: "photo"))
            
    }

}
