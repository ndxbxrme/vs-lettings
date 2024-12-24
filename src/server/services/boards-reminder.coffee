{ zonedTimeToUtc, utcToZonedTime, format } = require 'date-fns-tz'

millisecondsUntil10am = ->
  now = new Date
  timeZone = 'Europe/London'
  # Time zone for the United Kingdom
  # Convert the current time to the UK time zone
  nowInUKTimeZone = utcToZonedTime(now, timeZone)
  tenAM = new Date(nowInUKTimeZone)
  tenAM.setHours 10, 0, 0, 0
  if nowInUKTimeZone.getHours() >= 10 or nowInUKTimeZone.getTime() > tenAM.getTime()
    tenAM.setDate tenAM.getDate() + 1
  # Format the dates for display
  formatOptions = 
    timeZone: timeZone
    hour: '2-digit'
    minute: '2-digit'
  tenAMString = format(tenAM, 'HH:mm', formatOptions)
  nowString = format(nowInUKTimeZone, 'HH:mm', formatOptions)
  tenAM.getTime() - nowInUKTimeZone.getTime()

module.exports = (ndx) ->
  ndx.database.on 'ready', ->
    sendEmail = ->
      if new Date().getDay() is 3
        ndx.database.select 'emailtemplates',
          name: 'Auto Reminder - Boards'
        , (templates) -> 
          if templates and templates.length
            ndx.database.select 'users', null, (users) ->
              if users and users.length
                for user in users
                  templates[0].to = user.local.email
                  ndx.email.send templates[0]
      setTimeout sendEmail, millisecondsUntil10am()
    setTimeout sendEmail, millisecondsUntil10am()   