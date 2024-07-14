use std::io::Read;

use alloy_primitives::U256;
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

fn main() {
    // inputs: 
    // 1. ACP provided by Data Processor
    // 2. uid of the user
    //    * ACP Tree
    //    * ACP Merkle Root


    
    // TODO: 1. Read the inputs from env buffer
    // read the inputs from env buffer
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).unwrap();

    // TODO: 2. Parse the inputs to what we want
    // Decode and parse the input
    let number = <U256>::abi_decode(&input_bytes, true).unwrap();

    // TODO: 3. Building the merkle tree from ACP
    // TODO: 4. Query the MTR from db
    // TODO: 5. Assert the MTR with the calculated MTR
    // TODO: 6. Output with journal and MTR

    // Commit the journal that will be received by the application contract.
    // Journal is encoded using Solidity ABI for easy decoding in the app contract.
    env::commit_slice(number.abi_encode().as_slice());
}
