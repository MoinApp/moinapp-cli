http = require 'http'

class ApiClient
  @paths = {
    login: '/user/session'
  }
  
  @session = null
  
  createRequest: (method, path, callback) ->
    if @session
      path += '?session=' + @session
    
    http.request {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    }, callback
    
  writeJSONRequest: (method, path, json, callback) ->
    req = @createRequest method, path, callback
    
    req.write JSON.stringify json
    
    req
    
  login: (username, password, callback) ->
    credentials = {
      username: username,
      password: password
    }
    
    @writeJSONRequest 'POST', ApiClient.paths.login, credentials, (res) ->
      res.on 'data', callback
    .end()

module.exports = ApiClient
