pragma solidity 0.6.12;

import '@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol';
import '@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol';
import "./MarsToken.sol";
import "@nomiclabs/buidler/console.sol";

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
    mapping(uint256 => uint256) public ratios;
    uint256 public lastPeriod;

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
        ratio = _ratio; // 1000000000 => 1, times 1e9
        period = _period; // in blocks
        decay = _decay; // 1000 => ratio * 999/1000 every _period blocks
        if (lastUpdate <= block.number) {
            lastPeriod = block.number.sub(lastUpdate).div(period);    
        } else {
            lastPeriod = 0;
        }
        ratios[lastPeriod] = ratio;
    }

    function burn(uint256 _amount) public {
        require(_amount >= 10**18, "burn: minimum is 1 KEBAB");
        require(lastUpdate <= block.number, "burn: wrong request");
        kebab.safeTransferFrom(address(msg.sender), address(burnAddress), _amount);
        uint256 currentPeriod = block.number.sub(lastUpdate).div(period);
        uint256 cratio = ratios[lastPeriod];
        while (lastPeriod < currentPeriod) {
            cratio = cratio.mul(decay.sub(1)).div(decay);
            lastPeriod += 1;
            ratios[lastPeriod] = cratio;
        }
        uint256 reward = _amount.mul(ratios[lastPeriod]).div(10**9);
        mars.mint(address(msg.sender), reward);
        
        emit Burn(address(msg.sender), _amount, reward);
    }

}