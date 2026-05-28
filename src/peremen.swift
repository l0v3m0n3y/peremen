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
   
    public func request_code(email: String) async throws -> Any {
        let urlString = "\(api)/premium/user-email-verification"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: responseData)
    }

    public func auth_with_code(email: String, otp_code: Int) async throws -> Any {
        let urlString = "\(api)/premium/check-email-otp"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        let generatedDeviceId = UUID().uuidString.lowercased()
        self.deviceId = generatedDeviceId
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "otp_code": otp_code, "deviceId": generatedDeviceId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: responseData)
        
        if let dictionary = json as? [String: Any],
           let dataContainer = dictionary["data"] as? [String: Any],
           let user = dataContainer["user"] as? [String: Any],
           let publicUserId = user["public_user_id"] as? String {
            self.userId = publicUserId
        }
        
        return json
    }

    public func get_proxy() async throws -> Any {
        let urlString = "\(api)/premium/get-proxy-with-subscription"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId ?? "",
            "deviceId": deviceId ?? "",
            "deviceIp": "127.0.0.1",
            "withAuth": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: responseData)
    }

    public func deactivate_device() async throws -> Any {
        let urlString = "\(api)/premium/deactivate-device"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId ?? "",
            "deviceId": deviceId ?? ""
        ]
        
        self.deviceId = nil
        self.userId = nil
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: responseData)
    }
}
