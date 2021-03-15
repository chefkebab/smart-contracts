pragma solidity 0.6.12;

import '@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol';
import "./MarsToken.sol";

contract BurnChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    IBEP20 public kebab;
    MarsToken public mars;
    uint256 public lastUpdate;
    uint256 public ratio;
    uint256 public period;
    uint256 public decay;

    event Burn(address indexed user, uint256 amount, uint256 reward);

    constructor(
        IBEP20 _kebab,
        MarsToken _mars,
        uint256 _lastUpdate,
        uint256 _ratio,
        uint256 _period,
        uint256 _decay
    ) public {
        kebab = _kebab;
        mars = _mars;
        lastUpdate = _lastUpdate;
        ratio = _ratio; // 1000000000 => 1
        period = _period; // in blocks
        decay = _decay; // 1000 => ratio * 999/1000 every _period blocks
    }

    function burn(uint256 _amount) public {
        require(_amount >= 10**18, "burn: minimum is 1 KEBAB");
        kebab.safeTransferFrom(address(msg.sender), address(burnAddress), _amount);
        uint256 newPeriods = block.number.sub(lastUpdate).div(period);
        while (newPeriods >= 1) {
            ratio = ratio.mul(decay.sub(1)).div(decay);
            newPeriods = newPeriods.sub(1);
        }
        uint256 reward = _amount.div(10**9).mul(ratio);
        mars.mint(address(msg.sender), reward);
        
        emit Burn(address(msg.sender), _amount, reward);
    }

}