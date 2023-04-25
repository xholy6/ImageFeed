import Foundation

protocol AuthHelperProtocol {
    var authRequest: URLRequest? { get }
    func code(from url: URL) -> String?
}
