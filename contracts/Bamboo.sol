// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Bamboo is ERC20Burnable, Ownable {

  using SafeMath for uint256;

  string private constant SYMBOL = "BAM";
  string private constant NAME = "Bamboo";
  uint256 private constant INITIAL_SUPPLY = 100000000 * 10**9; // 100 million, precision 9
  uint256 private constant INITIAL_FEE = 20; 
  uint256 private constant PRECISION = 10**9;
  uint256 private constant PERCENT = 100;
  address private constant NULL_ADDRESS = address(0);

  uint256 public feeBuy;
  uint256 public feeSell;
  address public pool;
  address public devWallet;

  event Deployed(address sender, address pool, string symbol, string name);
  event SetBuyFee(address sender, uint256 fee);
  event SetSellFee(address sender, uint256 fee);
  event SetDevWallet(address sender, address devWallet);

  constructor(address _pool) 
    ERC20(SYMBOL, NAME) 
  {
    require(_pool != NULL_ADDRESS, "Bamboo::constructor: null pool address");
    _mint(_msgSender(), INITIAL_SUPPLY);
    setBuyFeePercent(INITIAL_FEE);
    setSellFeePercent(INITIAL_FEE);
    emit Deployed(_msgSender(), _pool, SYMBOL, NAME);
  }

  function decimals() public view virtual override returns (uint8) {
    return 9;
  }

  function setBuyFeePercent(uint256 feePercent) public onlyOwner {
    require(feePercent < feeBuy, "Bamboo::setBuyFeePercent: can only reduce transaction fees");
    feeBuy = feePercent;
    emit SetBuyFee(_msgSender(), feePercent);
  }

  function setSellFeePercent(uint256 feePercent) public onlyOwner {
    require(feePercent < feeSell, "Bamboo::setSellFeePercent: can only reduce transaction fees");
    feeSell = feePercent;
    emit SetSellFee(_msgSender(), feePercent);
  }

  function setDevWallet(address _devWallet) external onlyOwner {
    devWallet = _devWallet;
    emit SetDevWallet(_msgSender(), _devWallet);
  }

  // TODO

  function _transfer(
      address sender,
      address recipient,
      uint256 amount
  ) internal override virtual {
    address lpPool = pool;
    if(sender == lpPool) {
      uint256 devAmount = amount.mul(feeBuy).div(PERCENT);
      amount = amount.sub(devAmount);
      ERC20._transfer(sender, devWallet, devAmount);
    } else if (recipient == lpPool) {
      uint256 devAmount = amount.mul(feeSell).div(PERCENT);
      amount = amount.sub(devAmount);
      ERC20._transfer(sender, devWallet, devAmount);
    }
    ERC20._transfer(sender, recipient, amount);
  }

}
