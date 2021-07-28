docker stop cos
docker rm cos
docker rmi c:1.1

docker build -t c:1.1 .
docker run --name cos --privileged -d -v $PWD:/m c:1.1
docker exec -it cos /bin/sh

