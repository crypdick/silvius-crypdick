#!/bin/zsh


sudo systemctl start docker.service
# for Ubuntu: sudo service docker start
IP=172.17.0.2
echo setting IP to $IP

echo "making sure docker service is running"
sudo systemctl start docker.service
echo "killing all existing docker containers"
docker kill $(docker ps -q) 

echo "starting new silvius server"
docker run -d voxhub/silvius-worker:latest /bin/sh -c 'cd /root/silvius-backend ; python2 kaldigstserver/master_server.py'

# originally, this line was first
# sometimes gives error  (if so, run command above instead)
# docker: Error response from daemon: driver failed programming external connectivity on endpoint: Error starting userland proxy: listen tcp 172.17.0.2:8019: bind: cannot assign requested address.

#docker run -d -p $IP:8019:8019 voxhub/silvius-worker:latest /bin/sh -c 'cd /root/silvius-backend ; python2 kaldigstserver/master_server.py'

echo "starting two decoder threads"
docker run -d voxhub/silvius-worker /root/worker.sh -u ws://$IP:8019/worker/ws/speech
docker run -d voxhub/silvius-worker /root/worker.sh -u ws://$IP:8019/worker/ws/speech

#docker container ls

# docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  <master server container>

echo "starting silvius client"

cd ~/bin/voice2code/silvius-crypdick && python2 stream/mic.py --server $IP --device 4 --audio-gate 1 --keep-going | python2 grammar/main.py

#--audio-gate 
#--keep-going 

## other commands
#If you are getting spurious recognitions, try ./run.sh -G to see the
#  level of sound that forms background noise, and filter it out with
#  ./run.sh -e -g 100.
  
#  To select a different microphone, run python2 stream/list-mics.py and note the correct device number. Then pass -d N to mic.py.
