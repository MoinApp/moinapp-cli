pkg = require '../package'
program = require 'commander'
ApiClient = require './apiClient'

program
  .version(pkg.version)
  .option('-l --login [username]', 'Login. Requires username and password', false)
  .option('-p --password [password]', 'Enter password for username. Requires -l option.', false)
  .parse(process.argv)
  
if program.login
  console.log program.login
  if !program.password
    console.log "You need to specify username and password if you want to login."
  else
    username = program.login
    password = program.password
    client = new ApiClient
    
    console.log "Login for user " + username + "..."
    client.login username, password, (buffer) ->
      console.log buffer
    
