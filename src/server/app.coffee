http       = require "http"
express    = require "express"
socketio   = require "socket.io"
ioClient   = require "socket.io-client"
fs         = require "fs"
SoxCommand = require "sox-audio"

SERVICE_NAME = "audio-generator"

log       = require "./lib/log"

# server without a handler we do not need to serve files
app       = express()
server    = http.createServer app
io        = socketio.listen server

# fixed location of service registry
servRegAddress = "http://localhost:3001"

# collection of client sockets
sockets = []

app
  .get "/audio.mp3", (req, res) ->
    log.info "sending file"
    src1 = "/home/stofstik/Downloads/Comfort_Fit_-_03_-_Sorry.mp3"
    src2 = "/home/stofstik/Downloads/Kriss_-_03_-_jazz_club.mp3"
    soxCommand = SoxCommand()
    soxCommand
      .input("/home/stofstik/Downloads/Comfort_Fit_-_03_-_Sorry.mp3")
      .output(res)
      .outputFileType("mp3")
      .addEffect("speed", 1.5)

    soxCommand.on "prepare", (args) ->
      console.log "preparing with #{args.join ' '}"

    soxCommand.on "start", (cmdline) ->
      console.log "spawned sox with cmd: #{cmdline}"

    soxCommand.on "error", (err, stdout, stderr) ->
      console.log "cannot process audio #{err.message}"
      console.log "sox command stdout #{stdout}"
      console.log "sox command stderr #{stderr}"

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
  # let the os choose a random port
  server.listen 0
  log.info "Listening on port", server.address().port
  # tell registry we are a service
  serviceRegistry.emit "service-up",
    name: SERVICE_NAME
    port: server.address().port

serviceRegistry.on "disconnect", () ->
  log.info "service registry disconnected"
