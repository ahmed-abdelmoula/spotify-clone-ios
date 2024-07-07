//
//  LibraryToggleView.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 27/6/2023.
//

import UIKit
protocol LibraryToggleViewDelegate :AnyObject {
    func toggleViewDidTapPlaylists()
    func toggleViewDidTapAlbum()
}
enum State {
    case album
    case playlist
    
}

// this is just a container that contains two buttons  and then set the container
class LibraryToggleView: UIView {
    weak var delegate: LibraryToggleViewDelegate? // if we declared as let it will make an error

    var state : State = .playlist
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        return view
    }()
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Playlists", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(albumsButton)
        addSubview(playlistButton)
        addSubview(indicatorView)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 40)
        albumsButton.frame = CGRect(
            x: playlistButton.right,
            y: 0,
            width: 100,
            height: 40)
 
        layoutIndicator()

    }
    func layoutIndicator() {
         switch state {
         case .playlist:
             indicatorView.frame = CGRect(
                 x: 5,
                 y: playlistButton.bottom,
                 width: 100,
                 height: 4)
         case .album:
             indicatorView.frame = CGRect(
                 x: playlistButton.right + 5,
                 y: albumsButton.bottom,
                 width: 100,
                 height: 4)
         }
     }
    
    @objc private func didTapPlaylist() {
        state = .playlist
        UIView.animate(withDuration: 0.2) {
                   self.layoutIndicator()
               }
        delegate?.toggleViewDidTapPlaylists()
        
    }
    @objc private func didTapAlbums() {
        state = .album
        UIView.animate(withDuration: 0.2) {
                   self.layoutIndicator()
               }
        delegate?.toggleViewDidTapAlbum()

    }
    
    func update(for state: State) {
           self.state = state
           UIView.animate(withDuration: 0.2) {
               self.layoutIndicator()
           }
       }
}
