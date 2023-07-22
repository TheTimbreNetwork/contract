// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract TimbreProtocol {
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

    function addReviewableAddress(address newReviewableAddress) public {
        require(
            reviewableAddressExists[newReviewableAddress] == false,
            "This reviewable address exists!"
        );
        reviewableAddressExists[newReviewableAddress] = true;
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
    }

    function getViewerAccess(
        address existingReviewableAddress,
        address reviewerAddress
    ) public view returns (bool) {
        //  give access if fee is default of 0
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
}
