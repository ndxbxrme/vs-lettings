'use strict'

angular.module 'vs-agency'
.controller 'SolicitorsCtrl', ($scope, env) ->
  $scope.solicitors = []
  reduce = (name) ->
    (name or 'Unknown').toLowerCase().replace(/solicitor(s*)/g, '').replace(/law|llp/g,'').replace(/ll/g, 'l').replace(/ [a-z] /, '').replace(' & ', '').replace(' and ', '').replace(/\s+/g, '')
  getSolicitor = (name) ->
    for solicitor in $scope.solicitors
      if reduce(solicitor.name) is reduce(name)
        return solicitor
    solicitor =
      id: $scope.solicitors.length
      name: name or 'Unknown'
      properties: []
    $scope.solicitors.push solicitor
    solicitor
  pushProperty = (solicitor, property, role) ->
    for prop in solicitor.properties
      if prop.RoleId is property.RoleId
        prop[role] = solicitor.id
        return prop
    property[role] = solicitor.id
    solicitor.properties.push property
    return property
  $scope.propsOpts = 
    where:
      RoleStatus: 'OfferAccepted'
      RoleType: 'Letting'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.properties = $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.propsOpts
  , (properties) ->
    for property in properties.items
      property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}, #{property.Address.Postcode}"
      property.$case = $scope.single 'properties', property.RoleId, (item) ->
        item.locked = true
        if item.item
          item.item.override = item.item.override or {}
          override = item.item.override
          if not override.deleted
            item.$parent.address = override.address or item.$parent.displayAddress
            item.$parent.commission = override.commission or item.item.role.Commission
            item.$parent.date = new Date(override.date or item.item.startDate or item.item.progressions[0].milestones[0][0].startTime).valueOf()
            solicitor = getSolicitor item.item.purchasersSolicitor?.role
            pushProperty solicitor, item.$parent, 'purchaser'
            solicitor = getSolicitor item.item.vendorsSolicitor?.role
            pushProperty solicitor, item.$parent, 'vendor'
      property.$case.$parent = property
  $scope.open = (selectedSolicitor) ->
    open = selectedSolicitor.open
    for solicitor in $scope.solicitors
      solicitor.open = false
    selectedSolicitor.open = not open