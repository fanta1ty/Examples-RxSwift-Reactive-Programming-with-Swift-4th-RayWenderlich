import Foundation
import RxSwift
import RxCocoa

class EONET {
  static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
  static let categoriesEndpoint = "/categories"
  static let eventsEndpoint = "/events"
  
  static var categories: Observable<[EOCategory]> = {
    let request: Observable<[EOCategory]> = EONET.request(endpoint: categoriesEndpoint,
                                                          contentIdentifier: "categories")
    return request
      .map { categories in
        categories.sorted { $0.name < $1.name }
      }
      .catchErrorJustReturn([])
      .share(replay: 1, scope: .forever)
  }()
  
  static func events(forLast days: Int = 360,
                     category: EOCategory) -> Observable<[EOEvent]> {
    let openEvents = events(forLast: days, closed: false, endPoint: category.endpoint)
    let closedEvents = events(forLast: days, closed: true, endPoint: category.endpoint)
    
    return Observable.of(openEvents, closedEvents)
      .merge()
      .reduce([]) { running, new in
        running + new
      }
  }

  static func jsonDecoder(contentIdentifier: String) -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.userInfo[.contentIdentifier] = contentIdentifier
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }

  static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
    return events.filter { event in
      return event.categories.contains(where: { $0.id == category.id }) && !category.events.contains {
        $0.id == event.id
      }
      }
      .sorted(by: EOEvent.compareDates)
  }
  
  private static func events(forLast days: Int,
                             closed: Bool,
                             endPoint: String) -> Observable<[EOEvent]> {
    let query: [String: Any] = [
      "days": days,
      "status": (closed ? "closed" : "open")
    ]
    
    let request: Observable<[EOEvent]> = EONET.request(endpoint: endPoint,
                                                       query: query,
                                                       contentIdentifier: "events")
    return request.catchErrorJustReturn([])
  }

  static func request<T: Decodable>(endpoint: String,
                                    query: [String: Any] = [:],
                                    contentIdentifier: String) -> Observable<T> {
    do {
      guard let url = URL(string: API)?.appendingPathComponent(endpoint),
            var components = URLComponents(url: url,
                                           resolvingAgainstBaseURL: true) else {
        throw EOError.invalidURL(endpoint)
      }
      
      components.queryItems = try query.compactMap({ key, value in
        guard let v = value as? CustomStringConvertible else {
          throw EOError.invalidParameter(key, value)
        }
        
        return URLQueryItem(name: key, value: v.description)
      })
      
      guard let finalURL = components.url else {
        throw EOError.invalidURL(endpoint)
      }
      
      let request = URLRequest(url: finalURL)
      
      return URLSession.shared.rx.response(request: request)
        .map { (result: (response: HTTPURLResponse, data: Data)) -> T in
          let decoder = self.jsonDecoder(contentIdentifier: contentIdentifier)
          let envelope = try decoder.decode(EOEnvelope<T>.self, from: result.data)
          return envelope.content
        }
    } catch {
      return Observable.empty()
    }
  }
}
