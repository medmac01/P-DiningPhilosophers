spec DLDetection observes eForkTaken, ePutDown {
    var philoForks: set[machine];      // Counts how many forks each philosopher holds
    var numPhilosophers: int;
    var numForks: int;
    
    start state Init {
        entry {
            philoForks = default(set[machine]);
            numPhilosophers = 5;
            numForks = 5;
            goto Monitoring;
        }
    }
    
    state Monitoring {
        on eForkTaken do (payload: (philo: machine, philo_id: int)) {

            philoForks += (payload.philo); // Add the philosopher to the set of philosophers holding forks
            assert sizeof(philoForks) < numPhilosophers, "Deadlock detected: All philosophers are holding the left fork and waiting for each other";

        }
        
        on ePutDown do (payload: (philo: machine, philo_id: int)) {
            philoForks -= (payload.philo);
        }
    }
}