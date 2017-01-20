# Data generator service

## WIP

### About
An assignment for a job opening.  
Generator is from https://github.com/viriciti/example-application.  
Starts on a random port and saves it's service info in a Mongo document.  
This way we can connect to this service from another service.

### TODO
- Seperate registry service with easy (REST) instance subscription and health/alive checks

### Installation
- `npm install -g gulp`
- `npm install`
- `gulp`
- `localhost:3000`

### Configuration
Start MongoDB on boot and restart when it crashes to reduce SPOF risk

- `sudo systemctl enable mongod.service`  
- `sudo vim /etc/systemd/system/multi-user.target.wants/mongod.service`  
- `add Restart=always under [Service]`  
- `The following sed command will find [Service] and add (/a) Restart=always below it`  
  - `Better to this manually though k tnx`  
  - `sudo sed -i '/\[Service\]/a Restart=always' /etc/systemd/system/multi-user.target.wants/mongod.service`  
- `sudo systemctl daemon-reload`  
- `sudo systemctl restart mongod.service`  
- `sudo reboot`  

To test do: `sudo kill -9 $(ps -aux | pgrep mongod)` and check if Mongo comes back online
