//
//  ApiCaller.swift
//  spotifyClone
//
//  Created by Ahmed Mac on 13/6/2023.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
     
     private init() { }
     
     struct Constants {
         static let baseAPIURL = "https://api.spotify.com/v1"
     }
    enum APIError : Error {
        case failedToGetData
    }
    
    enum HTTPMethod: String {
          case GET
          case POST
          case DELETE
          case PUT
      }
    
    // MARK: -Profile
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
      
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me"),
            type: .GET) { baseRequest in // the completion gonna return for use the request
          let task = URLSession.shared.dataTask(with: baseRequest) { data, _, err in
              guard let data = data, err == nil else {
                  completion(.failure(APIError.failedToGetData))
                  return
              }
              do {
      // this method is used to see the structre of json result and based on it we will try to build a codable model in order to decoded
//let resultJson = try JSONSerialization.jsonObject(with: data , options: .allowFragments)print ("byyyy \(resultJson)")
                  let result = try JSONDecoder().decode(UserProfile.self, from: data)
//                  print (result) printing result here will help us to know if our result is decodable in case
//                  it 's not it will give us error and to idenify the error you have to hide some field every time
//                  the say which field responsible for that
                  completion(.success(result))
              } catch {
                  print(error.localizedDescription)
                  completion(.failure(error))
              }
          }
          task.resume()
      }
  }
    
    //MARK: Albums
    
    func getAlbumDetails(album: Album, completion: @escaping(Result<AlbumDetailsResponse,Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/\(album.id)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                guard let data = data else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    

                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    print(result)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }

            }
            task.resume()
        }
    }
    
    func getSavedAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                guard let data = data else {
                    print(APIError.failedToGetData)
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LibraryAlbumsResponse.self, from: data)
                    completion(.success(result.items.compactMap( { $0.album })))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func saveAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, err in
                guard let data = data,
                let code = (response as? HTTPURLResponse)?.statusCode
                else {
                    print(APIError.failedToGetData)
                    completion(false)
                    return
                }
                completion(code == 200)
            }
            task.resume()
        }
    }
    //MARK: - Categories

    func getAllCategories(completion: @escaping(Result<CategoryResponse, Error>) -> Void) {
         createRequest(with: URL(string:Constants.baseAPIURL + "/browse/categories"), type: .GET) { request in
             let task = URLSession.shared.dataTask(with: request) { data, _, err in
                 guard let data = data else {
                     print(APIError.failedToGetData)
                     return
                 }
                 do {
                     let result = try JSONDecoder().decode(CategoryResponse.self, from: data)
                     completion(.success(result))
                 } catch {
                     completion(.failure(error))
                 }

             }
             task.resume()
         }
     }
     func getCategoryPlaylist(category: Category, completion: @escaping(Result<[Playlist], Error>) -> Void) {
         createRequest(with: URL(string:Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists"), type: .GET) { request in
             let task = URLSession.shared.dataTask(with: request) { data, _, err in
                 guard let data = data else {
                     print(APIError.failedToGetData)
                     return
                 }
                 do {
                     let result = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                     let playlists = result.playlists.items
                     completion(.success(playlists))
                 } catch {
                     completion(.failure(error))
                 }
             }
             task.resume()
         }
     }
    
    // MARK: - Search
    // so in stead of  returning all 4 different  type of result (artis,playlist,track) which is results.(artist,playlist).items (TracksResponse, AlbumResponse,...) we gonne cast them in one model but having different type and return them
    func searchResult(query : String , completion : @escaping (Result<[SearchResult],Error>) -> Void) {
        // if the user type  a space , we don't want to put it , so we want to encode it to be url encoded
        // %20 for space
        createRequest(with: URL(
                   string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                             type: .GET) { request in
                   print(request.url?.absoluteString ?? "none")
                   let task = URLSession.shared.dataTask(with: request) { data, _, err in
                       guard let data = data else {
                           print(APIError.failedToGetData)
                           return
                       }
                       do {
                           let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                           //and now we create one type SearchResultModel that encapsulate all of our search results
                           var searchResults: [SearchResult] = [] //
                           // so what we are basicly do is to take a tracks from SearchResultResponse.tracks
                           // and convert them to one type which is searchResult
                           searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0 )}))
                           searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0 )}))
                           searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0 )}))
                           searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0 )}))
                           
                           completion(.success(searchResults))
                       } catch {
                           completion(.failure(error))
                       }
                   }
                   task.resume()
               }
    }
    
    // MARK: - Browse
    
    func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
         createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
//             print(request.url?.absoluteString ?? "nothing") for url printing
             let task = URLSession.shared.dataTask(with: request) { data, _, err in
                 guard let data = data else {
                     completion(.failure(APIError.failedToGetData))
                     return
                 }
                 do {
                     let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                     completion(.success(result))
                 } catch {
                     completion(.failure(error))
                 }

             }
             task.resume()
         }
     }
    
    func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
           let seeds = genres.joined(separator: ",")
           createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=10&seed_genres=\(seeds)"), type: .GET) { request in
               let task = URLSession.shared.dataTask(with: request) { data, _, err in
                   guard let data = data else {
                       completion(.failure(APIError.failedToGetData))
                       return
                   }
                   do {
                       let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                       completion(.success(result))
                   } catch {
                       completion(.failure(error))
                   }
               }
               task.resume()
           }
       }
    func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?country=TR"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                guard let data = data else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=10"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                guard let data = data else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
    
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Playlists
     
     func getPlaylistDetails(playlist: Playlist, completion: @escaping(Result<PlaylistDetailsResponse, Error>) -> Void) {
         createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)"), type: .GET) { request in
             let task = URLSession.shared.dataTask(with: request) { data, _, err in
                 guard let data = data else {
                     print(APIError.failedToGetData)
                     return
                 }
                 do {
                     let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                     completion(.success(result))
                 } catch {
                     print(error.localizedDescription)
                     completion(.failure(error))
                 }

             }
             task.resume()
         }
     }

     
     func getCurrentUserPlaylist(completion: @escaping (Result<[Playlist], Error>) -> Void) {
         createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists/?limit=50"), type: .GET) { request in
             let task = URLSession.shared.dataTask(with: request) { data, _, err in
                 guard let data = data else {
                     completion(.failure(APIError.failedToGetData))
                     return
                 }
                 do {
                     let result  = try JSONDecoder().decode(LibraryPlaylistResponse.self, from: data)
                     completion(.success(result.items))
                 } catch {
                     print(error)
                     completion(.failure(error))
                 }
             }
             task.resume()
         }
     }
    
   
    func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
           getCurrentUserProfile { [weak self] result in
               switch result {
               case .success(let profile):
                   let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                   self?.createRequest(with: URL(string: urlString), type: .POST, completion: { baseRequest in
                       var request = baseRequest
                       let json = [
                           "name": name
                       ]
                       request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                       let task = URLSession.shared.dataTask(with: request) { data, _, err in
                           guard let data = data else {
                               print(APIError.failedToGetData)
                               completion(false)
                               return
                           }
                           do {
                               let result = try JSONSerialization.jsonObject(with: data)
                               if let response = result as? [String: Any], response["id"] as? String != nil {
                                   print("Created")
                                   completion(true)
                               } else {
                                   completion(false)
                               }
                           } catch {
                               print(error)
                               completion(false)
                           }
                       }
                       task.resume()
                   })
               case .failure(let error):
                   print(error.localizedDescription)
               }
           }
       }
    
    /*
     the completion here work as a return method when we call inside the creatte Request completion(UrlRequest) , so outside the func createRequest (with "https:pool" , urlRequest {
     if (urlRequest) // do smth
     }
     */

    /* Value of optional type '((URLRequest) -> Void)?' must be unwrapped to a value of type '(URLRequest) -> Void'
      the completion value is optional so it can happen that at certain method call we are not using it
     so we must unwrap it so we can use it only if it's not nil */
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void // this is an optional completion
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return } // guard let is used lil tan4if check if it has value or condition true
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
          createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
              var request = baseRequest
              let json = [
                  "uris": ["spotify:track:\(track.id)"]
              ]
              request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
              request.setValue("application/json", forHTTPHeaderField: "Content-Type")
              print(request.url?.absoluteString ?? "none")

              let task = URLSession.shared.dataTask(with: request) { data, _, err in
                  guard let data = data else {
                      print(APIError.failedToGetData)
                      return
                  }
                  print(data)

                  do {
                      let result = try? JSONSerialization.jsonObject(with: data)
                      print(result)
                      if let response = result as? [String: Any],
                         response["snapshot_id"] as? String != nil {
                          completion(true)
                      } else {
                          completion(false)

                      }
                  }
                  catch {
                      print(error.localizedDescription)
                      completion(false)
                  }

              }
              task.resume()
          }
      }
    
    
    func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
            var request = baseRequest
            let json: [String: Any] = [
                "tracks": [
                    [
                        "uri": "spotify:track:\(track.id)"
                        
                    ]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                guard let data = data else {
                    print(APIError.failedToGetData)
                    return
                }
                do {
                    let result = try? JSONSerialization.jsonObject(with: data)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)

                    }
                }
                catch {
                    print(error.localizedDescription)
                    completion(false)
                }

            }
            task.resume()
        }
    }
}

