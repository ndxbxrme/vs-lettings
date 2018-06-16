'use strict'

angular.module 'vs-lettings', [
  'ndx'
  'ui.router'
  'multi-check'
  'ui.gravatar'
  'ngFileUpload'
  'vs-agency'
  'yaru22.angular-timeago'
]
.config ($locationProvider, $urlRouterProvider, gravatarServiceProvider) ->
  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true
  gravatarServiceProvider.defaults =
    size: 16
    "default": 'mm'
    rating: 'pg'
  console.log '%c', 'font-size:3rem; background:#f15b25 url(https://conveyancing.vitalspace.co.uk/public/img/VitalSpaceLogo-2016.svg);background-size:cover;background-repeat:no-repeat;padding-left:18rem;border:1rem solid #f15b25;border-radius:1rem'
.run ($rootScope, $state, progressionPopup, $http, $transitions, ndxModal, env) ->
  $http.defaults.headers.common.Authorization = "Bearer #{env.PROPERTY_TOKEN}"
  $rootScope.state = (route) ->
    if $state and $state.current
      if Object.prototype.toString.call(route) is '[object Array]'
        return route.indexOf($state.current.name) isnt -1
      else
        return route is $state.current.name
    false
  $transitions.onBefore {}, (trans) ->
    if trans.$from().name
      progressionPopup.hide()
      $('body').removeClass "#{trans.$from().name}-page"
  $transitions.onFinish {}, (trans) ->
    if trans.$to().name
      $('body').addClass "#{trans.$to().name}-page"
  $rootScope.makeDownloadUrl = (document) ->
    if document
      '/api/download/' + btoa JSON.stringify({path:document.path,filename:document.originalFilename})
  root = Object.getPrototypeOf $rootScope
  root.generateId = (len) ->
    letters = "abcdefghijklmnopqrstuvwxyz0123456789"
    output = ''
    i = 0
    while i++ < len
      output += letters[Math.floor(Math.random() * letters.length)]
    output
  root.hidePopup = (ev) ->
    progressionPopup.hide()
try
  angular.module 'ndx'
catch e
  angular.module 'ndx', [] #ndx module stub
angular.module 'vs-agency', []