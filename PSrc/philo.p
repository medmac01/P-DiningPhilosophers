machine Philo {
    var id: int;
    var leftFork: machine;
    var rightFork: machine;
    var reverseOrder: bool;
    
    start state Init {
        entry (payload: (id: int, left: machine, right: machine)) {
            id = payload.id;
            leftFork = payload.left;
            rightFork = payload.right;
            print format("Philosopher {0} initialized", id);
            goto Thinking;
        }
    }

    state Thinking {
        entry {
            print format("Philosopher {0} is thinking", id);
            goto TryLeftFork;
        }
    }
    
    state TryLeftFork {
        entry {
            print format("Philosopher {0} trying to pick up left fork", id);
            send leftFork, ePickup, (philo = this, philo_id = id);
        }
        
        on eForkTaken goto TryRightFork;  // Now get the right fork
        on eForkBusy goto TryLeftFork; // Try again later
    }

    state TryRightFork {
        entry {
            print format("Philosopher {0} trying to pick up right fork", id);
            send rightFork, ePickup, (philo = this, philo_id = id);
        }

        on eForkTaken goto Eating;  // Now can eat
        on eForkBusy goto TryRightFork; // Retry picking up right fork
    }

    state Eating {
        entry {
            print format("Philosopher {0} is eating", id);
            // Release both forks
            send leftFork, ePutDown, (philo = this, philo_id = id);
            send rightFork, ePutDown, (philo = this, philo_id = id);
            goto Thinking;
        }
    }
}