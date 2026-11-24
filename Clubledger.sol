pragma solidity ^0.8.20;

contract ClubLedger {
    enum EntryType { Income, Expense, Correction }

    struct Entry {
        uint256 id;
        EntryType entryType;
        uint256 amount;          // fake units, e.g. rupees
        string category;         // e.g. "Sponsorship", "Printing"
        string description;      // fake data only
        address recordedBy;
        uint256 timestamp;
        uint256 correctsId;      // 0 if not a correction (ids start at 1)
        bool correctionIsIncome; // for corrections: direction of adjustment
    }

    address public admin;
    mapping(address => bool) public isTreasurer;
    Entry[] private entries;
    int256 public balance;

    event TreasurerAdded(address indexed who);
    event TreasurerRemoved(address indexed who);
    event EntryRecorded(uint256 indexed id, EntryType entryType, uint256 amount, address indexed by);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can do this");
        _;
    }

    modifier onlyTreasurer() {
        require(isTreasurer[msg.sender], "Wallet is not an authorized treasurer");
        _;
    }

    constructor() {
        admin = msg.sender;
        isTreasurer[msg.sender] = true;
    }

    function addTreasurer(address who) external onlyAdmin {
        isTreasurer[who] = true;
        emit TreasurerAdded(who);
    }

    function removeTreasurer(address who) external onlyAdmin {
        isTreasurer[who] = false;
        emit TreasurerRemoved(who);
    }

    function recordIncome(uint256 amount, string calldata category, string calldata description)
        external onlyTreasurer
    {
        require(amount > 0, "Amount must be greater than zero");
        balance += int256(amount);
        _push(EntryType.Income, amount, category, description, 0, true);
    }

    function recordExpense(uint256 amount, string calldata category, string calldata description)
        external onlyTreasurer
    {
        require(amount > 0, "Amount must be greater than zero");
        require(balance >= int256(amount), "Expense exceeds current balance");
        balance -= int256(amount);
        _push(EntryType.Expense, amount, category, description, 0, false);
    }

    // Corrections are NEW entries. The original is never touched.
    function recordCorrection(
        uint256 originalId,
        uint256 amount,
        bool addsToBalance,
        string calldata reason
    ) external onlyTreasurer {
        require(amount > 0, "Amount must be greater than zero");
        require(originalId >= 1 && originalId <= entries.length, "Original entry does not exist");
        if (addsToBalance) {
            balance += int256(amount);
        } else {
            require(balance >= int256(amount), "Correction exceeds current balance");
            balance -= int256(amount);
        }
        _push(EntryType.Correction, amount, "Correction", reason, originalId, addsToBalance);
    }

    function _push(
        EntryType t, uint256 amount, string memory category,
        string memory description, uint256 correctsId, bool dir
    ) internal {
        uint256 id = entries.length + 1;
        entries.push(Entry(id, t, amount, category, description, msg.sender, block.timestamp, correctsId, dir));
        emit EntryRecorded(id, t, amount, msg.sender);
    }

    function entryCount() external view returns (uint256) {
        return entries.length;
    }

    function getEntry(uint256 id) external view returns (Entry memory) {
        require(id >= 1 && id <= entries.length, "Entry does not exist");
        return entries[id - 1];
    }
}