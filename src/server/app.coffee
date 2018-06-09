'use strict'

require 'ndx-server'
.config
  database: 'db'
  tables: ['users', 'properties', 'progressions', 'emailtemplates', 'smstemplates', 'dashboard', 'targets', 'shorttoken']
  localStorage: './data'
  hasInvite: true
  hasForgot: true
  softDelete: true
  publicUser:
    _id: true
    displayName: true
    local:
      email: true
    roles: true
.use (ndx) ->
  ndx.email.send
    to: 'lewis_the_cat@hotmail.com'
    from: 'VitalSpace <progression@vitalspace.co.uk>'
    subject: 'Vitalspace test'
    body: 'it arrived'
  , (err, response) ->
    console.log 'ERROR', err
  console.log 'sent email'
.start()
