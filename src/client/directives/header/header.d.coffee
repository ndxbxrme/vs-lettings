'use strict'

angular.module 'vs-lettings'
.directive 'header', ->
  restrict: 'EA'
  templateUrl: 'directives/header/header.html'
  replace: true