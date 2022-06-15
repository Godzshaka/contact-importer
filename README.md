# Contact-importer
This test was proposed by Koombea

## System requirements

- Docker

## Running the application locally

- Start the container on sleep mode: `docker-compose up -d --build`
- Enter the container: `docker exec -it contact-importer-api-web bash`
- Run bundle to install gems: `bundle install`
- Create the database: `rails db:setup`
- Start the application: `rails s -b 0.0.0.0`
- Access the application on `localhost:3000`

# Created user (but you are welcome to create another ones if you want to)
- email: test@koombea.com
- password: test123

# CSV Examples for contacts import located on spec/fixture/sheet/