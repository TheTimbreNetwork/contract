// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract TimbreProtocol {
    event AddedReviewableAddress(address newReviewableAddress);
    event AddedReview(
        address reviewer,
        address existingReviewableAddress,
        string _reviewDecentralizedStorageURL,
        uint256 currentBlockTime,
        uint256 _priceToAccessReview
    );

    struct ReviewObject {
        string reviewDecentralizedStorageURL;
        uint256 timestamp;
        uint256 priceToAccessReview;
        bool exists;
    }
    mapping(address reviewableAddress => bool exists)
        public reviewableAddressExists;
    mapping(address reviewableAddress => mapping(address reviewer => ReviewObject reviewObject))
        public reviewableAddressToReviewerToReviewObject;
    mapping(address reviewableAddress => mapping(address reviewer => mapping(address viewer => bool hasAccess)))
        public reviewableAddressToReviewerToViewerToAccess;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function addReviewableAddress(address newReviewableAddress) public {
        require(
            reviewableAddressExists[newReviewableAddress] == false,
            "This reviewable address exists!"
        );
        reviewableAddressExists[newReviewableAddress] = true;
        emit AddedReviewableAddress(newReviewableAddress);
    }

    function addReview(
        address existingReviewableAddress,
        string calldata _reviewDecentralizedStorageURL,
        uint256 _priceToAccessReview
    ) public {
        require(
            reviewableAddressExists[existingReviewableAddress] == true,
            "You can't add a review since it's not a reviewable address yet!"
        );

        ReviewObject memory newReviewObject = ReviewObject(
            _reviewDecentralizedStorageURL,
            block.timestamp,
            _priceToAccessReview,
            true
        );

        reviewableAddressToReviewerToReviewObject[existingReviewableAddress][
            msg.sender
        ] = newReviewObject;

        emit AddedReview(
            msg.sender,
            existingReviewableAddress,
            _reviewDecentralizedStorageURL,
            block.timestamp,
            _priceToAccessReview
        );
    }

    function getViewerAccess(
        address existingReviewableAddress,
        address reviewerAddress
    ) public view returns (bool) {
        if (
            reviewableAddressToReviewerToReviewObject[
                existingReviewableAddress
            ][reviewerAddress].priceToAccessReview <= 0
        ) {
            return true;
        }

        return
            reviewableAddressToReviewerToViewerToAccess[
                existingReviewableAddress
            ][reviewerAddress][msg.sender];
    }

    function payForViewerAccess(
        address existingReviewableAddress,
        address reviewer
    ) public payable {
        uint256 price = reviewableAddressToReviewerToReviewObject[
            existingReviewableAddress
        ][reviewer].priceToAccessReview;
        require(msg.value >= price, "Not enough funds to access this review!");

        reviewableAddressToReviewerToViewerToAccess[existingReviewableAddress][
            reviewer
        ][msg.sender] = true;
    }

    modifier onlyOwner() {
        require(
            msg.sender == i_owner,
            "Only the owner can call this function!"
        );
        _;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
