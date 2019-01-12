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
  console.log 'encryption key', process.env.ENCRYPTION_KEY
  ndx.email.send
    to: 'lewis_the_cat@hotmail.com'
    from: 'progression@vitalspace.co.uk'
    subject: 'this is a test'
    body: 'p i\'m testing'
  , (response) ->
    console.log 'email response', response
.start()