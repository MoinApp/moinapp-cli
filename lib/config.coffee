fs = require 'fs'

class Configuration
  @filename = 'config.json'
  @encoding = 'utf8'
  
  constructor: (@data) ->
    if !@data
      @data = {}
    
  load: ->
    exists = fs.existsSync Configuration.filename
    if !exists
      return
    
    data = fs.readFileSync Configuration.filename, Configuration.encoding
    
    @data = JSON.parse data
      
  save: ->
    string = JSON.stringify @data
    
    fs.writeFile Configuration.filename, string, (err) ->
      if !!err
        throw err
        
      console.log "Config saved."
      
  get: (key) ->
    @data[key]
  set: (key, value) ->
    @data[key] = value
    @save()

module.exports = Configuration
