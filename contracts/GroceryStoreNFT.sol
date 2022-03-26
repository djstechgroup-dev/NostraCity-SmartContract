// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NostraCityGroceryStore is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public constant MAX_SUPPLY = 20000;
    uint256 public constant MAX_TIER1_MINT = 50;
    uint256 public constant MAX_TIER2_MINT = 25;
    uint256 public constant MINT_PRICE = 200*1000000000000000000;//DAI
    IERC20 private _DAI;
    address private _vault;
    uint public _score = 0;

    //EVENTS
    //TODO: ADD EVENTS
    /** Mappings */
	mapping(address => bool) public presaleWhitelistTier1;
    mapping(address => bool) public presaleWhitelistTier2;

    modifier onlyVault() {
    require( _vault == msg.sender, "Caller is not the Vault" );
    _;
  }

    constructor(address DAI, address vault) ERC721("Tomato", "NCGS") {
        _DAI = IERC20(DAI);
        _vault = vault;
    }
    /**
     */
    function pause() public onlyOwner {
        _pause();
    }
    /**
     */
    function unpause() public onlyOwner {
        _unpause();
    }
      /**
	 * 
     *
	 */
    function safeMint(address to, uint8 numberOfTokens) public  {
        uint256 ts= totalSupply();
        uint256 mintingPrice = getMintingPrice(msg.sender);
        uint256 totalMintAmountInDAI = mintingPrice * numberOfTokens;
        uint256 mintLimit = getMintingLimit(msg.sender);
        require(_DAI.balanceOf(msg.sender) >= totalMintAmountInDAI, 'Your Wallet does not have enough DAI');
		require(numberOfTokens > 0, 'Mint at least 1 tomato');
        require(numberOfTokens + this.balanceOf(msg.sender) <= mintLimit, 'You have reached your limit of tokens');
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        
        _DAI.transferFrom(msg.sender , address(this), totalMintAmountInDAI);
        _score = _score + totalMintAmountInDAI;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, "https://gateway.pinata.cloud/ipfs/QmTrTBEc1LDSHsuqoaNRMr66aXsZabKQgQf9sa77DDiquH");
        }
        
    }
    /**
     */
    function getMintingLimit(address wallet) public view returns (uint256) {

        if (presaleWhitelistTier1[wallet]){
           return MAX_TIER1_MINT;
        } 
        else if (presaleWhitelistTier2[wallet]) {
            return MAX_TIER2_MINT;
        } 
        else {
            return MAX_SUPPLY;
        }
    }
     /**
     */
     function getMintingPrice(address wallet) public view returns (uint256) {

        if (presaleWhitelistTier1[wallet]){
           return (MINT_PRICE*20)/100;
        } 
        else if (presaleWhitelistTier2[wallet]) {
            return (MINT_PRICE*40)/100;
        } 
        else {
            return MINT_PRICE;
        }
    }
      /**
	 * 
     *
	 */

    function walletOfOwner(address _owner) public view returns (uint256[] memory){
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }
    /**
	 * 
     *
	 */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    /**
	 * 
	 */
	function whitelistTier1(address wallet, bool status) public onlyOwner {
		presaleWhitelistTier1[wallet] = status;
	}
    /**
	 * 
     *
	 */
    function whitelistTier2(address wallet, bool status) public  {
		presaleWhitelistTier2[wallet] = status;
	}
      /**
	 * 
     *
	 */
    function sendToTreasury() public onlyVault() returns (bool) {
        //TODO: EVENT
		return _DAI.transferFrom(address(this), _vault, _DAI.balanceOf(address(this)));
	}

    /**
     */
    function getCurrentScore() public view returns (uint256)  {
		return  _score;
	}
    

    /**
     */
    function setVault(address vault) public  onlyOwner  {
		_vault = vault;
	}
    

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

   function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}