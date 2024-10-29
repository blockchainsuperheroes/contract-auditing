pragma solidity ^0.8.22;

abstract contract IERC677Receiver {
    function onTokenTransfer(
        address _sender,
        uint256 _value,
        bytes memory _data
    ) public virtual;
}