//
//  ViewController.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    enum BrowseSectionType {
        case newReleases(viewModels: [NewReleasesCellViewModel])
        case featuredPlaylists(viewModels: [PlaylistCellViewModel])
        case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
    }
    private var sections = [BrowseSectionType]()
    //the reason why we want to save original data model returned from API maybe we will use them later in other function
    var newReleases : [Album] = []
    var playlists : [Playlist] = []
    var tracks: [AudioTrack] = []
    
    private var collectionView: UICollectionView = UICollectionView(
         frame: .zero,
         collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ -> NSCollectionLayoutSection? in
             return HomeViewController.createSectionLayout(section: sectionIndex)
         }))
    
     private let spinner: UIActivityIndicatorView = {
         let spinner = UIActivityIndicatorView()
         spinner.tintColor = .label
         spinner.hidesWhenStopped = true
         return spinner
     }()
    
    
   lazy private var collectionView3 : UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            //1) why we did call it with static because property initializers run before 'self' is available so (we cannot use instance member 'createSectionLayout' within property initializer)
            //2) will it work Self.createSectionLayout(of: sectionIndex) ? yes but you have to add it lazy or without lazy but do it without closure
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
       return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done,target: self,action: #selector(tapToGoProfile))
        // and what this closure function do it's basicly return a layout  to the  comppositon  layout  of how that section should look
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        addLongPressTapGesture()
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          collectionView.frame = view.bounds
      }
    private func configureCollectionView() {
        view.addSubview(collectionView)
        //  new releases , featuredPlaylists , Recomended Track
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(PlaylistsCollectionViewCell.self,
                                forCellWithReuseIdentifier: PlaylistsCollectionViewCell.identifier)
        collectionView.register(TrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        
        collectionView.register(HomeHeadersCollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: HomeHeadersCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }


    //actually what we have in our  api caller : Featured Playlist , Recommended Tracks , New Releases
    private func fetchData() {
          let group = DispatchGroup()
          group.enter()
          group.enter()
          group.enter()
          
          var newReleases: NewReleasesResponse?
          var featuredPlaylists: FeaturedPlaylistsResponse?
          var recommendedTracks: RecommendationsResponse?
          //New  Releases
          APICaller.shared.getNewReleases { result in
              defer {
                  group.leave()
              }
              switch result {
              case .success(let model):
                  newReleases = model
              case .failure(let error):
                  print(error.localizedDescription)
              }
          }
          //FeaturedPlayLists
          APICaller.shared.getFeaturedPlaylists { result in
              defer {
                  group.leave()
              }
              switch result {
              case .success(let model):
                  featuredPlaylists = model
              case .failure(let error):
                  print(error.localizedDescription)
              }
          }
          //Recommended
          APICaller.shared.getRecommendedGenres { result in
              
              switch result {
              case .success(let model):
                  let genres = model.genres
                  var seeds = Set<String>()
                  while seeds.count < 5 {
                      if let random = genres.randomElement() {
                          seeds.insert(random)
                      }
                  }
                  APICaller.shared.getRecommendations(genres: seeds) { recommendedResults in
                      defer {
                          group.leave()
                      }
                      switch recommendedResults {
                      case .success(let model):
                          recommendedTracks = model
                      case .failure(let error):
                          print(error.localizedDescription)
                      }
                      
                  }
              case .failure(let error):
                  print(error.localizedDescription)
              }
          }
          group.notify(queue: .main) {
              guard let releases = newReleases?.albums.items,
                    let playlists = featuredPlaylists?.playlists.items,
                    let tracks = recommendedTracks?.tracks
              else { return }
              self.configureViewModels(newReleases: releases,
                                       playlists: playlists,
                                       tracks: tracks)
              
          }
      }
    

    //ResponseModels -> ViewModels
     private func configureViewModels(newReleases: [Album], playlists: [Playlist], tracks: [AudioTrack]) {
       
     
         self.newReleases = newReleases
         self.playlists = playlists
         self.tracks = tracks
         //we gonna convert every album into view models
         sections.append(.newReleases(viewModels: newReleases.compactMap({
             return NewReleasesCellViewModel(
                 name: $0.name,
                 artworkURL: URL(string: $0.images.first?.url ?? ""),
                 numberOfTracks: $0.total_tracks,
                 artistName: $0.artists.first?.name ?? "-")
         })))
//         sections.append(.featuredPlaylists(viewModels: []))
//         sections.append(.recommendedTracks(viewModels: []))

         sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
             return PlaylistCellViewModel(
                 name: $0.name,
                 artworkURL: URL(string: $0.images.first?.url ?? "-") ,
                 creatorName: $0.owner.display_name ,
                 description: $0.description
             )
         })))
         sections.append(.recommendedTracks(viewModels: tracks.compactMap({
             return RecommendedTrackCellViewModel(
                 name: $0.name,
                 artistName: $0.artists.first?.name ?? "-",
                 artworkURL: URL(string: $0.album?.images.first?.url ?? "-"))
         })))
         collectionView.reloadData() // this step is done after we updated the actual viewmodel and fill our array section that popoulate the collection view in the extension part of ViewDataSource
     }
    
 
    
    @objc func tapToGoProfile() {
        let profileVc = SettingsViewController()
        profileVc.title  = "Setting"
        navigationController?.pushViewController(  profileVc, animated: true)
    }
    private func addLongPressTapGesture () {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress ( _ gesture : UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) , indexPath.section == 2 else
        {
            return
        }
        let model = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: model.name, message: "whould you like to add this tracks ", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add", style: .default , handler: { [weak self]  _ in
            let vc = LibraryPlaylistViewController()
            vc.selectionHandler = { playlist in // like listener that wait the function that call here to finish
                APICaller.shared.addTrackToPlaylist(
                                   track: model,
                                   playlist: playlist) { succes in
                                    print("Added to playlist success: \(succes)")
                               }
            }
            vc.title = "Select Playlist"
            
            self?.present(UINavigationController(rootViewController: vc), animated: true)
        }))
        present(actionSheet, animated: true)

        
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
            switch type {
            case .newReleases(let viewModels):
                return viewModels.count
            case .featuredPlaylists(let viewModels):
                return viewModels.count
            case .recommendedTracks(let viewModels):
                return viewModels.count
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        // determine which section selected
        let selectedSelection = sections[indexPath.section]
        
        switch selectedSelection {
        case .featuredPlaylists :
            let playlist = playlists[indexPath.row]
            let vc = DetailedPlayListViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        case .newReleases :
            let newRelease = newReleases[indexPath.row]
            // then we will pass this object to viewController to show it and pushed it
            let vc = DetailedAlbumViewController(album: newRelease)
            vc.title = newRelease.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            break
        case .recommendedTracks :
            break
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeHeadersCollectionReusableView.identifier,
            for: indexPath) as? HomeHeadersCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let type = sections[indexPath.section]
        switch type {
        case .newReleases:
            header.configure(with: "New Releases")
        case .featuredPlaylists:
            header.configure(with: "Featured Playlists")
        case .recommendedTracks:
            header.configure(with: "Recommended Tracks")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // this function is executed after numberOfItemsInSection , so after determining the nbr of element in each section , we can see if we will enter the switch case or note
        // since nbr of element in section feature playist or recommended track is zero so there will loop over it so we will not find  and indexPath.Section == 1 or 2 => so it will not enter the switch case for both playlist and track recommended
        // we will have only [0: sectionID ,1 : ElementIndex] [0,1], [0,2], [0,3],[0,4]

        let type = sections[indexPath.section]

               switch type {
               case .newReleases(let viewModels): // viewModels is the array of newReleaseModel in view part
                   guard let cell = collectionView.dequeueReusableCell(
                       withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                       for: indexPath) as? NewReleaseCollectionViewCell else { // guard that cell to see that can be casted or not
                       return UICollectionViewCell()
                   }
                   let viewModel = viewModels[indexPath.row]
                   //design configureation and not logic transformation
                   cell.configure(with: viewModel)
                   return cell
                   
               case .featuredPlaylists(let viewModels):
                   guard let cell = collectionView.dequeueReusableCell(
                       withReuseIdentifier: PlaylistsCollectionViewCell.identifier,
                       for: indexPath) as? PlaylistsCollectionViewCell else {
                       return UICollectionViewCell()
                   }
                   let viewModel = viewModels[indexPath.row]
                   cell.configure(with: viewModel)
                   return cell
                   
               case .recommendedTracks(let viewModels):
                   guard let cell = collectionView.dequeueReusableCell(
                       withReuseIdentifier: TrackCollectionViewCell.identifier,
                       for: indexPath) as? TrackCollectionViewCell else {
                       return UICollectionViewCell()
                   }
                   let viewModel = viewModels[indexPath.row]
                   cell.configure(with: viewModel)

                   return cell
               }
        
    }
    
    // action on select when select relase open release page
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        collectionView.deselectItem(at: indexPath, animated: true)
//    }
    
    //we specied the index of section and this is how we allow different section to have a different look
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
       let suplementaryViews = [
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize:NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            ), // size of header
            elementKind: UICollectionView.elementKindSectionHeader ,
            alignment: .top) //top of section
        ]
        switch section {
        case 0: // New Releases
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group
                    let verticalGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(360)),
                        subitem: item,
                        count: 3)//vertical group of 3 item when the group is full it create another group verticaly
            //Final Horizontal Group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(360)),
                subitem: verticalGroup,
                count: 1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = suplementaryViews
            return section
        case 1:
            //Featured Playlists
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            //Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(400)),
                subitem: item,
                count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(400)),
                subitem: verticalGroup,
                count: 2)
            
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = suplementaryViews
            return section
        case 2: //Recommended Tracks
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(100)),
                subitem: item,
                count: 1) // par row how 
            //Section
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.boundarySupplementaryItems = suplementaryViews
            return section
        default:
            //Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Vertical Group
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(130)),
                subitem: item,
                count: 3)
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = suplementaryViews
            return section
        }
    }
    
}
