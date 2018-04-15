'use strict'

angular.module 'vs-lettings'
.directive 'menu', ($rootScope, $state) ->
  restrict: 'EA'
  templateUrl: 'directives/menu/menu.html'
  replace: true
  link: ->
    $rootScope.state = (route) ->
      if $state and $state.current
        if Object.prototype.toString.call(route) is '[object Array]'
          return route.indexOf($state.current.name) isnt -1
        else if route
          return route is $state.current.name
        else
          return $state.current.name
      false