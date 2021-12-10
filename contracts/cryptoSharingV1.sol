// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/cryptosharing/ERCX/blob/main/contracts/interface/IERCX.sol";
import "./interface/IERC20.sol";
import "./interface/ICryptoSharingV1.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Holder.sol";


contract cryptoSharingV1 is ICryptoSharingV1 , ERC721Holder, ERC721Enumerable{
    
    address public token;
    
    mapping( uint256 => uint256) private _prices;
    
    mapping( uint256 => uint256) private _rentTime;
    
    mapping( uint256 => uint256) private _maxRentTime;
    
    mapping( uint256 => bool) private _rentLock;
    
    mapping( address => uint256) private _reserve;
    
    address immutable public factory;
    
    address public NFTAddress;
    
    constructor () {
 
        factory = msg.sender;
        
    }

    function setMaxRentTime(uint256 tokenId,uint256 time) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        _maxRentTime[tokenId] = time;
    }

    function setRentLock(uint256 tokenId,bool lock) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        _rentLock[tokenId] = lock;
    }

    function setPrice(uint256 tokenId,uint256 price) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        _prices[tokenId] = price;
    }

    function getPrice(uint tokenId) public view returns(uint){
        return _prices[tokenId];
    }

    function getRentTime(uint tokenId) public view returns(uint){
        return _rentTime[tokenId];
    }

    function getRentLock(uint tokenId) public view returns(bool){
        return _rentLock[tokenId];
    }

    function getReserve(address to) public view returns(uint){
        return _reserve[to];
    }

    function getMaxRentTime(uint tokenId) public view returns(uint){
        return _maxRentTime[tokenId];
    }
    
    function initialize(address _nftAddress, address _token) external{
        require(msg.sender == factory ," FORBIDDEN");
        NFTAddress = _nftAddress;
        token = _token;
    }
    
    function lendNFT(uint256 tokenId,uint256 maxRentTime,uint256 price) public {
        _rentLock[tokenId] = false;
        _prices[tokenId] = price;
        _maxRentTime[tokenId] = maxRentTime;
        _rentTime[tokenId] = block.timestamp;
        super._mint(msg.sender , tokenId);
        IERC721(NFTAddress).safeTransferFrom(msg.sender,address(this),tokenId);
        emit LENDNFT(msg.sender,tokenId,maxRentTime,price);
    }
    
    function withdrawBalance(uint256 amount) external{
        require(amount <= _reserve[msg.sender],"Insuff amount");
        _reserve[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender,amount);
    }
    
    function rentNFT(uint256 tokenId,uint256 time) external {
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
        require(_rentLock[tokenId] == false,"NFT is lock");
        require(time > _rentTime[tokenId],"ERROR time");
        require(time < _maxRentTime[tokenId] ,"ERROE Time");
        require(_maxRentTime[tokenId] > block.timestamp,"ERROR maxtime");
        _rentTime[tokenId] = time;
        uint256 cur_price = (time - block.timestamp) * _prices[tokenId];
        _reserve[ownerOf(tokenId)] += cur_price;
        IERC20(token).transferFrom(msg.sender,address(this),cur_price);
        IERC9999(NFTAddress).safeTransferUserFrom(address(this),msg.sender,tokenId);
        emit RENTNFT(msg.sender,tokenId,time);
    }
    
    function withdrawNFT(uint256 tokenId) external{
        require(_isApprovedOrOwner(_msgSender(),tokenId),"");
        require(block.timestamp > _rentTime[tokenId],"The NFT is Renting");
        super._burn(tokenId);
        IERC721(NFTAddress).safeTransferFrom(address(this),msg.sender,tokenId);
    }
    
}
