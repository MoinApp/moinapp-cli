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
      .command('logout')
        .description('Logout and delete the session token.')
        .action( =>
          @logout()
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
      .command('find [username]')
        .description('Returns a list of usernames beginning with the specified query term.')
        .action( (username) =>
          @findUser username
        )
    program
      .command('recents')
        .description('List the recent users you moin\'ed.')
        .action( =>
          @getRecents()
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
          
  logout: ->
    if !!@config.get 'session'
      read { prompt: "Do you really want to logout? ", default: 'Y' }, (err, answer) =>
        throw err if !!err
      
        if answer.toUpperCase() == 'Y'
          @setConfig 'session', undefined
    else
      console.log colors.warn 'You are not logged in.'
      
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
      console.log colors.ok("[USER]"), user
      
  findUser: (username) ->
    @client.findUser username, (err, data) =>
      if !!err
        return @apiError err
        
      users = []
      data.message.forEach (user) ->
        users.push user.username
        
      console.log colors.info("Users starting with #{username}:"), colors.ok JSON.stringify users
      
  getRecents: ->
    @client.getRecents (err, data) =>
      if !!err
        return @apiError err
        
      users = []
      data.message.forEach (user) ->
        users.push user.username
        
      console.log colors.info("Your recents:"), colors.ok JSON.stringify users
      
  moinUser: (username) ->
    @client.moinUsername username, (err, data) =>
      if !!err
        return @apiError err
      console.log colors.ok("Moin sent."), data
      
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
