machine Fork {
    var isAvailable: bool;
    
    start state Available {
        entry {
            isAvailable = true;
        }
        
        on ePickup do (payload: (philo : machine, philo_id : int)) {
            if (isAvailable) {
                isAvailable = false;
                send payload.philo, eForkTaken, (philo = payload.philo, philo_id = payload.philo_id);
                print format("Fork taken by philosopher {0}", payload.philo_id);
                goto Taken;
            } else {
                send payload.philo, eForkBusy, (philo = payload.philo, philo_id = payload.philo_id);
            }
        }

        on ePutDown do {
            // Fork is already available, no action needed
            print "Fork is already available";
        }
    }
    
    state Taken {
        on ePutDown do {
            isAvailable = true;
            goto Available;
        }

        on ePickup do (payload: (philo : machine, philo_id : int)) {
            // If already taken, just send busy response
            send payload.philo, eForkBusy, (philo = payload.philo, philo_id = payload.philo_id);
        }
    }
}