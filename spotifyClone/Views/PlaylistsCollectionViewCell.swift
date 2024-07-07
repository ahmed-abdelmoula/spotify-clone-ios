//
//  FeaturedPlaylistsCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Alpsu Dilbilir on 15.08.2022.
//

import UIKit
import SDWebImage
class PlaylistsCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistsCollectionViewCell"
    
    private var playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.backgroundColor = .red
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        playlistCoverImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        playlistCoverImageView.sizeToFit()
        playlistCoverImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.width,
            height: contentView.height)
//             label.frame = CGRect(
//                 x: 10,
//                 y: playlistCoverImageView.bottom + 20,
//                 width: contentView.width - 10,
//                 height: contentView.height - (contentView.height/1.5 + 50) )
    }
    
    func configure(with viewModel: PlaylistCellViewModel){
//        label.text = viewModel.name
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL)
    }
}
