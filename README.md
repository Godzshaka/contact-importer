# SARRAR
Repositório destinado ao TCC Mariane Vanderlei e Yago

# Development

## Setup
To build the cointainer follow the steps below:

docker-compose up --build

docker exec -it sarrar-api-web bash

rake db:create
rake db:migrate
