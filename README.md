# P-Dining-Philosophers

## Overview and Problem Description

The Dining Philosophers problem is a classic synchronization problem in computer science that demonstrates the challenges of resource allocation and deadlock prevention in concurrent systems. Five philosophers sit around a circular table with five forks between them. Each philosopher alternates between thinking and eating. To eat, a philosopher must acquire both adjacent forks (left and right). The challenge is to design a protocol that allows philosophers to eat without creating deadlock or starvation.

This project implements the Dining Philosophers problem using the P programming language and demonstrates both a deadlock-prone version and a deadlock-free solution.

## Architecture

**System Components:**
- **Philosophers (Philo)**: 5 state machines representing philosophers who think and eat (can be n philosophers)
- **Forks (Fork)**: 5 state machines representing shared forks (can be n forks)
- **Main**: Controller that initializes the system (deadlock version)
- **Main_NODL**: Controller for the deadlock-free version
- **DLDetection**: Specification that monitors for deadlock conditions by tracking fork ownership

**Communication:**
- `ePickup`: Philosopher requests a fork
- `eForkTaken`: Fork confirms acquisition
- `eForkBusy`: Fork denies request (already taken)
- `ePutDown`: Philosopher releases a fork
- `eStartEating`: Event for eating state transitions
- `eFinishEating`: Event for finishing eating state transitions

## Stately.ai visualization
below is a table of visualizations of the machines in this project, generated using Stately.ai.
| Machine | Visualization |
| --- | --- |
| Fork | ![Fork Visualization](https://raw.githubusercontent.com/medmac01/P-DiningPhilosophers/main/Visualizations/Fork.png) |
| Philosopher | ![Philosopher Visualization](https://raw.githubusercontent.com/medmac01/P-DiningPhilosophers/main/Visualizations/Philosopher.png) |

## The Process

1. **Initialization**: Main creates 5 forks and 5 philosophers, each with references to their left and right forks
2. **Philosopher Lifecycle**:
   - **Init**: Receives fork assignments and philosopher ID
   - **Thinking**: Initial thinking state, then automatically attempts to eat by invoking `TryLeftFork`
   - **TryLeftFork**: Requests left fork first, retries if busy
   - **TryRightFork**: After acquiring left fork, requests right fork, retries if busy
   - **Eating**: When both forks acquired, eats then releases both forks and returns to thinking
3. **Fork Management**: Each fork alternates between Available and Taken states. A fork can only be taken if it is available, otherwise it responds with `eForkBusy`. Also, only the philosopher who holds the fork can release it.
4. **Deadlock Detection**: The `DLDetection` specification monitors the system for deadlock conditions by tracking which philosophers hold forks and asserting when all philosophers are waiting for forks, in other words, when all philosophers are holding exactly one fork and waiting for another.

## Prerequisites

1. **Install P Language**: Ensure P language runtime is installed on your system

2. **Compile the Project**:
   ```bash
   # Navigate to project directory
   cd P-DiningPhilosophers

   # Compile the project
   p compile
   ```
   This generates the necessary binaries in the `PGenerated` folder.

## Problem Variants

### Deadlock Situation (Buggy Implementation 🐞)
The current implementation in `main_dl.p` demonstrates the **deadlock-prone version**. The bug occurs when all philosophers attempt to acquire their left forks simultaneously, leading to a circular wait condition.

**Deadlock Scenario:**
1. All 5 philosophers simultaneously acquire their left forks
2. All then try to acquire their right forks (which are held by the next philosopher)
3. All receive `eForkBusy` responses but don't release their left forks
4. System enters circular wait - each philosopher holds one resource and waits for another

**P Checker Detection:**
The `DLDetection` specification detects this deadlock by:
- Tracking philosophers holding forks in a set (`philoForks`)
- Asserting that not all philosophers are simultaneously holding forks
- When deadlock occurs: `assert sizeof(philoForks) < numPhilosophers, "Deadlock detected: All philosophers are holding the left fork and waiting for each other"`

**P Checker Command:**
```bash
p check -tc DeadLockImpl -s 10
```
**Expected Output:**
```
.. Searching for a P compiled file locally in folder ./PGenerated/
.. Found a P compiled file: ./PGenerated/CSharp/net8.0/DiningPhilosophers.dll
.. Checking ./PGenerated/CSharp/net8.0/DiningPhilosophers.dll
.. Test case :: DeadLockImpl
... Checker is using 'random' strategy (seed:865362962).
..... Schedule #1
Checker found a bug.
... Emitting traces:
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers_0_0.txt
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers_0_0.trace.json
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers_0_0.schedule
... Elapsed 0.06 sec and used 0 GB.
... Emitting coverage report:
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers.coverage.txt
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers.sci
... Checking statistics:
..... Found 1 bug.
... Scheduling statistics:
..... Explored 1 schedule
..... Explored 1 timeline
..... Found 100.00% buggy schedules.
..... Number of scheduling points in terminating schedules: 37 (min), 37 (avg), 37 (max).
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers_pchecker_summary.txt
... Elapsed 0.0920971 sec.
. Done
~~ [PTool]: Thanks for using P! ~~
```

**Peasy Visualization:**
![Deadlock Visualization](https://raw.githubusercontent.com/medmac01/P-DiningPhilosophers/main/Visualizations/buggy.png)



### Deadlock-Free Situation (main_nodl.p)
The deadlock-free solution in `main_nodl.p` implements a prevention strategy by having one philosopher (doesn't matter which one) use reverse fork ordering:

```p
if (i == numPhilosophers - 2) {
    // One philosopher picks up in reverse order
    philosophers += (0, new Philo((id=i, left=rightFork, right=leftFork)));
}
```

This breaks the circular dependency by ensuring not all philosophers follow the same left-then-right acquisition pattern, which prevents the deadlock condition.

**Deadlock-Free P Checker Command:**
```bash
p check -tc NoDeadLockImpl -s 10
```
**Expected Output:**
```
.. Searching for a P compiled file locally in folder ./PGenerated/
.. Found a P compiled file: ./PGenerated/CSharp/net8.0/DiningPhilosophers.dll
.. Checking ./PGenerated/CSharp/net8.0/DiningPhilosophers.dll
.. Test case :: NoDeadLockImpl
... Checker is using 'random' strategy (seed:3690150366).
..... Schedule #1
..... Schedule #2
..... Schedule #3
..... Schedule #4
..... Schedule #5
..... Schedule #6
..... Schedule #7
..... Schedule #8
..... Schedule #9
..... Schedule #10
... Emitting coverage report:
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers.coverage.txt
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers.sci
... Checking statistics:
..... Found 0 bugs.
... Scheduling statistics:
..... Explored 10 schedules
..... Explored 1 timeline
..... Number of scheduling points in terminating schedules: 100000 (min), 100000 (avg), 100000 (max).
..... Exceeded the max-steps bound of '10000' in 100.00% of the fair schedules.
..... Writing PCheckerOutput/BugFinding/DiningPhilosophers_pchecker_summary.txt
... Elapsed 58.6927534 sec.
. Done
~~ [PTool]: Thanks for using P! ~~
```

## Project Details

### Structure
```
P-DiningPhilosophers/
├── PSrc/
│   ├── main_dl.p       # Main controller (deadlock version) and event definitions
│   ├── main_nodl.p     # Main controller (deadlock-free version)
│   ├── philo.p         # Philosopher state machine
│   └── fork.p          # Fork state machine
├── PSpec/
│   └── deadlock.p      # Deadlock detection specification
└── README.md           # This file
```



**Key Testing Points:**
- Two test configurations are defined: `DeadLockImpl` and `NoDeadLockImpl`
- The deadlock detection spec monitors `eForkTaken` and `ePutDown` events
- Successful deadlock detection demonstrates P's capability for formal verification of concurrent systems
- The specification uses set-based tracking rather than counters for more precise deadlock detection