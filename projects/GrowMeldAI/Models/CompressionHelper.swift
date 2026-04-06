// Services/Backup/Utilities/CompressionHelper.swift

import Foundation
import Compression

struct CompressionHelper {
    /// Compress data using ZLIB
    static func compress(_ data: Data) throws -> Data {
        let bufferSize = 65_536  // 64 KB chunks
        var compressedData = Data()
        
        var sourceOffset = 0
        while sourceOffset < data.count {
            let chunkSize = min(bufferSize, data.count - sourceOffset)
            let chunk = data.subdata(in: sourceOffset..<sourceOffset + chunkSize)
            sourceOffset += chunkSize
            
            let compressedChunk = try compressChunk(chunk)
            compressedData.append(compressedChunk)
        }
        
        return compressedData
    }
    
    /// Decompress ZLIB data
    static func decompress(_ data: Data, estimatedSize: Int = 1_048_576) throws -> Data {
        var outputBuffer = [UInt8](repeating: 0, count: estimatedSize)
        
        let result = data.withUnsafeBytes { inputBytes in
            compression_decode_buffer(
                &outputBuffer,
                outputBuffer.count,
                inputBytes.baseAddress!.assumingMemoryBound(to: UInt8.self),
                data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }
        
        guard result >= 0 else {
            throw BackupError.deserializationFailed("ZLIB decompression failed")
        }
        
        return Data(outputBuffer[..<result])
    }
    
    private static func compressChunk(_ chunk: Data) throws -> Data {
        var outputBuffer = [UInt8](repeating: 0, count: chunk.count)
        
        let result = chunk.withUnsafeBytes { inputBytes in
            withUnsafeMutableBytes(of: &outputBuffer) { outputBytes in
                compression_encode_buffer(
                    outputBytes.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    outputBuffer.count,
                    inputBytes.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    chunk.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        
        guard result > 0 else {
            throw BackupError.serializationFailed("ZLIB compression failed")
        }
        
        return Data(outputBuffer[..<result])
    }
}

// Services/Backup/Utilities/ChecksumValidator.swift

import Foundation
import CryptoKit

extension Data {
    /// Calculate SHA256 hash
    func sha256Hash() -> String {
        let digest = SHA256.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify against expected hash
    func validateChecksum(_ expectedHash: String) -> Bool {
        sha256Hash() == expectedHash
    }
}

// Services/Backup/Utilities/FileSystemHelper.swift

import Foundation
