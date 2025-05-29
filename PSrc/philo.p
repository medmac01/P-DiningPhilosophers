machine Philo {
    var id: int;
    var leftFork: machine;
    var rightFork: machine;
    
    start state Init {
        entry (payload: (id: int, left: machine, right: machine)) {
            id = payload.id;
            leftFork = payload.left;
            rightFork = payload.right;
            print format("Philosopher {0} initialized with ID {1}", id, id);
            goto Thinking;
        }
    }

    state Thinking {
        entry {
            print format("Philosopher {0} is thinking", id);
            // Automatically try to eat after thinking (this will cause deadlock)
            goto TryLeftFork;
        }
    }
    
    state TryLeftFork {
        entry {
            print format("Philosopher {0} wants to eat, trying to pick the left fork", id);
            send leftFork, ePickup;
        }
        
        on eForkTaken goto TryRightFork;
        on eForkBusy goto Thinking; // Try again later
    }

    state TryRightFork {
        entry {
            print format("Philosopher {0} acquired left fork, now trying right fork", id);
            send rightFork, ePickup;
        }

        on eForkTaken goto Eating;
        on eForkBusy do {
            // DEADLOCK VERSION: Don't release left fork, just wait/retry
            print format("Philosopher {0} waiting for right fork (holding left)", id);
            send rightFork, ePickup; // Keep trying without releasing left fork
        }
    }

    state Eating {
        entry {
            print format("Philosopher {0} is eating", id);
            // Automatically finish eating to continue simulation
            send leftFork, ePutDown;
            send rightFork, ePutDown;
            goto Thinking;
        }
    }
}