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
        }
        
        on eStartEating goto TryLeftFork;
    }
    
    state TryLeftFork {
        entry {
            print format("Philosopher {0} wants to eat, trying to pick the left fork", id);
            send leftFork, ePickup;
        }
        
        on eForkTaken goto TryRightFork;
        on eForkBusy goto Thinking;
    }

    state TryRightFork {
        entry {
            print format("Philosopher {0} acquired left fork, now trying right fork", id);
            send rightFork, ePickup;
        }

        on eForkTaken goto Eating;
        on eForkBusy do {
            send leftFork, ePutDown; // Release left fork if right fork is busy
            goto Thinking;
        }
    }

    state Eating {
        entry {
            print format("Philosopher {0} is eating", id);
        }
        
        on eFinishEating do {
            send leftFork, ePutDown;
            send rightFork, ePutDown;
            goto Thinking;
        }
    }
}