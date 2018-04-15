'use strict'

angular.module 'vs-agency'
.directive 'jadeRender', ($timeout) ->
  restrict: 'AE'
  replace: true
  require: 'ngModel'
  template: '<iframe></iframe>'
  scope: 
    data: '='
    ngModel: '='
  link: (scope, elem, attrs, ngModel) ->
    doc = elem[0].contentWindow.document
    render = ->
      try
        doc.body.innerHTML = jade.render scope.ngModel, scope.data
      catch e
        false
    ngModel.$formatters.unshift (val) ->
      render()
      val
    scope.$watch 'data', (n, o) ->
      if n
        $timeout render, 500