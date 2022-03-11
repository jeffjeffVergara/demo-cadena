const express = require('express');
const Blockchain = require('../blockchain');
const bodyParser = require('body-parser');



const HTTP_PORT = process.env.HTTP_PORT || 3001;

const app = express();
const bc = new Blockchain();

app.get('/blocks', (req, res) => {
	res.json(bc.chain);
});

app.use(bodyParser.json());
app.post('/mine', (req, res) => {
    const block = bc.addBlock(req.body.data);
    console.log(`Nuevo bloque agregado: ${block.toString()}`);
    res.redirect('/blocks');
  });

app.listen(HTTP_PORT, () => console.log(`Escuhando el puerto HTTP: ${HTTP_PORT}`));