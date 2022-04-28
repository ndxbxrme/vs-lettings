angular.module('angular-flipclock', []).directive 'flipClock', [
  '$parse'
  ($parse) ->
    {
      replace: true
      template: '<div></div>'
      restrict: 'E'
      link: (scope, element, attr) ->
        optionKeys = [
          'autostart'
          'countdown'
          'callbacks'
          'classes'
          'clockFace'
          'defaultclockface'
          'defaultlanguage'
          'showSeconds'
        ]
        options = callbacks: {}
        clock = undefined
        methods = [
          'start'
          'stop'
          'setTime'
          'setCountdown'
          'getTime'
        ]
        callbacks = [
          'destroy'
          'create'
          'init'
          'interval'
          'start'
          'stop'
          'reset'
        ]
        #set options from attributes
        optionKeys.forEach (key) ->
          if attr[key]
            switch key
              when 'autostart'
                options['autoStart'] = if attr[key] == 'false' then false else true
              when 'defaultclockface'
                options['defaultClockFace'] = attr[key]
              when 'defaultlanguage'
                options['defaultLanguage'] = attr[key]
              else
                options[key] = attr[key]
                break
          return
        #init callbacks
        callbacks.forEach (callback) ->
          if attr[callback]

            options.callbacks[callback] = ->
              $parse(attr[callback]) scope
              return

          return
        #generate clock object
        #clock = new FlipClock(element, options);
        clock = $.fn.FlipClock(element, options)
        #bind methods to the scope
        methods.forEach (method) ->

          scope[method] = ->
            clock[method].apply clock, arguments

          return
        return

    }
]

# ---
# generated by js2coffee 2.2.0