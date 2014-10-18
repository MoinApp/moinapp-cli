url = require 'url'
restify = require 'restify'
{ Configuration } = require './config'

class APIClient
  @apiPaths = {
    login: '/api/auth',
    newUser: '/api/signup',
    getUser: '/api/user/:username',
    moin: '/api/moin'
  }
  @appID = "moinapp-cli"
  
  constructor: ->
    @config = Configuration.getConfiguration()
    @session = @config.get 'session'
    
    uri = url.format {
      protocol: 'http',
      hostname: @config.get('host'),
      port: @config.get('port')
    }
    @client = restify.createJsonClient {
      url: uri,
      version: "2.0.0",
      userAgent: 'moinapp-cli'
    }
    
  authenticatePath: (path) ->
    if !!@session
      urlObject = url.parse path, true, true
      urlObject.query.session = @session
      path = url.format urlObject
      
    return path
  logRequest: (method, path, payload = null) ->
    # create a copy or else we are not going to pass those parameters to the server!
    loggedPayload = {}
    `for ( var attr in payload ) {
      loggedPayload[attr] = payload[attr];
    }`
    if !!loggedPayload
      # remove unwanted parameters from stdout!
      if !!loggedPayload.password
        delete loggedPayload.password
      if !!loggedPayload.application
        delete loggedPayload.application
      
    console.log method, path, loggedPayload
  
  doGET: (path, callback) ->
    @logRequest "GET", path
    path = @authenticatePath path
    
    @client.get path, (err, req, res, obj) =>
      callback? err, obj
      @client.close()

  doPOST: (path, payload, callback) ->
    @logRequest "POST", path, payload
    path = @authenticatePath path
    
    @client.post path, payload, (err, req, res, obj) =>
      callback? err, obj
      @client.close()
      
  # Operation functions
  _parseLoginResponse: (response) ->
    if response.code == "Success"
      @session = response.message
      @config.set 'session', @session
  
  login: (username, password, callback) ->
    payload = {
      username: username,
      password: password,
      application: APIClient.appID
    }
    
    @doPOST APIClient.apiPaths.login, payload, (err, response) =>
      return callback err, response if !!err
      
      @_parseLoginResponse response
      
      callback err, @session
      
  createNewUser: (username, password, email, callback) ->
    payload = {
      username: username,
      password: password,
      email: email,
      application: APIClient.appID
    }
    
    @doPOST APIClient.apiPaths.newUser, payload, (err, response) =>
      return callback err, response if !!err
      
      @_parseLoginResponse response
      
      callback err, @session
      
  getUser: (username, callback) ->
    path = APIClient.apiPaths.getUser.replace /:username/, username
    
    @doGET path, (err, response) ->
      callback? err, response.message
      
  moinUsername: (username, callback) ->
    payload = {
      username: username
    }
    
    @doPOST APIClient.apiPaths.moin, payload, callback

module.exports.APIClient = APIClient
