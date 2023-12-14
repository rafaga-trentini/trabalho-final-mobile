const express = require('express');
const axios = require('axios');
const fs = require('fs');

const app = express();
const PORT = 3000;

app.use(express.json()); 

function generateUniqueId() {
  return Math.random().toString(36).substr(2, 9);
}

app.get('/todosPokemons', async (req, res) => {
  try {
    const response = await axios.get('https://pokeapi.co/api/v2/pokemon/');
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/primeiros151Pokemons', async (req, res) => {
  try {
    const response = await axios.get('https://pokeapi.co/api/v2/pokemon?limit=151&offset=0');
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/buscaPokemon/:nome', async (req, res) => {
  const { nome } = req.params;
  try {
    const response = await axios.get(`https://pokeapi.co/api/v2/pokemon/${nome}`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/buscaTipo/:tipo', async (req, res) => {
  const { tipo } = req.params;
  try {
    const response = await axios.get(`https://pokeapi.co/api/v2/type/${tipo}`);

    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/criarTreinador', (req, res) => {
  const { trainerName, trainerAge, selectedPokemons } = req.body;

  fs.readFile('treinadores.txt', 'utf8', (err, data) => {
    if (err && err.code !== 'ENOENT') {
      console.error(err);
      res.status(500).send('Erro interno do servidor ao ler arquivo');
    } else {
      let treinadores = [];
      if (data) {
        treinadores = JSON.parse(data);
      }

      const id = generateUniqueId(); 

      treinadores.push({ id, trainerName, trainerAge, selectedPokemons });

      fs.writeFile('treinadores.txt', JSON.stringify(treinadores), (err) => {
        if (err) {
          console.error(err);
          res.status(500).send('Erro interno do servidor ao escrever arquivo');
        } else {
          res.status(200).json({ id, message: 'Treinador criado com sucesso!' });
        }
      });
    }
  });
});

app.get('/treinadores', (req, res) => {
  fs.readFile('treinadores.txt', 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro interno do servidor ao ler arquivo');
    } else {
      let treinadores = [];
      if (data) {
        treinadores = JSON.parse(data);
      }
      res.status(200).json(treinadores);
    }
  });
});


app.delete('/excluirTreinador/:id', (req, res) => {
  const { id } = req.params;

  fs.readFile('treinadores.txt', 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro interno do servidor ao ler arquivo');
    } else {
      let treinadores = [];
      if (data) {
        treinadores = JSON.parse(data);
      }

      const index = treinadores.findIndex((trainer) => trainer.id === id);

      if (index !== -1) {
        treinadores.splice(index, 1);
      }

      fs.writeFile('treinadores.txt', JSON.stringify(treinadores), (err) => {
        if (err) {
          console.error(err);
          res.status(500).send('Erro interno do servidor ao escrever arquivo');
        } else {
          res.status(200).send('Treinador excluído com sucesso!');
        }
      });
    }
  });
});

app.put('/editarTreinador/:id', (req, res) => {
  const { id } = req.params;
  const { trainerName, trainerAge, selectedPokemons } = req.body;

  fs.readFile('treinadores.txt', 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send('Erro interno do servidor ao ler arquivo');
    } else {
      let treinadores = [];
      if (data) {
        treinadores = JSON.parse(data);
      }

      const index = treinadores.findIndex((trainer) => trainer.id === id);

      if (index !== -1) {
        treinadores[index] = {
          id,
          trainerName,
          trainerAge,
          selectedPokemons,
        };

        fs.writeFile('treinadores.txt', JSON.stringify(treinadores), (err) => {
          if (err) {
            console.error(err);
            res.status(500).send('Erro interno do servidor ao escrever arquivo');
          } else {
            res.status(200).send('Treinador atualizado com sucesso!');
          }
        });
      } else {
        res.status(404).send('Treinador não encontrado');
      }
    }
  });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});