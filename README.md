# MyGovernor DAO

A comprehensive Decentralized Autonomous Organization (DAO) built with Foundry and OpenZeppelin's governance contracts. This project demonstrates a complete governance system with token-based voting, timelock controls, and transparent proposal execution.

## Table of Contents

-   [What is a DAO?](#what-is-a-dao)
-   [Project Overview](#project-overview)
-   [Smart Contracts](#smart-contracts)
-   [Governance Process](#governance-process)
-   [Key Features](#key-features)
-   [Setup and Installation](#setup-and-installation)
-   [Usage](#usage)
-   [Testing](#testing)
-   [Deployment](#deployment)
-   [Security Considerations](#security-considerations)

## What is a DAO?

A **Decentralized Autonomous Organization (DAO)** is a blockchain-based organization that operates through smart contracts and is governed by its community members. Instead of traditional hierarchical management, DAOs use token-based voting systems where:

-   **Token holders** have voting power proportional to their token holdings
-   **Proposals** are submitted for community consideration
-   **Voting** occurs on-chain with transparent results
-   **Execution** happens automatically through smart contracts
-   **Transparency** is maintained through blockchain immutability

### Benefits of DAOs:

-   **Decentralization**: No single point of control
-   **Transparency**: All actions are recorded on-chain
-   **Global Access**: Anyone can participate regardless of location
-   **Automated Execution**: Reduces human error and bias
-   **Community-Driven**: Decisions are made collectively

## Project Overview

This DAO implementation provides a complete governance framework that allows token holders to:

1. **Propose** changes to the system
2. **Vote** on proposals using their governance tokens
3. **Execute** approved proposals after a timelock period
4. **Manage** protocol parameters and controlled contracts

The system is designed with security best practices including timelock delays, quorum requirements, and role-based access control.

## Smart Contracts

### Core Contracts

#### 1. **GovToken.sol** - Governance Token

-   **Purpose**: ERC20 token with voting capabilities
-   **Features**:
    -   Mintable governance tokens (MTK)
    -   Vote delegation system
    -   Snapshot-based voting power
    -   EIP-712 permit functionality
-   **Token Symbol**: MTK
-   **Token Name**: MyToken

#### 2. **MyGovernor.sol** - Main Governance Contract

-   **Purpose**: Handles proposal creation, voting, and execution
-   **Key Parameters**:
    -   **Voting Delay**: 1 block (proposals become active after 1 block)
    -   **Voting Period**: 50,400 blocks (~1 week assuming 15s blocks)
    -   **Quorum**: 4% of total token supply
    -   **Proposal Threshold**: 0 tokens (anyone can propose)
-   **Extensions Used**:
    -   `GovernorSettings`: Configurable voting parameters
    -   `GovernorCountingSimple`: Simple For/Against/Abstain voting
    -   `GovernorVotes`: Token-based voting power
    -   `GovernorVotesQuorumFraction`: Percentage-based quorum
    -   `GovernorTimelockControl`: Timelock integration

#### 3. **TimeLock.sol** - Timelock Controller

-   **Purpose**: Enforces delays between proposal approval and execution
-   **Security Features**:
    -   Minimum delay of 1 hour before execution
    -   Role-based access control (Proposer, Executor, Admin)
    -   Prevents immediate execution of proposals
    -   Allows community time to react to malicious proposals

#### 4. **Box.sol** - Example Governed Contract

-   **Purpose**: Demonstrates governance control over external contracts
-   **Functionality**:
    -   Stores a single number value
    -   Only the timelock can update the value
    -   Serves as a test target for governance proposals

## Governance Process

The governance process follows these steps:

### 1. **Proposal Creation**

-   Any token holder can create a proposal
-   Proposals specify target contracts, function calls, and descriptions
-   Proposals enter a "Pending" state initially

### 2. **Voting Delay**

-   1 block delay before voting becomes active
-   Prevents flash loan attacks and allows preparation time

### 3. **Active Voting Period**

-   Lasts for 50,400 blocks (~1 week)
-   Token holders vote: For (1), Against (0), or Abstain (2)
-   Voting power based on token holdings at proposal creation

### 4. **Vote Tallying**

-   Proposals need 4% quorum to be valid
-   Simple majority of participating votes needed to pass
-   Proposals can be in states: Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed

### 5. **Queueing**

-   Successful proposals must be queued in the timelock
-   Starts the mandatory delay period

### 6. **Execution**

-   After timelock delay (1 hour), proposals can be executed
-   Anyone can execute a ready proposal
-   Execution calls the specified functions on target contracts

## Key Features

### Security Features

-   **Timelock Protection**: Prevents immediate execution of proposals
-   **Quorum Requirements**: Ensures sufficient participation
-   **Role-Based Access**: Separates proposal, execution, and admin roles
-   **Snapshot Voting**: Prevents manipulation during voting period

### Governance Features

-   **Token-Based Voting**: Voting power proportional to token holdings
-   **Delegation System**: Token holders can delegate voting power
-   **Transparent Process**: All actions recorded on-chain
-   **Flexible Parameters**: Voting delays and periods can be updated

### Technical Features

-   **OpenZeppelin Integration**: Battle-tested governance contracts
-   **Foundry Testing**: Comprehensive test suite
-   **Gas Optimization**: Efficient contract design
-   **Modular Architecture**: Easy to extend and customize

## Setup and Installation

### Prerequisites

-   [Foundry](https://book.getfoundry.sh/getting-started/installation)
-   Git

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd foundry-dao

# Install dependencies
forge install

# Build the project
forge build
```

## Usage

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Test with Verbosity

```bash
forge test -vv
```

### Format Code

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

### Local Development

```bash
# Start local blockchain
anvil

# In another terminal, run tests
forge test --fork-url http://localhost:8545
```

## Testing

The project includes comprehensive tests in `test/MyGovernorTest.t.sol`:

### Test Coverage

-   **Token Deployment**: Verifies governance token functionality
-   **Governance Setup**: Tests proper initialization of all contracts
-   **Proposal Creation**: Ensures proposals can be created
-   **Voting Process**: Tests voting mechanics and power calculation
-   **Timelock Integration**: Verifies delay mechanisms
-   **Execution**: Tests proposal execution and state changes
-   **Access Control**: Ensures only authorized actions are permitted

### Key Test Scenarios

1. **Unauthorized Access**: Verifies contracts are protected
2. **Complete Governance Flow**: Tests full proposal lifecycle
3. **Edge Cases**: Handles various failure scenarios
4. **Integration**: Tests interaction between all components

### Running Tests

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testGovernanceUpdatesBox

# Run with gas reporting
forge test --gas-report
```

## Deployment

### Local Deployment

```bash
# Start Anvil (local blockchain)
anvil

# Deploy contracts (create deployment script)
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key <your-private-key> --broadcast
```

### Testnet Deployment

```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url https://sepolia.infura.io/v3/<your-key> --private-key <your-private-key> --broadcast --verify
```

## Security Considerations

### Implemented Security Measures

1. **Timelock Delays**: Prevents immediate execution of malicious proposals
2. **Quorum Requirements**: Ensures sufficient community participation
3. **Role Separation**: Limits admin privileges and distributes power
4. **Snapshot Voting**: Prevents manipulation during voting periods
5. **Access Controls**: Protects sensitive functions

### Best Practices

-   **Multi-sig Integration**: Consider using multi-signature wallets for critical roles
-   **Proposal Review**: Implement proposal review processes
-   **Emergency Procedures**: Plan for emergency governance scenarios
-   **Regular Audits**: Conduct security audits before mainnet deployment
-   **Parameter Tuning**: Adjust voting parameters based on token distribution

### Known Limitations

-   **Participation Requirements**: Low participation can lead to governance attacks
-   **Token Distribution**: Concentrated token holdings can centralize power
-   **Proposal Costs**: Gas costs may limit participation
-   **Execution Risks**: Malicious proposals can still be executed if they gain majority support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.

## Resources

-   [OpenZeppelin Governance Documentation](https://docs.openzeppelin.com/contracts/4.x/governance)
-   [Foundry Book](https://book.getfoundry.sh/)
-   [DAO Best Practices](https://github.com/blockchainsllc/DAO)
-   [Ethereum Governance Standards](https://eips.ethereum.org/eip-2535)

---

_This DAO implementation serves as a foundation for decentralized governance. Always conduct thorough testing and auditing before deploying to mainnet._

### Author: Fawarano
