docker stop wf
docker rm wf
docker rmi winterfell:1.0

docker build -t winterfell:1.0 .
docker run --name wf -d -v $PWD/src:/opt/winterfell -v /tmp/wf_logs:/logs -p 8189:80 winterfell:1.0

