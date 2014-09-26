fs = require 'fs'

class Configuration
  @filename = 'config.json'
  @encoding = 'utf8'
  @defaults = {
    host: 'localhost'
    port: 3000
  }
  
  @_instance = null
  @getConfiguration: ->
    if not @_instance
      @_instance = new Configuration
    @_instance
  
  
  constructor: (@data) ->
    
    
  load: ->
    exists = fs.existsSync Configuration.filename
    if !exists
      return
    
    data = fs.readFileSync Configuration.filename, Configuration.encoding
    
    try
      @data = JSON.parse data
    catch e
      #console.log "Invalid config. Did not load anything and started file from scratch."
      @data = Configuration.defaults
      @save()
      
  save: ->
    string = JSON.stringify @data
    
    fs.writeFile Configuration.filename, string, (err) ->
      if !!err
        throw err
        
      #console.log "Config saved."
      
  get: (key) ->
    @data[key]
  set: (key, value) ->
    @data[key] = value
    @save()

module.exports = Configuration
