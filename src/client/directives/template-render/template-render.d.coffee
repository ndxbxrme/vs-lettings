'use strict'

angular.module 'vs-agency'
.directive 'templateRender', ($timeout) ->
  restrict: 'AE'
  replace: true
  require: 'ngModel'
  template: '<div class="template-render"></div>'
  scope: 
    data: '='
    ngModel: '='
  link: (scope, elem, attrs, ngModel) ->
    fillTemplate = (template, data) ->
      template.replace /\{\{(.+?)\}\}/g, (all, match) ->
        evalInContext = (str, context) ->
          (new Function("with(this) {return #{str}}"))
          .call context
        evalInContext match, data
    render = ->
      try
        elem[0].innerText = fillTemplate scope.ngModel, scope.data
      catch e
        false
    ngModel.$formatters.unshift (val) ->
      render()
      val
    scope.$watch 'data', (n, o) ->
      if n
        $timeout render, 500