http       = require "http"
express    = require "express"
socketio   = require "socket.io"
ioClient   = require "socket.io-client"
fs         = require "fs"
SoxCommand = require "sox-audio"

SERVICE_NAME = "audio-generator"

log       = require "./lib/log"
random    = require "./lib/random"

# server without a handler we do not need to serve files
app       = express()
server    = http.createServer app
io        = socketio.listen server

# fixed location of service registry
servRegAddress = "http://localhost:3001"

# collection of client sockets
sockets = []

audioFile = process.argv[2]

app
  .get "/audio.mp3", (req, res) ->
    log.info "sending file"
    src1 = audioFile || "./duck.mp3"
    soxCommand = SoxCommand()
    soxCommand
      .input(src1)
      .inputFileType("mp3")
      .output(res)
      .outputFileType("mp3")
      # add a touch of weirdness...
      .addEffect("speed", random.hun(90, 110))
      .addEffect("stretch", random.hun(90, 110))
      .addEffect("bass", "+#{random.int(0, 5)}")
      .addEffect("vol", random.int(1, 1))
      .addEffect("pad", random.dec(0, 40))

    if(random.int(0, 1) == 0)
      soxCommand
        .addEffect("swap", [])

    soxCommand.on "prepare", (args) ->
      log.info "preparing with #{args.join ' '}"

    soxCommand.on "start", (cmdline) ->
      log.info "spawned sox with cmd: #{cmdline}"

    soxCommand.on "error", (err, stdout, stderr) ->
      log.info "cannot process audio #{err.message}"
      log.info "sox command stdout #{stdout}"
      log.info "sox command stderr #{stderr}"

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
