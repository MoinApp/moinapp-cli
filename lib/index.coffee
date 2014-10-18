pkg = require '../package'
program = require 'commander'
{ APIClient } = require './apiClient'
{ Configuration } = require './config'

class MoinCLI
  config: null
  client: null
  
  constructor: () ->
    
    
  main: ->
    @config = Configuration.getConfiguration()
    @registerCLIApp()
    
    @client = new APIClient
    @parse()
    
  registerCLIApp: ->
    program
      .version(pkg.version)
      .option('-l --login [username]', 'Login. Requires username and password', false)
      .option('-c --create [username]', 'Create a new user. Requires username, password and email.', false)
      .usage('[options] username')
      .option('-p --password [password]', 'Enter password for username. Requires -l option.', false)
      .option('-e --email [email]', 'Enter email for new user. Required for -c option.', false)
      .option('-g --get [username]', 'Returns the given user.', false)
      .option('--set [key:value]', 'Sets the config key with the given value.', null)
      .option('--config', 'Shows the current configuration.')
      .parse(process.argv)
      
  apiError: (error) ->
    formattedMessage = error
    if !!error.restCode && !!error.message
      formattedMessage = error.restCode + ": " + error.message
    console.log "Error communicating with server.", formattedMessage
      
  parse: ->
    if program.create
      @createAccount program.create, program.password, program.email
    else if program.login
      @login program.login, program.password
    else if program.get
      @getUser program.get
    else if program.set
      split = program.set.split ":"
      if split.length >= 2
        key = split[0]
        value = split[1]
        
        @setConfig key, value
      else
        console.log 'Please specify "key:value".'
    else if program.config
      @showConfig()
    else if program.args.length > 0
      @moinUser program.args[0]
    else
      program.help()
      
  createAccount: (username, password, email) ->
    if not username or not password or not email
      return console.log "You need to specify username, password and email!"
    
    @client.createNewUser username, password, email, (err, session) =>
      @loginSuccessHandler err, session
      
  login: (username, password) ->
    if not username or not password
      return console.log "You need to specify username and password!"
    
    console.log "Logging in with username \"#{username}\"..."
    @client.login username, password, (err, session) =>
      @loginSuccessHandler err, session
      
  loginSuccessHandler: (err, session) ->
    if !!err
      return @apiError err
    
    @config.set 'session', session
    console.log "Logged in."
    
  getUser: (username) ->
    @client.getUser username, (err, user) =>
      if !!err
        return @apiError err
      console.log "[USER]", user
      
  moinUser: (username) ->
    @client.moinUsername username, (err, data) =>
      if !!err
        return @apiError err
      console.log "Moin sent.", data
      
  setConfig: (key, value) ->
    console.log 'Writing value "' + value + '" for config key "' + key + '".'
    @config.set key, value
  showConfig: ->
    @config.print()

main = ->
  app = new MoinCLI
  app.main()
module.exports = ->
  # reduce stack trace and also remove traces of js
  setImmediate ->
    main()
