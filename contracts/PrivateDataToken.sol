// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol';
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ImageID} from "./ImageID.sol"; // auto-generated contract after running `cargo build`.

contract PrivateDataToken is ERC1155, AccessControl, ERC1155Burnable {
    
    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;
    
    /// @notice Image ID of the only zkVM binary to accept verification from.
    ///         The image ID is similar to the address of a smart contract.
    ///         It uniquely represents the logic of that guest program,
    ///         ensuring that only proofs generated from a pre-defined guest 
    ///         program are considered valid.
    bytes32 public constant imageId = ImageID.IS_EVEN_ID;
    
    mapping(address dataProcessor => bytes32 idTreeRoot)
        public dataProcessorRegistry;

    error DPHasRegistered(address dataProcessor, bytes32 idTreeRoot);
    error DPNotRegistered(address dataProcessor);

    /// @param _verifier is a deployed RiscZero verifier on chain
    constructor(IRiscZeroVerifier _verifier) ERC1155('PDTK') {
        verifier = _verifier;
    }

    /**
     * @dev storing the idTreeRoot into register mapping
     * @param idTreeRoot the id tree root of data processor (using keccak256)
     */
    function dpRegister(bytes32 idTreeRoot) public {
        if (dataProcessorRegistry[msg.sender] != bytes32(0)) {
            revert DPHasRegistered(
                msg.sender,
                dataProcessorRegistry[msg.sender]
            );
        }
        dataProcessorRegistry[msg.sender] = idTreeRoot;
    }

    /**
     * @dev set cid of data owner's data
     * @param cid the content identifier of ciphertext stored in ipfs
     */
    // url https://their.url/${id}.json
    function setURI(string memory cid) public {
        _setURI(cid);
    }

    /**
     * @dev mint function for data processor
     * @param id the identifier of data owner
     * @param data 123
     */
    function mint(
        uint256 id,
        bytes memory data,
        uint256 _journal,
        bytes calldata seal
    ) public {
        /// before minting the token, we would have to check the result + merkle proof is correct or not
        bytes memory journal = abi.encode(_journal);
        verifier.verify(seal, imageId, sha256(journal));
        _mint(msg.sender, id, 1, data);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
