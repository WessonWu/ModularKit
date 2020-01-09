import UIKit

public final class MKWatchDog {
    private let pingThread: PingThread
    
    public init(threshold: TimeInterval = 0.5, strictMode: Bool = true) {
        self.pingThread = PingThread(threshold: threshold, handler: { thread in
            let message = "👮 Main thread was blocked 👮"
            if strictMode {
                assert(UIApplication.shared.applicationState == .background, message)
            } else {
                print(message)
            }
        })
        self.pingThread.start()
    }
    
    deinit {
        self.pingThread.cancel()
    }
}

fileprivate class PingThread: Thread {
    let threshold: TimeInterval
    let handler: (PingThread) -> Void
    
    var pingTaskIsRunning = false
    
    init(threshold: TimeInterval, handler: @escaping (PingThread) -> Void) {
        self.threshold = threshold
        self.handler = handler
    }
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        while !self.isCancelled {
            self.pingTaskIsRunning = true
            DispatchQueue.main.async {
                self.pingTaskIsRunning = false
                semaphore.signal()
            }
            
            Thread.sleep(forTimeInterval: self.threshold)
            if self.pingTaskIsRunning {
                self.handler(self)
            }
            
            semaphore.wait()
        }
    }
}
