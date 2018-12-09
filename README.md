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

## Reference repositories
For building this, two repositories served as references and helped a lot:
* [scotty-blog-postgres](https://github.com/dbushenko/scotty-blog-postgres)
* [haskell-scotty-realworld-example-app](https://github.com/eckyputrady/haskell-scotty-realworld-example-app)
