spec DeadlockDetection observes ePickup, ePutDown, eForkTaken, eForkBusy {
    var pendingRequests: int; // Active pickup requests that haven't been resolved
    var consecutiveBusyCount: int; // Consecutive busy responses without any fork taken
    var totalOperations: int; // Total operations for deadlock detection
    var lastSuccessfulOperation: int; // Track when last fork was successfully taken
    
    start state Monitoring {
        entry { 
            pendingRequests = 0;
            consecutiveBusyCount = 0;
            totalOperations = 0;
            lastSuccessfulOperation = 0;
        }
        
        on ePickup do {
            pendingRequests = pendingRequests + 1;
            totalOperations = totalOperations + 1;
            print format("Fork pickup request - Pending: {0}, Total ops: {1}", 
                        pendingRequests, totalOperations);
        }
        
        on eForkTaken do {
            // Fork successfully acquired
            pendingRequests = pendingRequests - 1;
            consecutiveBusyCount = 0;
            lastSuccessfulOperation = totalOperations;
            print format("Fork acquired - Pending: {0}, Reset consecutive busy", pendingRequests);
        }
        
        on eForkBusy do {
            // Fork was busy
            pendingRequests = pendingRequests - 1;
            consecutiveBusyCount = consecutiveBusyCount + 1;
            
            print format("Fork busy - Consecutive: {0}, Pending: {1}, Gap since success: {2}", 
                        consecutiveBusyCount, pendingRequests, 
                        totalOperations - lastSuccessfulOperation);
            
            // More aggressive deadlock detection
            assert consecutiveBusyCount <= 5, 
                   format("Deadlock detected: {0} consecutive busy responses", consecutiveBusyCount);
                   
            // Alternative: detect if too many operations without progress
            assert (totalOperations - lastSuccessfulOperation) <= 15,
                   format("Deadlock detected: {0} operations without progress", 
                          totalOperations - lastSuccessfulOperation);
        }
        
        on ePutDown do {
            // Fork released - this indicates progress
            consecutiveBusyCount = 0;
            lastSuccessfulOperation = totalOperations;
            print format("Fork released - Reset consecutive busy counter");
        }
    }
}