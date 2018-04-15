'use strict'

angular.module 'vs-agency'
.directive 'milestone', ($rootScope, progressionPopup) ->
  restrict: 'AE'
  templateUrl: 'directives/milestone/milestone.html'
  replace: true
  scope:
    milestone: '=data'
    disabled: '@'
  link: (scope, elem, attrs) ->
    scope.getClass = ->
      completed: scope.milestone.completed
      progressing: scope.milestone.progressing
      overdue: if scope.milestone.completed then false else (scope.milestone.progressing and new Date().valueOf() > (scope.milestone.userCompletedTime or scope.milestone.estCompletedTime))
    scope.itemClick = ->
      if scope.disabled isnt 'true'
        myscope = scope
        while myscope and not property = myscope.property
          myscope = myscope.$parent
        progressionPopup.show elem[0], scope.milestone, property
      #$rootScope.$emit 'swiper:show' 
    