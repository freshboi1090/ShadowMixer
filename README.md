 ShadowMixer
ShadowMixer is a privacy-preserving Ethereum smart contract designed to break on-chain links between depositors and withdrawers. It uses zk-SNARKs, Merkle trees, and nullifier hashing to allow anonymous withdrawals after fixed-amount deposits — with support for gasless relayer flows and pluggable ERC-20 support.

✨ Features
🔐 Zero-Knowledge Proofs: Anonymous withdrawals via zk-SNARKs

🌲 Merkle Tree: On-chain commitments with root validation

🛡️ Double-Spend Protection: Enforced via nullifier hashing

⚡ Gasless Withdrawals: Optional relayer pattern support

💸 ETH + ERC-20 Compatible: Supports configurable token types

📦 Auditable Proof Flow: Based on proven Tornado Cash architecture

🧠 How It Works
Deposit: A user sends a fixed amount (e.g., 0.1 ETH) along with a hash of a secret note.

Merkle Tree: The note is inserted into a Merkle tree on-chain.

Generate Proof: Off-chain, the user generates a zk-SNARK that proves ownership of a note in the tree without revealing which one.

Withdraw: The user (or a relayer) submits the zk-SNARK proof and receives the funds anonymously.

🧱 Contract Structure
bash
Copy
Edit
/contracts
  ├── ShadowMixer.sol            # Main mixer logic (deposit, withdraw)
  ├── Verifier.sol               # zk-SNARK proof verifier (auto-generated)
  └── interfaces/
        └── IERC20Minimal.sol    # Token interface for ERC-20 compatibility
⚙️ Setup & Deployment
Prerequisites
Node.js

Hardhat

Circom

snarkjs

Installation
bash
Copy
Edit
git clone https://github.com/yourhandle/shadowmixer.git
cd shadowmixer
npm install
Compile & Deploy
bash
Copy
Edit
npx hardhat compile
npx hardhat run scripts/deploy.js --network goerli
🔐 Circuit Setup (ZK)
Circuits are required to generate zk-proofs for deposits/withdrawals.

bash
Copy
Edit
cd circuits
circom mixer.circom --r1cs --wasm --sym
snarkjs groth16 setup mixer.r1cs powersOfTau28_hez_final.ptau mixer_0000.zkey
snarkjs zkey contribute mixer_0000.zkey mixer_final.zkey
snarkjs zkey export verificationkey mixer_final.zkey verification_key.json
✍️ Usage (Example Flow)
User generates a note:

ts
Copy
Edit
const secret = randomBytes(32)
const nullifier = randomBytes(32)
const commitment = poseidonHash([secret, nullifier])
User deposits to the contract:

solidity
Copy
Edit
shadowMixer.deposit(commitment);
User (or relayer) withdraws with proof:

solidity
Copy
Edit
shadowMixer.withdraw(proof, root, nullifierHash, recipient, relayer, fee, refund);
🧪 Tests
bash
Copy
Edit
npx hardhat test
Test coverage includes:

✅ Valid/invalid zk-SNARK proof tests

🔁 Replay attack prevention via nullifier hash

🌲 Merkle root validation

🧪 Gasless relayer simulation

🛡️ Security Considerations
Reentrancy protection is implemented (nonReentrant)

zk-SNARK verifier is auto-generated from a trusted setup

Contract accepts only fixed denominations to preserve anonymity set

Nullifier hash mapping ensures proofs are one-time use only

