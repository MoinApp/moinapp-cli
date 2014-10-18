fs = require 'fs'

class Configuration
  @filename = 'config.json'
  @encoding = 'utf8'
  @defaults = {
    host: 'moinapp.herokuapp.com'
    port: 80
  }
  
  @_instance = null
  @getConfiguration: ->
    if not Configuration._instance
      Configuration._instance = new Configuration
      Configuration._instance.load()
    Configuration._instance
  
  
  constructor: (@data = {}) ->
    @filename = path.join path.dirname(require.main.filename), Configuration.filename
    
  loadDefault: ->
    @data = Configuration.defaults
    @save()
    
  load: ->
    exists = fs.existsSync @filename
    if !exists
      return @loadDefault()
    
    data = fs.readFileSync @filename, Configuration.encoding
    
    try
      @data = JSON.parse data
    catch e
      #console.log "Invalid config. Did not load anything and started file from scratch."
      @loadDefault()
      
  save: ->
    string = JSON.stringify @data
    
    fs.writeFile @filename, string, (err) ->
      if !!err
        throw err
        
      #console.log "Config saved."
      
  get: (key) ->
    @data[key]
  set: (key, value) ->
    @data[key] = value
    @save()

module.exports.Configuration = Configuration
