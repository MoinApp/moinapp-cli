pkg = require '../package'
program = require 'commander'
ApiClient = require './apiClient'
Configuration = require './config'

config = Configuration.getConfiguration()
config.load()

program
  .version(pkg.version)
  .option('-s --session [session]', 'Session token.', false)
  .option('-l --login [username]', 'Login. Requires username and password', false)
  .option('-c --create [username]', 'Create a new user. Requires username, password and email.', false)
  .option('-p --password [password]', 'Enter password for username. Requires -l option.', false)
  .option('-e --email [email]', 'Enter email for new user. Required for -c option.', false)
  .option('-g --get [username]', 'Returns the given user.', false)
  .option('--config [key:value]', 'Sets the config key with the given value.', null)
  .parse(process.argv)
  
if program.session
  config.set 'session', program.session
  
client = new ApiClient config.get('session')

if program.create
  username = program.create
  password = program.password
  email = program.email
  
  client.createNewUser username, password, email, (err, username) ->
    if !!err
      throw err
    console.log username, "created and logged in."
    config.set 'session', session
  
else if program.login
  if !program.password
    console.log "You need to specify username and password if you want to login."
  else
    username = program.login
    password = program.password
    
    console.log "Login for user " + username + "..."
    client.login username, password, (err, session) ->
      if !!err
        throw err
      console.log "Logged in."
      config.set 'session', session
else if program.get
  username = program.get

  client.getUser username, (err, user) ->
    console.log 'User "' + username + '": ' + user
else if program.args.length > 0
  moinUsername = program.args[0]
  
  client.moinUsername moinUsername, (err, data) ->
    console.log "Moin sent:", data
    
else if program.config
  
  configs = program.config.split ':'
  if configs.length != 2
    program.help()
  else
    
    key = configs[0]
    value = configs[1]
    
    console.log 'Writing config key "' + key + '" as "' + value + '".'
    config.set key, value
  
else
  program.help()
