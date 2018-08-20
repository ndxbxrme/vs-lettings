angular.module 'vs-lettings'
.filter 'flatten', ->
  (input) ->
    output = []
    if input
      for group in input
        for milestone in group
          output.push milestone
    output