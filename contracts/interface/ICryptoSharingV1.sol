// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICryptoSharingV1{

    event RENTNFT(address to,uint256 tokenId,uint256 time);

    event LENDNFT(address from,uint256 tokenId,uint256 maxRentTime,uint256 price);

    function setMaxRentTime(uint256 tokenId,uint256 time) external;

    function setRentLock(uint256 tokenId,bool lock) external;

    function setPrice(uint256 tokenId,uint256 price) external;

    function getPrice(uint tokenId) external view returns(uint);

    function getRentTime(uint tokenId) external view returns(uint);

    function getRentLock(uint tokenId) external view returns(bool);

    function getReserve(address to) external view returns(uint);

    function getMaxRentTime(uint tokenId) external view returns(uint);
    
    function initialize(address _nftAddress, address _token) external;
    
    function lendNFT(uint256 tokenId,uint256 maxRentTime,uint256 price) external ;
    
    function withdrawBalance(uint256 amount) external;

    function rentNFT(uint256 tokenId,uint256 time) external ;
    
    function withdrawNFT(uint256 tokenId) external;
    
}
