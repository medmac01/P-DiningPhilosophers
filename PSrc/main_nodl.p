machine Main_NODL {
    var philosophers: seq[machine];
    var forks: seq[machine];
    var numPhilosophers: int;
    var leftFork: machine;
    var rightFork: machine;
    
    start state Init {
        entry {
            var i: int;
            var j: int;
            numPhilosophers = 5;
            
            // Create 5 forks
            j = 0;
            while (j < numPhilosophers) {
                forks += (0, new Fork());
                j = j + 1;
            }
            
            // Create 5 philosophers
            i = 0;
            while (i < numPhilosophers) {
                // Left fork is at index i, right fork is at index (i+1) % numPhilosophers
                leftFork = forks[i];
                rightFork = forks[(i + 1) % numPhilosophers];

                if (i == numPhilosophers - 2) {
                    // One philosopher picks up in reverse order
                    philosophers += (0, new Philo((id=i, left=rightFork, right=leftFork)));
                } else {
                    philosophers += (0, new Philo((id=i, left=leftFork, right=rightFork)));
                }
                i = i + 1;
            }

            print format("Dining philosophers simulation started with {0} philosophers and {1} forks", numPhilosophers, numPhilosophers);
        }
    }
}