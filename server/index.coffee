#!/usr/bin/env iced
process.env['TMP'] = '/data/tmp'
WebnodeApp = require 'webnode'
# WebnodeApp.Cluster.run ()->
app = new WebnodeApp(__dirname)
app.run()