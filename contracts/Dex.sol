// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error Dex__AddressCannotBeZero();
error Dex__AmountCannotBeZero();

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

        // when our pool already has some reserve
        // calculating token amount using ratio of amm 
        uint256 ethReserveBefore = ethReserve - msg.value;
        uint256 minTokenAmount = (msg.value * tokenReserve) / ethReserveBefore;
        require(amount >= minTokenAmount);
        // user sends token to this contract (with minimum amount calculated)
        _token.transferFrom(msg.sender, address(this), minTokenAmount);
        poolTokenToMint = (totalSupply() * msg.value) / ethReserveBefore;
        // sender gets pool token in return
        _mint(msg.sender, poolTokenToMint);
        return poolTokenToMint;
    }

    function removeLiquidity(uint256 amountPT) external returns (uint256, uint256) {
        if(amountPT == 0) {
            revert Dex__AmountCannotBeZero();
        }

        uint256 ethReserve = address(this).balance;
        uint256 ptSupply = totalSupply();

        uint256 returnEth = (ethReserve * amountPT) / ptSupply;
        uint returnToken = (ERC20(token).balanceOf(address(this)) * amountPT) / ptSupply;

        // burning pool token 
        // and sending ether, token to msg.sender
        _burn(msg.sender, amountPT);
        (bool success, ) = payable(msg.sender).call{value: returnEth}("");
        require(success);
        ERC20(token).transfer(msg.sender, returnToken);

        return (returnEth, returnToken);
    } 

    function ethToTokenSwap(uint256 minToken) external payable {
        uint256 tokenReserve = ERC20(token).balanceOf(address(this));
        uint256 tokenToRecieve = getOutput(msg.value, address(this).balance, tokenReserve);
        require(tokenToRecieve >= minToken);
        ERC20(token).transfer(_msgSender(), tokenToRecieve); 
    }

    function tokenToEthSwap(uint256 tokensToSwap, uint256 minEth) public {
        uint256 tokenBalance = ERC20(token).balanceOf(address(this));
        uint256 ethToReceive = getOutput(tokensToSwap, tokenBalance, address(this).balance);
        require(ethToReceive >= minEth);
        ERC20(token).transferFrom(msg.sender, address(this), tokensToSwap);
        (bool success, ) = payable(msg.sender).call{value: ethToReceive}("");
        require(success);
    }

    function getOutput(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0);
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 n = inputAmountWithFee * outputReserve;
        uint256 d = (inputReserve * 100) + inputAmountWithFee;
        return n / d;
    }

}   