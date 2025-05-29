# P-Dining-Philosophers

## Overview and Problem Description

The Dining Philosophers problem is a classic synchronization problem in computer science that demonstrates the challenges of resource allocation and deadlock prevention in concurrent systems. Five philosophers sit around a circular table with five forks between them. Each philosopher alternates between thinking and eating. To eat, a philosopher must acquire both adjacent forks (left and right). The challenge is to design a protocol that allows philosophers to eat without creating deadlock or starvation.

This project implements the Dining Philosophers problem using the P programming language and demonstrates both a deadlock-prone version and a deadlock-free solution.

## Architecture
Include a placeholder so that I can include a graph explaining the system.

**System Components:**
- **Philosophers (Philo)**: 5 state machines representing philosophers who think and eat
- **Forks (Fork)**: 5 state machines representing shared resources (forks)
- **Main**: Controller that initializes the system
- **DeadlockDetection**: Specification that monitors for deadlock conditions

**Communication:**
- `ePickup`: Philosopher requests a fork
- `eForkTaken`: Fork confirms acquisition
- `eForkBusy`: Fork denies request (already taken)
- `ePutDown`: Philosopher releases a fork

## The Process

1. **Initialization**: Main creates 5 forks and 5 philosophers, each with references to their left and right forks
2. **Philosopher Lifecycle**:
   - **Thinking**: Initial state, then automatically attempts to eat
   - **TryLeftFork**: Requests left fork first
   - **TryRightFork**: After acquiring left fork, requests right fork
   - **Eating**: When both forks acquired, eats then releases both forks
3. **Fork Management**: Each fork can be in Available or Taken state
4. **Deadlock Monitoring**: DeadlockDetection spec tracks consecutive busy responses and operations without progress

## Problem Variants

### Deadlock Situation (BUG)
The current implementation in this repository demonstrates the **incorrect solution** that suffers from deadlock. The bug occurs in the `TryRightFork` state of the Philosopher machine:

```p
on eForkBusy do {
    // DEADLOCK VERSION: Don't release left fork, just wait/retry
    print format("Philosopher {0} waiting for right fork (holding left)", id);
    send rightFork, ePickup; // Keep trying without releasing left fork
}
```

**Deadlock Scenario:**
1. All 5 philosophers simultaneously acquire their left forks
2. All then try to acquire their right forks (which are held by the next philosopher)
3. All receive `eForkBusy` responses but don't release their left forks
4. System enters circular wait - each philosopher holds one resource and waits for another

**P Checker Detection:**
The `DeadlockDetection` specification detects this deadlock through:
- Monitoring consecutive `eForkBusy` responses (threshold: 5)
- Tracking operations without progress (threshold: 15 operations)

When deadlock occurs, the assertion fails with:
```
"Deadlock detected: X consecutive busy responses"
```

### No Bugs Situation
The corrected solution would modify the `TryRightFork` state to implement deadlock prevention:

```p
on eForkBusy do {
    send leftFork, ePutDown; // Release left fork if right fork is busy
    goto Thinking;
}
```

This prevents circular wait by ensuring philosophers release acquired resources when they cannot obtain all required resources, eliminating the deadlock condition. The same `DeadlockDetection` specification should pass without assertion failures in the corrected version.

## Project Details

### Structure
```
P-DiningPhilosophers/
├── PSrc/
│   ├── main.p          # Main controller and event definitions
│   ├── philo.p         # Philosopher state machine (deadlock version)
│   └── fork.p          # Fork state machine
├── PSpec/
│   └── deadlock.p      # Deadlock detection specification
└── ReadME.md           # This file
```

### How to Run the P Checker

1. **Install P Language**: Ensure P language runtime is installed on your system

2. **Compile and Test**:
   ```bash
   # Navigate to project directory
   cd P-DiningPhilosophers
   
   # Run P checker with deadlock detection
   p compile PSrc/main.p
   p test PSrc/main.p
   ```

3. **Expected Output**:
   - **Deadlock Version**: Assertion failure with deadlock detection message
   - **Corrected Version**: All tests pass, no deadlock detected

4. **Verbose Output** (optional):
   ```bash
   p test PSrc/main.p -v
   ```
   This shows detailed state transitions and print statements for debugging.

**Key Testing Points:**
- The test configuration in `main.p` uses `assert DeadlockDetection` to ensure the specification is checked
- The deadlock detection spec monitors all fork-related events across all philosophers
- Successful deadlock detection demonstrates P's capability for formal verification of concurrent systems