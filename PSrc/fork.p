machine Fork {
    var isAvailable: bool;
    
    start state Available {
        entry {
            isAvailable = true;
        }
        
        on ePickup do (payload: machine) {
            if (isAvailable) {
                isAvailable = false;
                send payload, eForkTaken;
                goto Taken;
            } else {
                send payload, eForkBusy;
            }
        }
    }
    
    state Taken {
        on ePutDown do {
            isAvailable = true;
            goto Available;
        }
    }
}