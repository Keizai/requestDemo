private func decryptAES(originalString: String, key: String) -> String {
    do {
        // Remove any whitespace or newlines that might have been added
        let cleanString = originalString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = Data(base64Encoded: cleanString, options: .ignoreUnknownCharacters) else {
            print("Error: Failed to decode base64 string")
            return originalString
        }
        
        let iv = key.prefix(16)
        print("Using IV:", String(iv))
        
        // Create AES instance with proper padding
        let aes = try AES(key: key, iv: String(iv), padding: .pkcs7)
        
        let decrypted = try aes.decrypt(data.bytes)
        
        if let result = String(data: Data(decrypted), encoding: .utf8) {
            print("Successfully decrypted to:", result)
            return result
        } else {
            print("Error: Failed to convert decrypted data to string")
            return originalString
        }
    } catch {
        print("Detailed decryption error: \(error)")
        return originalString
    }
} 