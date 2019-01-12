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
  console.log process.env.EMAIL_OVERRIDE
  ndx.email.send
    to: 'lewis_the_cat@hotmail.com'
    from: 'progression@vitalspace.co.uk'
    subject: 'this is a test'
    text: 'i\'m testing'
.start()