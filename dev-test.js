const Block = require('./blockchain/block');
const SHA256 = require('crypto-js/sha256');

const block = new Block('10:45:10', '0000','AFDJ','Transferencias');
console.log(Block.genesis().toString());


const primerBlock = Block.mineBlock(Block.genesis(), 'nuevo registro');
console.log(primerBlock.toString());

const fooBlock = Block.mineBlock(Block.genesis(), 'nuevo registro 2');
console.log(fooBlock.toString());


console.log('Hash de Jefferson: ' + SHA256('Jefferson').toString());