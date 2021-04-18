//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Challenge Coins
 * @author Hadyn
 * @version 1.0.0
 *
 * @notice A contract for non-fungible tokens which represent membership at a certain company.
 *
 * This membership could be for any part of the year and membership is verified either manually or
 * through email.
 *
 * These tokens are not meant to be serious but rather be a fun way to prove you worked at a
 * FAANG corporation. It is not recommended that these be bought or sold but you are certainly
 * able to. Just know that no matter the circumstance, it's one token per email/person per year.
 *
 * There is a centralized authority for verifying that people worked at these companies. This
 * means that this system is not entirely trustless. You will have to trust that centralized
 * authority.
 *
 * There is no cost to minting one of these challenge coins once you are verified except for paying
 * for the transaction.
 *
 * Do not for ANY reason send ERC20 tokens to this contract. You will not get them back! Anyone
 * telling you to do so is trying to grief you.
 */
contract ChallengeCoins is Ownable, ERC721("IDK", "IDK") {

  /** All of the out of the box company codes, additional companies may be added later  */
  uint256 public constant COMPANY_FACEBOOK = 0;
  uint256 public constant COMPANY_APPLE = 1;
  uint256 public constant COMPANY_AMAZON = 2;
  uint256 public constant COMPANY_NETFLIX = 3;
  uint256 public constant COMPANY_GOOGLE = 4;

  /**
   * @dev The metadata associated with each token.
   */
  mapping(uint256 => uint256) public metadata;

  /**
   * @dev The number of tokens that have been issued so far.
   */
  uint256 public count;

  constructor() public { }

  /**
   * @notice Directly mints a challenge coin to the specified recipient.
   *
   * This can only be called by the owner.
   *
   * @param _company   The company organization.
   * @param _year      The year that the position was held.
   * @param _recipient The recipient address.
   */
  function mint(
    uint256 _company,
    uint256 _year,
    address _recipient
  ) external onlyOwner {
    // Get the identifier of the next non-fungible token.
    uint256 _id = _nextID();

    // Mint the non-fungible token to the recipient.
    _mint(_recipient, _id);

    // Write the metadata for the minted non-fungible token.
    metadata[_id] = _encodeMetadata(_company, _year, _recipient);
  }

  /**
   * @dev Encodes non-fungible token metadata into a unsigned 256 bit value.
   *
   * It should be noted that the most significant 224 bits are reserved.
   *
   * @param _company The company organization.
   * @param _year    The year that the position was held.
   * @param _creator The original creator.
   * @return         The encoded value.
   */
  function _encodeMetadata(
    uint256 _company,
    uint256 _year,
    address _creator
  ) internal returns (uint256) {
    // Company and year must be within acceptable byte bounds otherwise they'll encode wrong.
    require(_company <= 0xff, "BC");
    require(_year <= 0xffff, "BY");

    // MSB indicates that the metadata is populated even when all values are zero.
    return 1 << 255 | _creator << 24 | _company << 16 | _year;
  }

  /**
   * @dev Gets the next free assignable identifier for a non-fungible token.
   *
   * @return The next free identifier.
   */
  function _nextID() internal returns (uint256) {
    // The next identifier will always be the current count of non-fungible tokens. This starts
    // at zero and counts up as tokens are minted.
    uint256 _id = count;

    // Should never overflow so safe math is not required here.
    count++;

    return _id;
  }
}