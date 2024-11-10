// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyLibrary {
    // State variable to store the owner's address
    address public owner;

    // Counter for total number of books added
    uint256 public bookCount;

    // Enum to represent reading status
    enum ReadStatus { WantToRead, AlreadyRead }

    // Enum to represent book categories
    enum Category { Adventure, Horror, Detective }

    // Struct to represent a Book
    struct Book {
        uint256 id;
        string name;
        string author;
        uint256 price; // in wei
        ReadStatus status;
        Category category;
    }

    // Mapping from book ID to Book
    mapping(uint256 => Book) public books;

    // Mapping from Category to array of Book IDs
    mapping(Category => uint256[]) private categoryToBooks;

    // Events
    event BookAdded(
        uint256 indexed id,
        string name,
        string author,
        uint256 price,
        ReadStatus status,
        Category category
    );
    event ReadStatusUpdated(uint256 indexed id, ReadStatus newStatus);

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only owner can perform this action");
        _;
    }

    // Constructor sets the deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    function addBook(
        uint256 _id,
        string memory _name,
        string memory _author,
        uint256 _price,
        Category _category
    ) public onlyOwner {
        require(_id > 0, "Book ID must be greater than zero");
        require(books[_id].id == 0, "Book with this ID already exists");

        books[_id] = Book({
            id: _id,
            name: _name,
            author: _author,
            price: _price,
            status: ReadStatus.WantToRead,
            category: _category
        });

        categoryToBooks[_category].push(_id);
        bookCount += 1;
        emit BookAdded(_id, _name, _author, _price, ReadStatus.WantToRead, _category);
    }

    
    function getBook(uint256 _id) public view returns (Book memory) {
        require(_id > 0, "Book ID must be greater than zero");
        require(books[_id].id != 0, "Book does not exist");
        return books[_id];
    }


    function markAsRead(uint256 _id) public {
        require(_id > 0, "Book ID must be greater than zero");
        require(books[_id].id != 0, "Book does not exist");

        books[_id].status = ReadStatus.AlreadyRead;
        emit ReadStatusUpdated(_id, ReadStatus.AlreadyRead);
    }

    function markAsWantToRead(uint256 _id) public {
        require(_id > 0, "Book ID must be greater than zero");
        require(books[_id].id != 0, "Book does not exist");

        books[_id].status = ReadStatus.WantToRead;
        emit ReadStatusUpdated(_id, ReadStatus.WantToRead);
    }


    function getAllBooks() public view returns (Book[] memory) {
        Book[] memory allBooks = new Book[](bookCount);
        uint256 counter = 0;

        for (uint256 i = 1; i <= bookCount; i++) {
            if (books[i].id != 0) {
                allBooks[counter] = books[i];
                counter++;
            }
        }

        // Resize the array to the actual number of books
        bytes memory encoded = abi.encode(allBooks);
        assembly { mstore(add(encoded, 0x40), counter) }
        return abi.decode(encoded, (Book[]));
    }


    function getBooksByCategory(Category _category) public view returns (string[] memory) {
        uint256[] memory bookIds = categoryToBooks[_category];
        string[] memory bookNames = new string[](bookIds.length);

        for (uint256 i = 0; i < bookIds.length; i++) {
            bookNames[i] = books[bookIds[i]].name;
        }

        return bookNames;
    }
}

