'use strict'

angular.module 'ndx'
.factory 'FileUtils', (Upload) ->
  put = (object, path, value) ->
    if typeof path is 'string'
      path = path.split '.'
    if not (path instanceof Array) or path.length is 0
      return false
    path = path.slice()
    key = path.shift()
    if typeof object isnt 'object' or object is null
      return false
    if path.length is 0
      object[key] = value
    else
      if not object[key]
        object[key] = {}
      if typeof object[key] isnt 'object' or object[key] is null
        return false
      return put object[key], path, value
  uploadFn: ($scope, errFn) ->
    (path, files, errFiles) ->
      $scope.uploading = true
      if errFiles and errFiles.length
        $scope.uploading = false
        errFn? errFiles
        return
      type = Object.prototype.toString.call files
      if files and ((type is '[object Array]' and files.length) or (type is '[object File]'))
        Upload.upload
          url: '/api/upload'
          data:
            file: files
        .then (response) ->
          $scope.uploading = false
          if response.data
            for document in response.data
              put $scope, path, document
        , (err) ->
          $scope.uploading = false
          false
        , (progress) ->
          $scope.uploadProgress = Math.min 100, parseInt(100.0 * progress.loaded / progress.total)
      else
        $scope.uploading = false