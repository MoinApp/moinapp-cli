pkg = require '../package'
program = require 'commander'
ApiClient = require './apiClient'
Configuration = require './config'

class MoinCLI
  config: null
  client: null
  
  constructor: () ->
    
    
  main: ->
    @config = Configuration.getConfiguration()
    @registerCLIApp()
    
    @client = new ApiClient @config.get('session')
    @parse()
    
  registerCLIApp: ->
    program
      .version(pkg.version)
      .option('-s --session [session]', 'Session token.', false)
      .option('-l --login [username]', 'Login. Requires username and password', false)
      .option('-c --create [username]', 'Create a new user. Requires username, password and email.', false)
      .usage('[options] username')
      .option('-p --password [password]', 'Enter password for username. Requires -l option.', false)
      .option('-e --email [email]', 'Enter email for new user. Required for -c option.', false)
      .option('-g --get [username]', 'Returns the given user.', false)
      .option('--config [key:value]', 'Sets the config key with the given value.', null)
      .parse(process.argv)
      
  apiError: (error) ->
    console.log "Error communicating with server:", error
      
  parse: ->
    if !!program.session
      @config.set 'session', program.session
      
    if program.create
      @createAccount program.create, program.password, program.email
    else if program.login
      @login program.login, program.password
    else if program.get
      @getUser program.get
    else if program.config
      key = program.config.split(':')[0]
      value = program.config.split(':')[1]
      
      @setConfig key, value
    else if program.args.length > 0
      @moinUser program.args[0]
    else
      program.help()
      
  createAccount: (username, password, email) ->
    if not username or not password or not email
      return console.log "You need to specify username, password and email!"
    
    @client.createNewUser username, password, email, @loginSuccessHandler
      
  login: (username, password) ->
    if not username or not password
      return console.log "You need to specify username and password!"
    
    console.log "Logging in with username \"#{username}\"..."
    client.login username, password, @loginSuccessHandler
      
  loginSuccessHandler: (err, session) ->
    if !!err
      return @apiError err
    
    @config.set 'session', sessionToken
    console.log "Logged in."
    
  getUser: (username) ->
    @client.getUser username, (err, user) ->
      if !!err
        return @apiError err
      console.log "[USER]", user
      
  moinUser: (username) ->
    @client.moinUsername username, (err, data) ->
      if !!err
        return @apiError err
      console.log "Moin sent.", data
      
  setConfig: (key, value) ->
    console.log 'Writing config key "' + key + '" as "' + value + '".'
    config.set key, value

main = ->
  app = new MoinCLI
  app.main()
module.exports = ->
  main()
