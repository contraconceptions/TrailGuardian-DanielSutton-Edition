import Foundation

class APIManager {
    static let shared = APIManager()
    
    // API Configuration
    private var apiKeys: [String: String] = [:]
    private var rateLimiters: [String: RateLimiter] = [:]
    private var cache: [String: CachedResponse] = [:]
    
    private init() {
        // Initialize rate limiters for each API
        rateLimiters["ridb"] = RateLimiter(callsPerSecond: 10, callsPerDay: 10000)
        rateLimiters["campflare"] = RateLimiter(callsPerSecond: 2, callsPerDay: 5000)
        rateLimiters["osm"] = RateLimiter(callsPerSecond: 1, callsPerDay: 10000)
        rateLimiters["usgs"] = RateLimiter(callsPerSecond: 5, callsPerDay: 50000)
        rateLimiters["nws"] = RateLimiter(callsPerSecond: 10, callsPerDay: 100000)
    }
    
    func setAPIKey(_ key: String, for service: String) {
        apiKeys[service] = key
    }
    
    func getAPIKey(for service: String) -> String? {
        return apiKeys[service]
    }
    
    func canMakeRequest(for service: String) -> Bool {
        guard let limiter = rateLimiters[service] else { return true }
        return limiter.canMakeRequest()
    }
    
    func recordRequest(for service: String) {
        rateLimiters[service]?.recordRequest()
    }
    
    func getCachedResponse(for key: String) -> Data? {
        guard let cached = cache[key],
              cached.expiresAt > Date() else {
            cache.removeValue(forKey: key)
            return nil
        }
        return cached.data
    }
    
    func cacheResponse(_ data: Data, for key: String, expiresIn: TimeInterval = 3600) {
        cache[key] = CachedResponse(data: data, expiresAt: Date().addingTimeInterval(expiresIn))
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

class RateLimiter {
    let callsPerSecond: Int
    let callsPerDay: Int
    private var recentCalls: [Date] = []
    private var dailyCalls: Int = 0
    private var lastReset: Date = Date()
    
    init(callsPerSecond: Int, callsPerDay: Int) {
        self.callsPerSecond = callsPerSecond
        self.callsPerDay = callsPerDay
    }
    
    func canMakeRequest() -> Bool {
        let now = Date()
        
        // Reset daily counter if needed
        if Calendar.current.isDate(now, inSameDayAs: lastReset) == false {
            dailyCalls = 0
            lastReset = now
        }
        
        // Check daily limit
        if dailyCalls >= callsPerDay {
            return false
        }
        
        // Check per-second limit
        recentCalls.removeAll { $0 < now.addingTimeInterval(-1) }
        if recentCalls.count >= callsPerSecond {
            return false
        }
        
        return true
    }
    
    func recordRequest() {
        let now = Date()
        recentCalls.append(now)
        dailyCalls += 1
    }
}

struct CachedResponse {
    let data: Data
    let expiresAt: Date
}

