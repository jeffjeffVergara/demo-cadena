const SHA256 = require('crypto-js/sha256');
class Block {
    constructor(timestamp, lastHash, hash,nonce, data) {
        this.timestamp = timestamp;
      this.lastHash = lastHash;
      this.hash = hash;
      this.nonce = nonce;
      this.data = data;

    }
    
    toString() {
        return `Block -
              Timestamp : ${this.timestamp}
              Last Hash : ${this.lastHash.substring(0, 10)}
              Hash      : ${this.hash.substring(0, 10)}
              Nonce     : ${this.nonce}
              Data      : ${this.data}`;
      }
    static genesis() {
        return new this('Genesis time', '-----', 'f1r57-h45h','', []);
    }

    static mineBlock(lastBlock, data){
        const lastHash = lastBlock.hash;
        let hash, timestamp;
        let difficulty = 2;
        let nonce = 0;

        do {
            nonce++;
            timestamp = Date.now();

            hash = Block.hash(timestamp, lastHash, data, nonce, difficulty);
          } while (hash.substring(0, difficulty) !== '0'.repeat(difficulty));

        return new this(timestamp,lastHash,hash,nonce,data);
    }

    static hash(timestamp, lastHash, data,nonce, difficulty) {
        return SHA256(`${timestamp}${lastHash}${data}${nonce}${difficulty}`).toString();
    }

    static blockHash(block) {
        const { timestamp, lastHash, data } = block;
      return Block.hash(timestamp, lastHash, data);
    }

}
module.exports= Block;