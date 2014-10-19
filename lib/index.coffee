pkg = require '../package'
program = require 'commander'
read = require 'read'
{ APIClient } = require './apiClient'
{ Configuration } = require './config'
colors = require './colors'

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
    program
      .command('login')
        .description('Login and save the session token.')
        .action( =>
          @login()
        )
    program
      .command('signup')
        .description('Sign up for a new account and save the session token.')
        .action( =>
          @createAccount()
        )
    program
      .command('get [username]')
        .description('Retrives information about the given user.')
        .action( (username) =>
          @getUser username
        )
    program
      .command('config-show')
        .description('Shows the content of configuration file.')
        .action( =>
          @showConfig()
        )
    program
      .command('config-set [key] [value]')
        .description('Sets the specified value for the configuration key.')
        .action( (key, value) =>
          @setConfig key, value
        )
    program
      .command('*')
        .description('Send a moin to the user.')
        .action( (username) =>
          @moinUser username
        )
        
  parse: ->
    program.parse process.argv
    if !program.args.length
      program.help()
      
  apiError: (error) ->
    formattedMessage = error
    if !!error.restCode && !!error.message
      formattedMessage = error.restCode + ": " + error.message
    console.log colors.error("Error communicating with server."), colors.error(formattedMessage)
    
  getReadInput: (prompt, isSilent, callback) ->
    read { prompt: prompt, silent: isSilent }, (err, result) ->
      throw err if !!err
      
      callback? result
  getSilentInput: (prompt, callback) ->
    @getReadInput prompt, true, callback
  getInput: (prompt, callback) ->
    @getReadInput prompt, false, callback
  
  login: ->
    @getInput "Username: ", (username) =>
      @getSilentInput "Password: ", (password) =>
        if not username or not password
          return console.log "You need to specify username and password!"
    
        console.log "Logging in with username \"#{username}\"..."
        @client.login username, password, (err, session) =>
          @loginSuccessHandler err, session
      
  createAccount: ->
    @getInput "Username: ", (username) =>
      @getSilentInput "Password: ", (password) =>
        @getInput "Email: ", (email) =>
          if not username or not password or not email
            return console.log "You need to specify username, password and email!"
    
          @client.createNewUser username, password, email, (err, session) =>
            @loginSuccessHandler err, session
      
  loginSuccessHandler: (err, session) ->
    if !!err
      return @apiError err
    
    @config.set 'session', session
    console.log colors.ok "Logged in."
    
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
    console.log 'Writing value "' + colors.info(value) + '" for config key "' + colors.info(key) + '".'
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
