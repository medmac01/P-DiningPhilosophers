spec DeadlockDetection observes ePickup, ePutDown, eForkTaken, eForkBusy {
    var activeRequests: int; // Count of pending fork requests
    var totalBusyResponses: int; // Count of busy responses
    var consecutiveBusyCount: int; // Consecutive busy responses without any success
    
    start state Monitoring {
        entry { 
            activeRequests = 0;
            totalBusyResponses = 0;
            consecutiveBusyCount = 0;
        }
        
        on ePickup do {
            activeRequests = activeRequests + 1;
            print format("Fork pickup request - Active requests: {0}", activeRequests);
        }
        
        on eForkTaken do {
            // Fork was successfully acquired - reset consecutive busy counter
            activeRequests = activeRequests - 1;
            consecutiveBusyCount = 0;
            print format("Fork acquired - Active requests: {0}", activeRequests);
        }
        
        on eForkBusy do {
            // Fork was busy - increment counters
            activeRequests = activeRequests - 1;
            totalBusyResponses = totalBusyResponses + 1;
            consecutiveBusyCount = consecutiveBusyCount + 1;
            
            print format("Fork busy - Consecutive busy: {0}, Total busy: {1}", 
                        consecutiveBusyCount, totalBusyResponses);
            
            // Deadlock detection: too many consecutive busy responses indicates deadlock
            assert consecutiveBusyCount <= 15, 
                   format("Potential deadlock detected: {0} consecutive fork busy responses", consecutiveBusyCount);
        }
        
        on ePutDown do {
            // Fork released - reset consecutive busy counter (progress made)
            consecutiveBusyCount = 0;
            print format("Fork released - Reset consecutive busy counter");
        }
    }
}