'use strict'

require 'ndx-server'
.config
  database: 'db'
  tables: ['users', 'properties', 'progressions', 'emailtemplates', 'smstemplates', 'dashboard', 'targets', 'shorttoken']
  localStorage: './data'
.start()
