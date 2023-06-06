// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
contract EjercicioCuatro {

    struct Subasta {
        uint256 startTime;
        uint256 endTime;
        address payable creator;
        address  highestBidder;
        uint256 highestBid;
        uint256 totalBids;
        uint256 deposit;
        bool ended;
        mapping(address billetera => uint256 amount) offers;
    }
    
    mapping(bytes32 auctionId => Subasta ) public subastas;
    bytes32[] subastasActivas;
    event SubastaCreada(bytes32 indexed _auctionId, address indexed _creator);
    event OfertaPropuesta(address indexed _bidder, uint256 _bid);
    event SubastaFinalizada(address indexed _winner, uint256 _bid);

    error CantidadIncorrectaEth();
    error TiempoInvalido();
    error SubastaInexistente();
    error FueraDeTiempo();
    error OfertaInvalida();
    error SubastaEnMarcha();

    function creaSubasta(uint256 _startTime, uint256 _endTime) public payable {
        if (msg.value != 1 ether ) revert CantidadIncorrectaEth();
        if (_startTime >= _endTime) revert TiempoInvalido();
        bytes32 _auctionId = _createId(_startTime, _endTime);
        Subasta storage s = subastas[_auctionId];
        s.startTime = _startTime;
        s.endTime = _endTime;
        s.creator = payable( msg.sender);
        s.deposit = msg.value;
        subastasActivas.push(_auctionId);
        emit SubastaCreada(_auctionId, msg.sender);
    }

    function proponerOferta(bytes32 _auctionId) public payable {
        if (subastas[_auctionId].endTime == 0 || subastas[_auctionId].ended) revert SubastaInexistente();
        Subasta storage subasta = subastas[_auctionId];
        if(subastas[_auctionId].highestBid > msg.value) revert OfertaInvalida();
        if(block.timestamp > subasta.endTime || block.timestamp < subasta.startTime) revert FueraDeTiempo();
        
        subasta.offers[msg.sender] += msg.value;     
        subasta.highestBid = subasta.offers[msg.sender];
        subasta.highestBidder = msg.sender;   
        if (subasta.endTime - block.timestamp <= 5 minutes) {
            subasta.endTime += 5 minutes;
        }
        emit OfertaPropuesta(msg.sender, subasta.offers[msg.sender]);
    }

    function finalizarSubasta(bytes32 _auctionId) public {
        Subasta storage s =subastas[_auctionId];
        if (s.endTime == 0 || s.ended) revert SubastaInexistente();
        if(block.timestamp <= s.endTime) revert SubastaEnMarcha();
        emit SubastaFinalizada(s.highestBidder, s.highestBid);
        s.ended = true;
        removeAuction(_auctionId);

    }

    function recuperarOferta(bytes32 _auctionId)  external returns(uint)  {
        Subasta storage s = subastas[_auctionId];
        if(block.timestamp <= s.endTime) revert SubastaEnMarcha();       
        uint256  amount = s.offers[msg.sender];
        if(amount  == 0) revert("No tiene oferta");
        s.offers[msg.sender] = 0;
        if (msg.sender == s.highestBidder) {
            payable(msg.sender).transfer(amount + s.deposit);
        } else {
            payable(msg.sender).transfer(amount);
        }
        return amount;
    }

    function verSubastasActivas() public view returns (bytes32[] memory) {
        return subastasActivas;
    }

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////   INTERNAL METHODS  ///////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    function _createId(
        uint256 _startTime,
        uint256 _endTime
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _startTime,
                    _endTime,
                    msg.sender,
                    block.timestamp
                )
            );
    }
    function removeAuction(bytes32 _auctionId) internal {
        for (uint256 i = 0; i < subastasActivas.length; i++) {
            if (subastasActivas[i] == _auctionId) {
                subastasActivas[i] = subastasActivas[subastasActivas.length - 1];
                subastasActivas.pop();
                break;
            }
        }
    }
}

