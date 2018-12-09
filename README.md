# haskell-image-gallery

Dockerized Haskell Rest API for yielding information about images. It's integrated with a PostgreSql database using its offical docker container, beyond it uses a migrations for creating table on up.

## Using
### Routes

* **list:** `/images`
* **create:** `/admin/images`
* **update:** `/admin/images`
* **get:** `/image/:id`
* **delete:** `/admin/image/:id`

### Running
* `sudo docker-compose up`
