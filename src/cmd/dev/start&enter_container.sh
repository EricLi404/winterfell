#!/bin/bash
docker start wf
sleep 2s
docker exec -it wf /bin/sh
