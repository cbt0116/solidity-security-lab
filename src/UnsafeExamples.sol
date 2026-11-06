// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Deliberately unsafe teaching example. Never deploy.
contract UnsafeWithdraw {
    mapping(address => uint256) public credit;
    function deposit() external payable { credit[msg.sender] += msg.value; }
    function withdraw() external {
        uint256 amount = credit[msg.sender];
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "send failed");
        credit[msg.sender] = 0; // State update occurs too late.
    }
    receive() external payable {}
}

// Safer checks-effects-interactions ordering for a basic example.
contract SaferWithdraw {
    mapping(address => uint256) public credit;
    function deposit() external payable { credit[msg.sender] += msg.value; }
    function withdraw() external {
        uint256 amount = credit[msg.sender];
        require(amount > 0, "nothing to withdraw");
        credit[msg.sender] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "send failed");
    }
    receive() external payable {}
}
