docker stop wf
docker rm wf
docker rmi winterfell:1.1

docker build -t winterfell:1.1 .
docker run --name wf -d -v $PWD/src:/opt/winterfell -p 8189:80 -p 9189:11212 winterfell:1.1

