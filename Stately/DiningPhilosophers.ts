import { createMachine, assign } from 'xstate';
interface Context {retries: number;}
const Fork = createMachine<Context>({
        id: "Fork",
        initial: "Available", 
        states: {
            Available: {
                on: {
                    ePickup : { target: [
                        "Taken",
                        ]
                    },
                    ePutDown : { target: [
                        ]
                    },
                }
            },
            Taken: {
                on: {
                    ePutDown : { target: [
                        "Available",
                        ]
                    },
                    ePickup : { target: [
                        ]
                    },
                }
            }
        }
});
const Main = createMachine<Context>({
        id: "Main",
        initial: "Init", 
        states: {
            Init: {
            }
        }
});
const Philo = createMachine<Context>({
        id: "Philo",
        initial: "Init", 
        states: {
            Init: {
                always: [
                { target: [
                    "Thinking",
                    ]
                }
                ],
            },
            Thinking: {
                always: [
                { target: [
                    "TryLeftFork",
                    ]
                }
                ],
            },
            TryLeftFork: {
                on: {
                    eForkTaken : { target: [
                        "TryRightFork",
                        ]
                    },
                    eForkBusy : { target: [
                        "TryLeftFork",
                        ]
                    },
                }
            },
            TryRightFork: {
                on: {
                    eForkTaken : { target: [
                        "Eating",
                        ]
                    },
                    eForkBusy : { target: [
                        "TryRightFork",
                        ]
                    },
                }
            },
            Eating: {
                always: [
                { target: [
                    "Thinking",
                    ]
                }
                ],
            }
        }
});
const Main_NODL = createMachine<Context>({
        id: "Main_NODL",
        initial: "Init", 
        states: {
            Init: {
            }
        }
});
