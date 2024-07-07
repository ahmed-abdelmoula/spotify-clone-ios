//
//  PlaylistViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit
protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    // which take paremeter wbich is the view that make this delegate call
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}
class DetailedPlayListViewController : UIViewController {
    private var tracks = [AudioTrack]()
    var playlist : Playlist
    public var isOwner = false 
    
    private var collectionView: UICollectionView = UICollectionView(
         frame: .zero,
         collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ -> NSCollectionLayoutSection? in
             let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1),
                 heightDimension: .fractionalHeight(1)))
             item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
             let verticalGroup = NSCollectionLayoutGroup.vertical(
                 layoutSize: NSCollectionLayoutSize(
                     widthDimension: .fractionalWidth(1.0),
                     heightDimension: .absolute(100)),
                 subitem: item,
                 count: 1) // 1 item par row how 
             //Section
             let section = NSCollectionLayoutSection(group: verticalGroup)
             //specify a layout for the header of section
             section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(layoutSize:
                                                                NSCollectionLayoutSize(
                                                                    widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)), // size of header
                                                            elementKind: UICollectionView.elementKindSectionHeader ,
                                                            alignment: .top) //top of section
             ]
             return section
         }))
    
    
    
    init(playlist : Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModels = [RecommendedTrackCellViewModel]()


      
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Playlist"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                   barButtonSystemItem: .action,
                   target: self,
                   action: #selector(didTapShare))
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(TrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        // Registers a class for use in creating supplementary views for the collection view.
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PlaylistHeaderCollectionReusableView")
        
        fetchPlaylist()
            
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    @objc private func didLongPress(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return
        }
        let trackToDelete = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: trackToDelete.name, message: "Do you want to remove this track from playlist?", preferredStyle: .actionSheet)
        present(actionSheet, animated: true)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {[weak self] _ in
            guard let self = self else { return }
            APICaller.shared.removeTrackFromPlaylist(track: trackToDelete, playlist: self.playlist) { success in
                DispatchQueue.main.async {
                    if success {
                        self.tracks.remove(at: indexPath.row)
                        self.viewModels.remove(at: indexPath.row)
                        self.collectionView.reloadData()
                    } else {
                        print("Failed to remove")
                    }
                }
            }
        }))
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: [])
        /*
         in fact, if you just try and show one on an iPad like this, your app crashes:
         The solution is to use a UIPopoverPresentationController, which gets created for you when you try to access the popoverPresentationController property of a UIAlertController. With this, you can tell it where to show from (and what view those coordinates relate to) before presenting the action sheet, which makes it work correctly on iPad.
         let popover = vc.popoverPresentationController
         lezim tspecifi fi chkoun popover m3al9a bich appeari when we click
         popover?.barButtonItem = navigationItem.rightBarButtonItem
         */
           present(vc, animated: true)
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          collectionView.frame = view.bounds
      }
    
    func fetchPlaylist() {
        // the returened playlist details contains the details of playlist and a list of audio track
        APICaller.shared.getPlaylistDetails(playlist: playlist) { [weak self ] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model) :
                    
                    // convert to ResponseModels to ViewModel
                    //loop over the list of tracks and convert them
                    //since we are working with one section and one type of element
                    // no need to append because we are casting the whole array
                    self?.tracks = model.tracks.items.compactMap({ $0.track })

                    self?.viewModels =   model.tracks.items.compactMap({
                        RecommendedTrackCellViewModel(name: $0.track.name,
                                                      artistName: $0.track.artists.first?.name ?? "-",

                                                      artworkURL: URL(string: $0.track.album?.images.first?.url ?? "-"))
                    })
                    self?.collectionView.reloadData()
                    break
                case .failure(let error) :
                    break
                }
            }
        }
    }

}
extension DetailedPlayListViewController: UICollectionViewDelegate, UICollectionViewDataSource , PlaylistHeaderCollectionReusableViewDelegate {
   
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // start play list play in here  in queue
        print("play all ")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return viewModels.count
       }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell else {
                  return UICollectionViewCell()
              }
              cell.configure(with: viewModels[indexPath.row])
              return cell
    }
 
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath) as? PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerViewModel = PlaylistCellViewModel(
            name: playlist.name,
            artworkURL: URL(string: playlist.images.first?.url ?? "-"),
            creatorName: playlist.owner.display_name,
            description: playlist.description)
            header.configure(with: headerViewModel)
            header.delegate = self
            return header
    }
}


