http = require 'http'
Configuration = require './config'

class ApiClient
  @paths = {
    moin: '/moin'
    newUser: '/user'
    login: '/user/session',
    getUser: '/user/:name'
  }
  @apiKey = 'ef19d485-4259-439e-933e-8c6caf8476f7'
  
  constructor: (@session) ->
    # may set session
    
  setSession: (sessionToken) ->
    @session = sessionToken
  
  createRequest: (method, path, callback) ->
    console.log method, path
    
    path += '?api_key=' + ApiClient.apiKey
    if @session
      path += '&session=' + @session
      
    config = Configuration.getConfiguration()
    
    http.request {
      hostname: config.get('host'),
      port: config.get('port'),
      path: path,
      method: method,
      headers: {
        'User-Agent': 'moinapp-cli'
        'Content-Type': 'application/json'
      }
    }, callback
    
  getJSONRequest: (method, path, callback) ->
    @createRequest method, path, (res) ->
      res.setEncoding 'utf8'
      
      res.on 'data', (buffer) ->
        json = JSON.parse buffer.toString()
        
        if res.statusCode == 200
          callback null, json
        else
          callback new Error json.code + ": " + json.message
    
  writeJSONRequest: (method, path, json, callback) ->
    req = @getJSONRequest method, path, callback
    
    req.write JSON.stringify json
    
    req
    
  login: (username, password, callback) ->
    credentials = {
      username: username,
      password: password
    }
    
    @writeJSONRequest 'POST', ApiClient.paths.login, credentials, (err, json) =>
      if !!err || json.code != "Success"
        callback err || new Error json.code
      else
        @session = json.session
        callback null, @session
    .end()
    
  createNewUser: (username, password, email, callback) ->
    user = {
      username: username,
      password: password,
      email: email
    }
    
    @writeJSONRequest 'POST', ApiClient.paths.newUser, user, (err, json) ->
      if !!err || json.code != "Success"
        callback err || new Error json.code
      else
        @session = json.session
        callback null, @session
    .end()
    
  getUser: (username, callback) ->
    path = ApiClient.paths.getUser.replace /:name/, username
    
    @getJSONRequest 'GET', path, (err, json) ->
      if !!err
        callback err || new Error json.code
      else
        callback null, json
    .end()
    
  moin: (userId, callback) ->
    to = {
      to: userId
    }
    
    @writeJSONRequest 'POST', ApiClient.paths.moin, to, (err, json) ->
      if !!err || json.code != 'Success'
        callback err || new Error json.code
      else
        callback null, json
    .end()
  moinUsername: (username, callback) ->
    @getUser username, (err, user) =>
      if !!err
        return callback err
      userId = user.id
      
      @moin userId, callback

module.exports = ApiClient
