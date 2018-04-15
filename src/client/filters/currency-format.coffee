'use strict'

angular.module 'vs-agency'
.filter 'currencyFormat', ($sce) ->
  (val) ->
    if angular.isDefined(val)
      if val.toString().indexOf('.') isnt -1
        bits = val.toString().split '.'
        val = bits[0] + '.<sub>' + bits[1] + '</sub>'
    else
      val = ''
    $sce.trustAs 'html', val.toString()