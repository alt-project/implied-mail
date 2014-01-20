
base = require './base'

class Mailer extends base.Mailer

  constructor: (app)->
    super
    @sendgrid = require("sendgrid")(@app.get('email_username'), @app.get 'email_password')

  # Send an email.
  #
  # @param opts.body {string}
  # @param opts.subject {string}
  # @param opts.from {string}
  # @param opts.to {array}
  send_mail: (opts, callback) ->
    defaults = 
      from: @default_from
      text: opts.body
      headers:
        'X-SMTPAPI': '{"category": '+(@app.get 'name')+'}'
    
    files = opts.files or []
    delete opts.files

    init = {}
    
    for k,v of defaults
      init[k] = v
    
    for k,v of opts
      init[k] = v

    email = new @sendgrid.Email init

    for file in files
      email.addFile file

    @sendgrid.send email, (success, message) ->
      console.error message unless success
      err = null
      if not success then err = message
      callback?(err)

module.exports = (app)->
  console.log 'initializing'
  unless app.get('name')
    throw 'Please name your app. app.set("name",...)'
  app.set 'mailer', new Mailer app