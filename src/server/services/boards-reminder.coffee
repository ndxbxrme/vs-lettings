{ zonedTimeToUtc, utcToZonedTime, format } = require 'date-fns-tz'

millisecondsUntilNextWednesdayAt10am = ->
  now = new Date
  timeZone = 'Europe/London'
  # Time zone for the United Kingdom
  # Convert the current time to the UK time zone
  nowInUKTimeZone = utcToZonedTime(now, timeZone)
  nextWednesday = new Date(nowInUKTimeZone)
  nextWednesday.setHours 10, 0, 0, 0
  # Determine the day difference to next Wednesday
  daysUntilWednesday = (10 - nowInUKTimeZone.getDay()) % 7 or 7
  nextWednesday.setDate nextWednesday.getDate() + daysUntilWednesday
  nextWednesday.getTime() - nowInUKTimeZone.getTime()

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
      setTimeout sendEmail, millisecondsUntilNextWednesdayAt10am()
    setTimeout sendEmail, millisecondsUntilNextWednesdayAt10am()   