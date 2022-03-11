##################################################################################
# ---------------------1. Configuración Node --------------------------------------#
##################################################################################
# Verificar Node y NPM
node -v
npm -v
# Crear nombre del Proyecto, entrar en el proyecto creado
 mkdir osiptel-cadena | cd osiptel-cadena
# Iniciar como NPM Proyect 
npm init -y
# Instalar la dependencia Nodemon viene con un servidor de desarrollo
npm i nodemon --save-dev

##################################################################################
# ---------------------2. Clase Bloque --------------------------------------------#
##################################################################################
#
# Crear la clase Bloque con un archivo llamado block.js. 
# Cada bloque debe tener un `hash`, `lastHash`, y `timestamp` como atributos.

# Crea el archivo block.js

# Dentro de block.js: 
```
class Block {
constructor(timestamp, lastHash, hash, data) {
	this.timestamp = timestamp;
  this.lastHash = lastHash;
  this.hash = hash;
  this.data = data;
}
toString() {
	return `Block -
          Timestamp : ${this.timestamp}
 		      Last Hash : ${this.lastHash.substring(0, 10)}
          Hash      : ${this.hash.substring(0, 10)}
          Data      : ${this.data}`;
  }
}
module.exports= Block;

```
# Para probar la nueva clase Bloque creada. Crear dev-test.js junto a block.js:

```
const Block = require('./block');
const block = new Block('foo', 'bar','zoo','baz');
console.log(block.toString())
```
# En `package.json`, buscar la seccion scripts y agregar luego de una coma:
```
,"dev-test": "nodemon dev-test"
```
# Luego de asegurarse de guardar todo, ejecutar lo siguiente para ejecutar:
npm run dev-test

##################################################################################
# ---------------------3. Bloque Genesis ------------------------------------------#
##################################################################################
#
# Todo blockchain empieza con el bloque "Genesis" - un bloque por defecto que origina la cadena.
# Agregar la función estática genesis() en `Block` en la clase `block.js`;
```
static genesis() {
	return new this('Genesis time', '-----', 'f1r57-h45h', []);
}
```
# De vuelta en dev-test.js, probamos el bloque genesis:
```
console.log(Block.genesis().toString());
```
npm run dev-test

##################################################################################
# ---------------------4. Minería de Bloque ---------------------------------------#
##################################################################################
#
# Agregar una funcion para generar un bloque basado en alguna data de entrada y el último bloque, function mineBlock
# Generar un bloque es equivalente al acto de Minería ya que toma esfuerzo computacional
# Luego incrementaremos el esfuerzo computacional para ser más explicitos 
# Se agrega el método mineBlock() en la clase Block
```
static mineBlock(lastBlock, data) {
        const lastHash = lastBlock.hash;
        const timestamp = Date.now();
        const hash = 'todo-hash';
        return new this(timestamp, lastHash, hash, data);
    }
```
# Ahora probaremos mineBlock() desde dev-test.js
# Borraremos todas las lineas excepto la que importa la Clase Block
```
const fooBlock = Block.mineBlock(Block.genesis(), 'foo');
console.log(fooBlock.toString());
```

##################################################################################
# ---------------------5. Encriptación de Bloque ----------------------------------#
##################################################################################
#
# Una funcion hashing genera un único valor para la combinacion de atributos del bloque.
# El hash de cada bloque se basa en su tiempo de creación (timestamp), data que guarda, y el hash del bloque que vino antes. 

# Instalar la librería crypto-js, módulo que tiene el algoritmo SHA256 (Secure Hashing Algorithm 256-bit)
npm i crypto-js --save
# En block.js, agregamos la invocación a la librería crypto-js en la cabecera de todo el archivo, especificamos el algoritmo.
```
const SHA256 = require('crypto-js/sha256');
```
# Luego agregar una funcion estática hash() a la clase Bloque
```
static hash(timestamp, lastHash, data) {
	return SHA256(`${timestamp}${lastHash}${data}`).toString();
}
```
# Reemplazamos el uso de hash() en el método de la Mineria de Bloques
```
const hash = Block.hash(timestamp, lastHash, data);
```
# Ejecutar y probar los scripts de dev-test
npm run dev-test

##################################################################################
# ---------------------7. Minar un Bloque ---------------------------------------#
##################################################################################
# Actualizar constructores
```
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
```
##################################################################################
# ---------------------6. Clase Cadena ------------------------------------------#
##################################################################################
#
# Crear una clase Cadena basado en la clase Bloque creada anteriormente

# Crear el archivo blockchain.js

```
const Block = require('./block');

class Blockchain {
  constructor() {
    this.chain = [Block.genesis()];
  }

  addBlock(data) {
    const block = Block.mineBlock(this.chain[this.chain.length-1], data);
    this.chain.push(block);
    return block;
  }
}

module.exports = Blockchain;
```
##################################################################################
# ---------------------7. Validaciones de Cadena ----------------------------------#
##################################################################################
#
# La validación de cadena asegura que la cadena no haya sido corrupta, sobretodo cuando hay multiples contribuidores.
# Para evaluar la cadena, debemos asegurarnos que empiece con el bloque genesis y que su hash haya sido bien apropiadamente.

# En la clase Blockchain se agrega el método isValidChain

```
isValidChain(chain) {
  if (JSON.stringify(chain[0]) !== JSON.stringify(Block.genesis())) return false;
  for (let i=1; i<chain.length; i++) {
    const block = chain[i];
    const lastBlock = chain[i-1];
    if (
      block.lastHash !== lastBlock.hash || block.hash !== Block.blockHash(block)
    ) {
      return false;
    }
  }
  return true;
}
```
# Este método depende de la funcion blockHash en la clase Bloque
# Esto generará un hash del bloque basado en su instancia.

```
static blockHash(block) {
	const { timestamp, lastHash, data } = block;
  return Block.hash(timestamp, lastHash, data);
}
```
# Si existe otro contribuidor(nodo) que actualiza o genera una nueva cadena lo correcto es reemplazar
# Solo se debe reemplazar cuando exista una cadena más grade que la que yo tengo en mi nodo.
# Crearemos una función para reemplazar la cadena que tenemos en memoria.
```
replaceChain(newChain) {
  if (newChain.length <= this.chain.length) {
    console.log('La cadena recibida no es mas larga que la que tengo');
    return;
  } else if (!this.isValidChain(newChain)) {
    console.log('La cadena recibida no es válida');
    return;
  }

  console.log('Reemplazando la nueva cadena a mi cadena local');
  this.chain = newChain;
}
```
##################################################################################
# ---------------------8. Contruir Aplicación ----------------------------------#
##################################################################################
#Organizar el proyecto
#- Crear carpeta blockchain/
#- Mover block.js, blockchain.js a blockchain/
#- Renombrar blockchain.js a index.js 
```
const Blockchain = require('./index');
```

#- Crear carpeta app/
#- Crear app/index.js

# Agregar express module para crear Node API:
npm i express --save

#Crear una instancia de blockchain en el archivo principal
#Luego crear un GET request para obtener los bloques de una cadena. In app/index.js:
```
const express = require('express');
const Blockchain = require('../blockchain');
const HTTP_PORT = process.env.HTTP_PORT || 3001;

const app = express();
const bc = new Blockchain();

app.get('/blocks', (req, res) => {
	res.json(bc.chain);
});

app.listen(HTTP_PORT, () => console.log(`Listening on port: ${HTTP_PORT}`));
```
#Ahora en package.json, add the `start` and `dev` scripts 
#en la sección “scripts”:
```
"start": "node ./app",
"dev": "nodemon ./app"
```
npm run dev
npm i body-parser --save

#En app/index.js, agregar método para Minar

```
const bodyParser = require('body-parser');
app.use(bodyParser.json());
…
app.post('/mine', (req, res) => {
  const block = bc.addBlock(req.body.data);
  console.log(`New block added: ${block.toString()}`);
  res.redirect('/blocks');
});
```

HTTP_PORT=3001 P2P_PORT=5001 npm run dev
HTTP_PORT=3002 P2P_PORT=5002 PEERS=ws://localhost:5001 npm run dev
HTTP_PORT=3003 P2P_PORT=5003 PEERS=ws://localhost:5002,ws://localhost:5001 npm run dev

www.menti.com
1968 8024