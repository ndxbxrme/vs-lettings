'use strict'
superagent = require 'superagent'
objtrans = require 'objtrans'

module.exports = (ndx) ->
  getDefaultProgressions = (property) ->
    property.progressions = []
    ndx.database.select 'progressions',
      isdefault: true
    , (progressions) ->
      for progression in progressions
        property.progressions.push JSON.parse JSON.stringify progression
  calculateMilestones = (property) ->
    if not property
      return
    if property.progressions and property.progressions.length
      updateEstDays = (progressions) ->
        aday = 24 * 60 * 60 * 1000
        fetchMilestoneById = (id, progressions) ->
          for myprogression in progressions
            for mybranch in myprogression.milestones
              for mymilestone in mybranch
                if mymilestone._id is id
                  return mymilestone
        for progression in progressions
          for branch in progression.milestones
            for milestone in branch
              milestone.estCompletedTime = null
        needsCompleting = true
        i = 0
        while needsCompleting and i++ < 5
          for progression in progressions
            delete progression.needsCompleting
            progStart = progression.milestones[0][0].completedTime
            b = 1
            while b++ < progression.milestones.length
              branch = progression.milestones[b-1]
              for milestone in branch
                milestone.overdue = false
                milestone.afterTitle = ''
                if milestone.estCompletedTime
                  continue
                if milestone.completed and milestone.completedTime
                  milestone.estCompletedTime = milestone.completedTime
                  continue
                if milestone.userCompletedTime
                  try
                    milestone.estCompletedTime = new Date(milestone.userCompletedTime).valueOf()
                    continue
                if not milestone.estAfter
                  prev = progression.milestones[b-2][0]
                  milestone.estCompletedTime = (prev.completedTime or prev.estCompletedTime) + (milestone.estDays * aday)
                  continue
                testMilestone = fetchMilestoneById milestone.estAfter, progressions
                if testMilestone
                  if milestone.estType is 'complete'
                    if testMilestone.completedTime or testMilestone.estCompletedTime
                      milestone.estCompletedTime = (testMilestone.completedTime or testMilestone.estCompletedTime) + (milestone.estDays * aday)
                    milestone.afterTitle = " after #{testMilestone.title} completed"
                  else
                    if testMilestone.completedTime or testMilestone.estCompletedTime
                      milestone.estCompletedTime = (testMilestone.completedTime or testMilestone.estCompletedTime) - (testMilestone.estDays * aday) + (milestone.estDays * aday)
                    milestone.afterTitle = " after #{testMilestone.title} started"
                else
                  progression.needsCompleting = true
                  b = progression.milestones.length
                  break
          needsCompleting = false
          for progression in progressions
            if progression.needsCompleting
              needsCompleting = true
        for progression in progressions
          delete progression.needsCompleting 
      updateEstDays property.progressions
      property.milestoneIndex = {}
      gotOverdue = false
      for progression, p in property.progressions
        for branch, b in progression.milestones
          for milestone in branch
            if milestone.userCompletedTime
              milestone.userCompletedTime = new Date(milestone.userCompletedTime).valueOf()
            if new Date().valueOf() > (milestone.userCompletedTime or milestone.estCompletedTime)
              milestone.overdue = true
              if p is 0 and milestone.progressing and not gotOverdue
                property.milestone = milestone
                gotOverdue = true
            if p is 0 and not gotOverdue
              if milestone.completed or milestone.progressing
                property.milestone = milestone
            if milestone.completed #unsure
              property.milestoneIndex[progression._id] = b
      if property.milestone
        property.milestoneStatus = 'progressing'
        if property.milestone.overdue
          property.milestoneStatus = 'overdue'
        if property.milestone.completed
          property.milestoneStatus = 'completed'
        property.cssMilestone = 
          completed: property.milestone.completed
          progressing: property.milestone.progressing
          overdue: property.milestoneStatus is 'overdue'
  fetchCurrentProps = (status) ->
    new Promise (resolve, reject) ->
      opts = 
        RoleType: 'Letting'
        IncludeStc: true
      superagent.post "#{process.env.PROPERTY_URL}/search"
      .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
      .send opts
      .end (err, res) ->
        if not err and res.body.Collection
          resolve res.body.Collection
        else
          reject err      
  fetchPropertyData = (prop) ->
    new Promise (resolve, reject) ->
      prop.lettingData = await ndx.dezrez.get 'role/{id}', null, id:prop.RoleId
      prop.tenantData = await ndx.dezrez.get 'role/{id}', null, id:prop.lettingData.TenantRoleId
      prop.viewings = await ndx.dezrez.get 'role/{id}/viewingsbasic', null, id:prop.RoleId
      prop.extendedData = await ndx.dezrez.get 'property/{id}', null, id:prop.PropertyId
      property = objtrans prop,
        uId: true
        Address: true
        AvailableDate: true
        DateInstructed: true
        LastUpdated: true
        Fees: true
        Images: true
        Price: true
        PropertyId: true
        RoleId: true
        SearchField: true
        Term: true
        Status: 'RoleStatus.SystemName'
        displayAddress: true
        Id: '_id'
        Deposit: 'lettingData.Deposit'
        Landlord: 'lettingData.LandlordInfo[0].Person'
        LandlordName: 'lettingData.LandlordInfo[0].Person.ContactName'
        OfferAcceptedPriceDataContract: 'lettingData.OfferAcceptedPriceDataContract'
        ServiceLevel: 'lettingData.ServiceLevel'
        TenancyReference: 'tenantData.TenancyReference'
        TenancyStatus: 'tenantData.TenancyStatus'
        TenancyType: 'tenantData.TenancyType'
        TenantBaseDeposit: 'tenantData.TenantBaseDeposit'
        Tenant: 'tenantData.TenantInfo[0].Person'
        TenantName: 'tenantData.TenantInfo[0].Person.ContactName'
        EstimatedStartDate: 'tenantData.EstimatedStartDate'
        Viewings: 'viewings'
        SpecialArrangements: 'extendedData.SpecialArrangements'
      resolve property
  checkNew = ->
    currentProps = await fetchCurrentProps()
    for prop in currentProps
      prop.uId = prop.RoleId + '_' + new Date(prop.AvailableDate).valueOf()
      dbProperty = await ndx.property.fetch prop.uId
      if dbProperty
        #if prop.LastUpdated isnt dbProperty.LastUpdated
        if ['OfferAccepted', 'InstructionToLet'].includes prop.RoleStatus.SystemName
          property = await fetchPropertyData prop
          Object.assign dbProperty, property
        else
          dbProperty.Status = prop.RoleStatus.SystemName
        calculateMilestones dbProperty
        ndx.database.update 'properties', dbProperty,
          _id: dbProperty._id
      else
        property = await fetchPropertyData prop
        getDefaultProgressions property
        calculateMilestones property
        property.delisted = false
        property.milestone = ''
        property.milestoneStatus = ''
        property.milestoneIndex = null
        property.notes = []
        property.chainBuyer = []
        property.chainSeller = []
        ndx.database.insert 'properties', property
  ndx.database.on 'ready', ->
    setInterval checkNew, 10 * 60 * 1000
    checkNew()
  
  ndx.property = 
    getDefaultProgressions: 'getDefaultProgressions'
    checkNew: checkNew
    fetch: (uId, cb) ->
      new Promise (resolve, reject) ->
        property = await ndx.database.selectOne 'properties', uId: uId
        resolve property
        cb? property