//
//  PlaylistHeaderCollectionReusableView.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 22/6/2023.
//

import UIKit
import SDWebImage


//final mean no body can subclass it
final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    //create a weak reference
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?

    private let nameLabel :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold )
        return label
    }()
    
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular )
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ownerLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .light )
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let playlistImageView : UIImageView  = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(systemName: "photo")
        return image
    }()
    private let playButton :UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    
        //create a view with specified frame 
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        print(height)
        addSubview(playlistImageView)
        addSubview(ownerLabel)
        addSubview(descriptionLabel)
        addSubview(nameLabel)
        addSubview(playButton)
        playButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)

    }
    @objc private func didTapPlayAll() {
        // we want to controller to play all tracks so how to tell him , notify him from
        //this function , and to do this we will use delegate  to notify the controller the button was tapped
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)


    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    // we need it once we start adding subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        //height here is the height of the subview PLaylistHeader and not entire screen
        let imageSize : CGFloat = height/1.7
        playlistImageView.frame = CGRect(x: (width - imageSize)/2 , y: 20, width: imageSize, height: imageSize)
        
        nameLabel.frame = CGRect(x: 10, y: playlistImageView.bottom, width: width - 20, height: 44)
        descriptionLabel.frame = CGRect(
             x: 10,
             y: nameLabel.bottom ,
             width: width,
             height: 24)
         ownerLabel.frame = CGRect(
             x: 10,
             y: descriptionLabel.bottom ,
             width: width,
             height: 24)
        playButton.frame = CGRect(x: width - 90, y: height - 70, width: 50, height: 50)
    }
    func configure (with playlist : PlaylistCellViewModel) {
        nameLabel.text = playlist.name
        ownerLabel.text = playlist.creatorName
        descriptionLabel.text = playlist.description
        playlistImageView.sd_setImage(with: playlist.artworkURL, placeholderImage: UIImage(systemName: "photo"))
    }
}
