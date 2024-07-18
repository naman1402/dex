// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error Dex__AddressCannotBeZero();

contract Dex is ERC20{

    address public token;

    constructor(address _token) ERC20("PoolToken", "PLT"){
        if(_token==address(0)) {
            revert Dex__AddressCannotBeZero();
        }
        token = _token;
    }

    function addLiquidity(uint256 amount) external payable returns(uint) {

        uint256 poolTokenToMint;
        uint256 tokenReserve = ERC20(token).balanceOf(address(this));
        uint256 ethReserve = address(this).balance;

        ERC20 _token = ERC20(token);

        if (tokenReserve == 0) {
            _token.transferFrom(msg.sender, address(this), amount);
            poolTokenToMint = ethReserve;
            // msg.sender sends token to this contract and gets poolToken minted (contract has no TOKEN)
            // poolToken is minted
            _mint(msg.sender, poolTokenToMint);
            return poolTokenToMint;
        } 

        uint256 ethReserveBefore = ethReserve - msg.value;
        uint256 minTokenAmount = (msg.value * tokenReserve) / ethReserveBefore;
        require(amount >= minTokenAmount);

        _token.transferFrom(msg.sender, address(this), minTokenAmount);
        poolTokenToMint = (totalSupply() * msg.value) / ethReserveBefore;

        _mint(msg.sender, poolTokenToMint);
        return poolTokenToMint;
    }

}   