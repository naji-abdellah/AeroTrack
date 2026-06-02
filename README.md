# ✈️ AeroTrack — Airplane Spare Parts Provenance on Ethereum

> Securing aviation supply chains using immutable, decentralized smart contracts.

---

## 📌 Overview

**AeroTrack** is an Ethereum smart contract built in Solidity that tracks the full lifecycle of airplane spare parts on the blockchain. From the moment a part rolls off the manufacturing line, through ownership transfers between airlines and maintenance facilities, to its final decommissioning — every action is cryptographically secured and permanently recorded.

This project was developed as part of the **Industrial Blockchain Laboratory** course, demonstrating how blockchain technology can eliminate the single points of failure in traditional aviation supply chains (paper certificates, centralized databases, forgeable records).

---

## 🚨 The Problem

Traditional aviation supply chains rely on:
- Paper-based certificates (EASA Form 1, FAA 8130-3) — susceptible to forgery
- Centralized databases — vulnerable to manipulation and data loss
- Manual ownership tracking — error-prone and opaque

A single counterfeit or poorly maintained part can compromise an entire aircraft.

---

## ✅ The Solution

AeroTrack provides:
- **Immutability** — once recorded, part history cannot be altered
- **Transparency** — any authorized party can verify a part's provenance
- **Decentralization** — no single point of failure or central authority
- **Role-Based Access Control** — only verified owners can modify part data
- **Cheap auditability** — maintenance history stored as blockchain events, not expensive storage

---

## 🏗️ Contract Architecture

### Data Structures

```solidity
enum PartStatus { Manufactured, InTransit, Installed, Retired }

struct Part {
    uint256 serialNumber;
    string  partName;
    address manufacturer;
    address currentOwner;
    PartStatus status;
    bool exists;
}

mapping(uint256 => Part) public parts;
```

### Access Control Modifiers

| Modifier | Protection |
|---|---|
| `onlyAuthority` | Restricts actions to the regulatory authority (FAA/EASA) |
| `partExists` | Reverts calls on unregistered serial numbers |
| `onlyPartOwner` | Ensures only the current owner can transfer or maintain a part |

### Core Functions

| Function | Description |
|---|---|
| `manufacturePart(serialNumber, partName)` | Registers a new part; caller becomes manufacturer and initial owner |
| `transferPart(serialNumber, newOwner)` | Transfers ownership; updates status to InTransit |
| `logMaintenance(serialNumber, report)` | Logs a maintenance report; updates status to Installed |

### Events

```solidity
event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
```

---

## 🚀 Getting Started

### Prerequisites
- [Remix IDE](https://remix.ethereum.org/) — no installation needed, runs in your browser
- OR [Node.js](https://nodejs.org/) + [Hardhat](https://hardhat.org/) for local development

### Deploy in Remix IDE

1. Go to [https://remix.ethereum.org](https://remix.ethereum.org)
2. Create a new file: `AeroTrack.sol`
3. Paste the contract code from [`contracts/AeroTrack.sol`](contracts/AeroTrack.sol)
4. Go to the **Solidity Compiler** tab → select version `0.8.19` → click **Compile**
5. Go to the **Deploy & Run** tab → Environment: `Remix VM` → click **Deploy**

---

## 🧪 Testing the Supply Chain

Once deployed, simulate the full lifecycle using multiple Remix accounts:

### 1. Manufacture a Part (Account 1 — Manufacturer)
```
Function: manufacturePart
_serialNumber: 999
_partName: "Boeing 737 Landing Gear"
```

### 2. Verify State
```
Function: parts
Input: 999
Expected: currentOwner = Account 1, status = 0 (Manufactured), exists = true
```

### 3. Test Access Control — Hacking Attempt (Account 3)
```
Function: transferPart
_serialNumber: 999
_newOwner: Account 3's address
Expected: REVERT — "Not the owner."
```

### 4. Legitimate Transfer (Account 1 → Account 2)
```
Function: transferPart
_serialNumber: 999
_newOwner: Account 2's address
Expected: OwnershipTransferred event emitted, status = 1 (InTransit)
```

### 5. Log Maintenance (Account 2 — Airline)
```
Function: logMaintenance
_serialNumber: 999
_report: "10,000 hour inspection passed. No fatigue detected."
Expected: MaintenanceLogged event emitted, status = 2 (Installed)
```

---

## 📊 Transaction Summary

| Block | Action | Actor | Result |
|---|---|---|---|
| 1 | Contract deployed | Account 1 | `regulatoryAuthority` set |
| 2 | `manufacturePart(999, ...)` | Account 1 | `PartManufactured` event emitted |
| 3 | Unauthorized `transferPart` | Account 3 | ❌ Reverted — "Not the owner." |
| 4 | `transferPart(999, Account 2)` | Account 1 | `OwnershipTransferred` event emitted |
| 5 | `logMaintenance(999, ...)` | Account 2 | `MaintenanceLogged` event emitted |

---

## 🔮 Future Enhancements

- **Decentralized Identifiers (DIDs)** — cryptographically prove that a manufacturer address belongs to a certified entity (Boeing, Airbus)
- **IoT Oracles** — allow physical sensors on airplane parts to automatically trigger `logMaintenance` when stress or wear is detected
- **Upgradable Proxy Pattern** — enable regulatory updates (FAA rule changes) without losing historical part data
- **Part Retirement** — add a `retirePart` function and restrict further actions on `Retired` parts

---

## 🛠️ Built With

- [Solidity 0.8.19](https://docs.soliditylang.org/)
- [Ethereum](https://ethereum.org/)
- [Remix IDE](https://remix.ethereum.org/)

---

## 👤 Author

**Naji Abdellah**
Industrial Blockchain Laboratory — June 2026

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
