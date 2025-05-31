# P-Dining-Philosophers

## Overview and Problem Description

The Dining Philosophers problem is a classic synchronization problem in computer science that demonstrates the challenges of resource allocation and deadlock prevention in concurrent systems. Five philosophers sit around a circular table with five forks between them. Each philosopher alternates between thinking and eating. To eat, a philosopher must acquire both adjacent forks (left and right). The challenge is to design a protocol that allows philosophers to eat without creating deadlock or starvation.

This project implements the Dining Philosophers problem using the P programming language and demonstrates both a deadlock-prone version and a deadlock-free solution.

## Architecture

**System Components:**
- **Philosophers (Philo)**: 5 state machines representing philosophers who think and eat
- **Forks (Fork)**: 5 state machines representing shared resources (forks)
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

## The Process

1. **Initialization**: Main creates 5 forks and 5 philosophers, each with references to their left and right forks
2. **Philosopher Lifecycle**:
   - **Init**: Receives fork assignments and philosopher ID
   - **Thinking**: Initial thinking state, then automatically attempts to eat
   - **TryLeftFork**: Requests left fork first, retries if busy
   - **TryRightFork**: After acquiring left fork, requests right fork, retries if busy
   - **Eating**: When both forks acquired, eats then releases both forks and returns to thinking
3. **Fork Management**: Each fork alternates between Available and Taken states
4. **Deadlock Monitoring**: DLDetection spec tracks philosophers holding forks and asserts when all philosophers simultaneously hold exactly one fork

## Problem Variants

### Deadlock Situation (Current Implementation)
The current implementation in `main_dl.p` demonstrates the **deadlock-prone version**. The bug occurs in the `TryRightFork` state of the Philosopher machine:

```p
on eForkBusy goto TryRightFork; // Retry picking up right fork
```

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

### Deadlock-Free Situation (main_nodl.p)
The deadlock-free solution in `main_nodl.p` implements a prevention strategy by having one philosopher (philosopher 3) use reverse fork ordering:

```p
if (i == numPhilosophers - 2) {
    // One philosopher picks up in reverse order
    philosophers += (0, new Philo((id=i, left=rightFork, right=leftFork)));
}
```

This breaks the circular dependency by ensuring not all philosophers follow the same left-then-right acquisition pattern, preventing the deadlock condition.

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

### How to Run the P Checker

1. **Install P Language**: Ensure P language runtime is installed on your system

2. **Compile and Test**:
   ```bash
   # Navigate to project directory
   cd P-DiningPhilosophers
   
   # Test deadlock version (should fail)
   p test PSrc/main_dl.p::DeadLockImpl
   
   # Test deadlock-free version (should pass)
   p test PSrc/main_dl.p::NoDeadLockImpl
   ```

3. **Expected Output**:
   - **Deadlock Version (DeadLockImpl)**: Assertion failure with deadlock detection message
   - **Deadlock-Free Version (NoDeadLockImpl)**: All tests pass, no deadlock detected

4. **Verbose Output** (optional):
   ```bash
   p test PSrc/main_dl.p::DeadLockImpl -v
   ```
   This shows detailed state transitions and print statements for debugging.

**Key Testing Points:**
- Two test configurations are defined: `DeadLockImpl` and `NoDeadLockImpl`
- The deadlock detection spec monitors `eForkTaken` and `ePutDown` events
- Successful deadlock detection demonstrates P's capability for formal verification of concurrent systems
- The specification uses set-based tracking rather than counters for more precise deadlock detection