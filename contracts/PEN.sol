import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./shared/BasicAccessControl.sol";
import "./Freezable.sol";
import "./interface/IERC677Receiver.sol";

contract PEN is
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    Freezable,
    BasicAccessControl
{
    mapping(address => bool) public transferable;

    bool public isTransferable = false;

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    constructor() ERC20("Pentagon", "PEN") ERC20Permit("Pentagon") {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function toggleIsTransferable() public onlyOwner {
        isTransferable = !isTransferable;
    }

    function addTransferable(address _transferable) external onlyOwner {
        transferable[_transferable] = true;
    }

    function removeTransferable(address _transferable) external onlyOwner {
        transferable[_transferable] = false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(
            moderators[_msgSender()] || isTransferable,
            "Cannot transfer to the provided address"
        );
        require(!isFrozen(from), "ERC20Freezable: from account is frozen");
        require(!isFrozen(to), "ERC20Freezable: to account is frozen");
    }

    function freeze(address _account) public onlyModerators {
        freezes[_account] = true;
        emit Frozen(_account);
    }

    function unfreeze(address _account) public onlyModerators {
        freezes[_account] = false;
        emit Unfrozen(_account);
    }

    /* /////////////////////////////
     ** ERC677 Transfer and call
     ** /////////////////////////////
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data
    );

    /**
     * @dev transfer token to a contract address with additional data if the recipient is a contact.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     * @param _data The extra data to be passed to the receiving contract.
     */
    function transferAndCall(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public returns (bool success) {
        if (isContract(_to)) {
            IERC677Receiver receiver = IERC677Receiver(_to);
            receiver.onTokenTransfer(msg.sender, _value, _data);
        }

        transfer(_to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function isContract(address _addr) private view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}
