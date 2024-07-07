//
//  LibraryViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit

class LibraryViewController: UIViewController , LibraryToggleViewDelegate{
    func toggleViewDidTapPlaylists() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func toggleViewDidTapAlbum() {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
    }
    
    private let playlistVC = LibraryPlaylistViewController()
       private let albumsVC = LibraryAlbumsViewController()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true // we can paginate horitonal
        return scrollView
    }()
    private let toggleView = LibraryToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(toggleView)
        view.addSubview(scrollView)
        toggleView.delegate = self
        scrollView.delegate = self
        // !!!!!!!!!!                           here we defined the widht of scrobalbe view to equal twice the width , for the height we let it to be defined by the frame because it will not be defined by the frame later
        scrollView.contentSize.width =  view.width * 2 // width of scrollview
        // that contains both visiable and no visible , it define the scrollable area
        addChildren()
        updateBarButton()
    }
    private func updateBarButton() {
           switch toggleView.state {
           case .playlist:
               navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
           case .album:
               navigationItem.rightBarButtonItem = nil
           }
       }
    @objc private func didTapAdd () {
        playlistVC.showCreatePlaylistAlert()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect( // define the visiable view
            x: 0,
            y: view.safeAreaInsets.top + 55,
            width: view.width,
            height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top , width: 200, height: 55)

    }
    private func addChildren() {
         addChild(playlistVC)
         scrollView.addSubview(playlistVC.view)
         playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
         playlistVC.didMove(toParent: self)
         
         addChild(albumsVC)
         scrollView.addSubview(albumsVC.view)
         albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
         albumsVC.didMove(toParent: self)
         
     }
   

}

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x )
        if scrollView.contentOffset.x >= ( view.width - 100) {
            toggleView.update(for: .album)
        } else {
            toggleView.update(for: .playlist)
        }
    }
}
