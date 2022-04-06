// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault is ERC20 {
    // userAddress => stakingBalance
    mapping(address => uint256) public depositBalance;
    // userAddress => isStaking boolean
    mapping(address => bool) public isDepositor;

    IERC20 public daiToken;
    uint256 public constant exchangeRate = 1;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);

    constructor(IERC20 _daiToken) ERC20("PPTOKEN", "PP") {
        daiToken = _daiToken;
    }

    function deposit(uint256 amount) public {
        require(
            amount > 0 && daiToken.balanceOf(msg.sender) >= amount,
            "You cannot deposit zero tokens"
        );

        daiToken.transferFrom(msg.sender, address(this), amount);
        depositBalance[msg.sender] += amount;
        isDepositor[msg.sender] = true;

        uint256 lpAmount = calculateLPAmount(amount);
        amount = 0;
        _mint(msg.sender, lpAmount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(
            isDepositor[msg.sender] =
                true &&
                depositBalance[msg.sender] >= amount,
            "Nothing to withdraw"
        );

        uint256 balanceTransfer = amount;
        amount = 0;
        depositBalance[msg.sender] -= balanceTransfer;
        daiToken.transfer(msg.sender, balanceTransfer);

        uint256 burnLPAmount = calculateDaiAmount(balanceTransfer);
        _burn(msg.sender, burnLPAmount);

        if (depositBalance[msg.sender] == 0) {
            isDepositor[msg.sender] = false;
        }
        emit Withdraw(msg.sender, amount);
    }

    function calculateLPAmount(uint256 daiAmount)
        public
        pure
        returns (uint256)
    {
        uint256 lpAmount = daiAmount * exchangeRate;
        return lpAmount;
    }

    function calculateDaiAmount(uint256 lpAmount)
        public
        pure
        returns (uint256)
    {
        uint256 daiAmount = lpAmount * exchangeRate;
        return daiAmount;
    }
}
