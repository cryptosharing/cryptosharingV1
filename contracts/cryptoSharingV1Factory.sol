// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './cryptoSharingV1.sol';
import './interface/ICryptoSharingV1.sol';

contract cryptoSharingV1Factory {

    mapping(address => mapping(address => address)) public getRentPool;

    address[] public allRentPool;

    event RentPoolCreated(address indexed token0, address indexed token1, address pair, uint);

    function allPairsLength() external view returns (uint) {
        return allRentPool.length;
    }

    function createRentPool(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'cryptoSharingV1: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'cryptoSharingV1: ZERO_ADDRESS');
        require(getRentPool[token0][token1] == address(0), 'cryptoSharingV1: RENTPOOL_EXISTS');
        bytes memory bytecode = type(cryptoSharingV1).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ICryptoSharingV1(pair).initialize(token0, token1);
        getRentPool[token0][token1] = pair;
        getRentPool[token1][token0] = pair;
        allRentPool.push(pair);
        emit RentPoolCreated(token0, token1, pair, allRentPool.length);
    }
}
