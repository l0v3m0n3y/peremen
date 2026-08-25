import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            task.resume()
        }
    }
}

public class Peremen {
    private let api = "https://peremen.space/api/v2"
    private var headers: [String: String]
    
    private var deviceId: String?
    private var userId: String?
    
    public init() {
        self.deviceId = nil
        self.userId = nil
        self.headers = [
            "Connection": "keep-alive",
            "Accept-Encoding": "deflate, zstd",
            "Accept-Language": "en-US,en;q=0.9",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
        ]
    }
    
    private func fetchJSON(from urlString: String,method: HTTPMethod = .get,body: Data? = nil,queryParameters: [String: String]? = nil) async throws -> Any {
        var urlComponents = URLComponents(string: urlString)
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents?.url else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data)
    }
   
    public func requestCode(email: String) async throws -> Any {
        let urlString = "\(api)/premium/user-email-verification"
        
        let body: [String: Any] = ["email": email]
        
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(from: urlString,method: .post,body: bodyData,queryParameters: nil)
    }

    public func authWithCode(email: String, otpCode: Int) async throws -> Any {
        let urlString = "\(api)/premium/check-email-otp"
        let generatedDeviceId = UUID().uuidString.lowercased()
        self.deviceId = generatedDeviceId
        
        let body: [String: Any] = ["email": email, "otp_code": otp_code, "deviceId": generatedDeviceId]
        
        
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let json = try await fetchJSON(from: urlString,method: .post,body: bodyData,queryParameters: nil)
        
        if let dictionary = json as? [String: Any],
           let dataContainer = dictionary["data"] as? [String: Any],
           let user = dataContainer["user"] as? [String: Any],
           let publicUserId = user["public_user_id"] as? String {
            self.userId = publicUserId
        }
        
        return json
    }

    public func getProxy() async throws -> Any {
        let urlString = "\(api)/premium/get-proxy-with-subscription"
        
        let body: [String: Any] = [
            "userId": userId ?? "",
            "deviceId": deviceId ?? "",
            "deviceIp": "127.0.0.1",
            "withAuth": false
        ]
        
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(from: urlString,method: .post,body: bodyData,queryParameters: nil)
    }

    public func deactivateDevice() async throws -> Any {
        let urlString = "\(api)/premium/deactivate-device"
        
        let body: [String: Any] = [
            "userId": userId ?? "",
            "deviceId": deviceId ?? ""
        ]
        
        self.deviceId = nil
        self.userId = nil
        
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(from: urlString,method: .post,body: bodyData,queryParameters: nil)
    }
}
