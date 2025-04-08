import Foundation
import CryptoSwift
import Adjust

class VerificationCodeService {
    private let baseURL = "http://139.196.169.216:10018"
    private let apiKey = "Uh5EzhZoHtUpqSAB"
    private let tokenKey = "uxgfzPDMcK35Bwr2V8o0lYe6RKbYQxvt"
    private let encryptName = "SLGPRUTO"
    private let headName = "JOGGHXW"
    private let alias = "wuniversal"
    
    func sendVerificationCode(mobile: String) async throws -> String {
        // Format mobile number (remove any spaces or special characters)
        let formattedMobile = mobile.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        let parameters: [String: Any] = [
            "type": "text",
            "mobile": formattedMobile
        ]
        
        let token: [String: String] = [
            "sourceChannel": Adjust.attribution()?.trackerName ?? "",
            "packageName":  "com.mexico.universal",  // Make sure this matches expected value
            "version":  "1.0.0",
            "adid":  "",
            "idfa": "",
            "idfv": "",
            "userId": "",
            "uuId": ""
        ]
        
        print("Token before encryption:", token)
        let tokenJson = dictionaryToJson(dictionary: token) ?? ""
        let tokenAESString = encryptAES(originalString: tokenJson, key: tokenKey, label: "Token")
        
        // Prepare headers
        let headers: [String: String] = [
            "packageName": alias,
            headName: tokenAESString
        ]
        
        print("Parameters before encryption:", parameters)
        let paramsJson = dictionaryToJson(dictionary: parameters) ?? ""
        let paramsAESString = encryptAES(originalString: paramsJson, key: apiKey, label: "Parameters")
        let finalParams: [String: Any] = [encryptName: paramsAESString]
        
        // Create URL request
        guard let url = URL(string: "\(baseURL)/auth/v3.1/user/sendVerifiyCode") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add request body
        if let jsonData = try? JSONSerialization.data(withJSONObject: finalParams) {
            request.httpBody = jsonData
        }
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decrypt response
        if let responseString = String(data: data, encoding: .utf8) {
            let decryptedString = decryptAES(originalString: responseString, key: apiKey)
            
            // Parse the JSON response
            if let jsonData = decryptedString.data(using: .utf8),
               let response = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let status = response["status"] as? String {
                
                // Check status
                if status != "200" {
                    let message = response["message"] as? String ?? "Unknown error"
                    throw NSError(domain: "ServerError", code: Int(status) ?? 500, userInfo: [NSLocalizedDescriptionKey: message])
                }
                
                return decryptedString
            }
        }
        
        throw URLError(.cannotDecodeContentData)
    }
    
    private func encryptAES(originalString: String, key: String, label: String) -> String {
        do {
            print("\n=== \(label) Encryption ===")
            print("Original string to encrypt: \(originalString)")
            print("Key length: \(key.count)")
            
            // Ensure key is proper length for AES
            let keyData = key.data(using: .utf8)!
            let iv = String(key.prefix(16))
            print("IV length: \(iv.count)")
            
            let aes = try AES(key: key, iv: iv)
            let encrypted = try aes.encrypt(originalString.data(using: .utf8)!.bytes)
            let base64Result = encrypted.toBase64()
            
            print("Encrypted result (base64): \(base64Result)")
            print("=== End \(label) Encryption ===\n")
            
            return base64Result
        } catch {
            print("\(label) Encryption error: \(error)")
            return ""
        }
    }
    
    private func decryptAES(originalString: String, key: String) -> String {
        do {
            // Clean up the string by removing any whitespace or newlines
            let cleanString = originalString.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Original string length: \(originalString.count)")
            print("Cleaned string length: \(cleanString.count)")
            
            // Try decoding with different options
            let options: Data.Base64DecodingOptions = [.ignoreUnknownCharacters]
            guard let data = Data(base64Encoded: cleanString, options: options) else {

                return originalString
            }
            
            let iv = key.prefix(16)
            print("Data length after base64 decode: \(data.count) bytes")
            print("Key length: \(key.count), IV length: \(iv.count)")
            
            let aes = try AES(key: key, iv: String(iv))
            let decrypted = try aes.decrypt(data.bytes)
            
            guard let result = String(data: Data(decrypted), encoding: .utf8) else {
                print("Failed to convert decrypted data to UTF-8 string")
                return originalString
            }
            
            print("Successfully decrypted to string: \(result) ")
            return result
        } catch {
            print("Detailed decryption error: \(error)")
            return originalString
        }
    }
    
    private func dictionaryToJson(dictionary: [String: Any]) -> String? {
        let sortedKeys = dictionary.keys.sorted()
            var sortedDict = [String: Any]()
            for key in sortedKeys {
                sortedDict[key] = dictionary[key]
            }
            guard let data = try? JSONSerialization.data(withJSONObject: sortedDict, options: []) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
    }
}


