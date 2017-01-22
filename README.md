# Audio Generator Service

## WIP

### About
A service that hosts a file at a random port, generated with some random SoX options  
Needs Service Registry https://github.com/stofstik/service-registry

### Installation
- `sudo apt-get install sox`
- `npm install -g gulp`
- `npm install`
- `gulp`

### Running
Provide an mp3 file as first arg, otherwise default audio file will be `duck.mp3`  
e.g: `node build/server/app.js ./some-file.mp3`
