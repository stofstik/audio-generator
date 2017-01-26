fs         = require "fs"
http       = require "http"
express    = require "express"
socketio   = require "socket.io"
ioClient   = require "socket.io-client"
random     = require("random-js")()
SoxCommand = require "sox-audio"

randHelper = require "./lib/rand-helper"
log        = require "./lib/log"

# server without a handler we do not need to serve files
app       = express()
server    = http.createServer app
io        = socketio.listen server

SERVICE_NAME = "audio-generator"
# fixed location of service registry
servRegAddress = "http://localhost:3001"

# collection of client sockets
sockets = []

# TODO check file size, only allow small files
app
  .get "/audio.mp3", (req, res) ->
    log.info "sending file"
    # check if we have a source file as argument
    audioFile = process.argv[2] || "./audio-files/applause-1.mp3"
    fs.stat audioFile, (err, stats) ->
      if(err)
        log.info "could not find source file, using default"
        audioFile = "./audio-files/applause-1.mp3"
      soxCommand = SoxCommand()
      soxCommand
        .input(audioFile)
        .inputFileType("mp3")
        .output(res) # set response stream as output stream
        .outputSampleRate(44100)
        .outputFileType("mp3")
        # add a touch of weirdness...
        .addEffect("speed", randHelper.real(0.9, 1.1, true, 100))
        .addEffect("bass", "+#{random.integer(0, 5)}")
        .addEffect("treble", "+#{random.integer(0, 5)}")
        .addEffect("vol", randHelper.real(-0.5, 0.5, true, 100))
        .addEffect("pad", randHelper.real(0, 2, true, 100))
        .addEffect("gain", "-n")
      if(random.bool())
        soxCommand
          .addEffect("swap", [])

      # error logging
      soxCommand.on "error", (err, stdout, stderr) ->
        log.info "cannot process audio #{err.message}"
        log.info "sox command stdout #{stdout}"
        log.info "sox command stderr #{stderr}"

      # run it!
      soxCommand.run()

# websocket connection logic
io.on "connection", (socket) ->
  # add socket to client sockets
  sockets.push socket
  log.info "Socket connected, #{sockets.length} connection(s) active"

  # disconnect logic
  socket.on "disconnect", ->
    # remove socket from client sockets
    sockets.splice sockets.indexOf(socket), 1
    log.info "Socket disconnected, #{sockets.length} connection(s) active"

# connect to the service registry
serviceRegistry = ioClient.connect servRegAddress,
  "reconnection": true

# when we are connected to the registry start the service
serviceRegistry.on "connect", (socket) ->
  log.info "service registry connected"
  # tell registry we are a service
  serviceRegistry.emit "service-up",
    name: SERVICE_NAME
    port: server.address().port

serviceRegistry.on "disconnect", () ->
  log.info "service registry disconnected"

# let the os choose a random port
server.listen 0
log.info "Listening on port", server.address().port
