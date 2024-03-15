// Cache by Alex Maggio
import Foundation

public class AMCache {
    private var cachedValues: [String: AMCacheData] = [:]
    
    public init() {
        loadFromDisk(ignoreExpired: true)
    }
        
    public func clear() {
        cachedValues.removeAll()
    }
    
    @discardableResult
    public func cacheValue(key: String, value: Data?) -> Bool {
        guard
            let value = value,
            let cachedString = String(data: value, encoding: .utf8)
        else { return false }
        cachedValues[key] = AMCacheData(response: cachedString, data: value)
        
        if (cachedValues.count % max(1, CacheConfiguration.dumpEvery)) == 0 {
            saveToDisk()
        }
        
        return true
    }
    
    public func getCachedValue(for key: String) -> Data? {
        if let entry = cachedValues[key], !entry.isExpired {
            return entry.data
        }
        
        return nil
    }
    
    @discardableResult
    private func saveToDisk() -> Bool {
        let file = CacheConfiguration.dbFile

        var linesToWrite: [String] = []
        cachedValues.forEach { (key: Hashable, value: AMCacheData) in
            if !value.isExpired, let encoded = try? JSONEncoder().encode(value) {
                linesToWrite.append("\(key),\(encoded.base64EncodedString())")
            }
        }

        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                
                try linesToWrite
                    .joined(separator: "\n")
                    .write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Unable to write cache to disk")
                return false
            }
        }
        
        return true
    }
    
    private func loadFromDisk(ignoreExpired: Bool = false) {
        let file = CacheConfiguration.dbFile

        if let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)

            do {
                let savedFileContents = try String(contentsOf: fileURL, encoding: .utf8).split(separator: "\n").map({ String($0) })
                
                savedFileContents.forEach {
                    let line = $0.split(separator: ",", maxSplits: 1).map { String($0) }
                    if line.count > 1,
                       let encodedData = line[1].data(using: .utf8),
                       let decoded = try? JSONDecoder().decode(AMCacheData.self, from: encodedData) {
                        if ignoreExpired || !decoded.isExpired {
                            cachedValues[line[0]] = decoded
                        }
                    }
                }
            } catch {
                print("Unable to read cache from disk")
            }
        }
    }
}

