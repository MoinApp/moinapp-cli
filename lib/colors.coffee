clc = require 'cli-color'

exports.info = clc.blue
exports.ok = clc.green
exports.warn = clc.yellow.blink
exports.error = clc.red.bold
