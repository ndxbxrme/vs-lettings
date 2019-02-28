'use strict'
superagent = require 'superagent'
progress = require 'progress'
marked = require 'marked'

module.exports = (ndx) ->
  ndx.app.post '/api/properties/send-request-email', ndx.authenticate(), (req, res, next) ->
    template = await ndx.database.selectOne 'emailtemplates',
      name: req.body.type + ' Request'
    if not template
      return res.end 'No template'
    if not ndx.email
      requre res.end 'No email package'
    Object.assign template, req.body
    template.toFirstName = template.toName.substr 0, template.toName.indexOf(' ')
    template.refFirstName = template.refName.substr 0, template.refName.indexOf(' ')
    template.to = req.body.toMail
    #template.text = marked template.text
    ndx.email.send template
    req.body.property.notes = req.body.property.notes or []
    req.body.property.notes.push
      date: new Date()
      text: """
        # Request #{req.body.type}
        ### Date
        #### #{new Date().toDateString()}
        ### Requested by
        #### #{ndx.user.displayName or ndx.user.local.email}
        ### #{req.body.type} Name
        #### #{req.body.toName}
        ### Regarding
        #### #{req.body.refName}
      """
      item: req.body.type + ' Request'
      side: ''
      user: ndx.user
    ndx.database.update 'properties',
      notes: req.body.property.notes
    ,
      _id: req.body.property._id
    res.end('OK')
  ndx.app.post '/api/properties/send-accept-email', ndx.authenticate(), (req, res, next) ->
    console.log 'sae'
    if ndx.email
      console.log 'em'
      user = ndx.user
      ndx.database.select 'emailtemplates',
        name: 'Application Accepted - ' + req.body.applicant.employment
      , (templates) ->
        console.log 'tm', templates
        if templates and templates.length
          templates[0].applicant = req.body.applicant
          templates[0].property = req.body.property
          templates[0].user = user
          templates[0].to = req.body.applicant.email
          ndx.email.send templates[0]
    res.end 'OK'
  ndx.app.post '/api/properties/send-marketing-email', ndx.authenticate(), (req, res, next) ->
    if ndx.email
      user = ndx.user
      ndx.database.select 'emailtemplates',
        name: 'Marketing Email'
      , (templates) ->
        if templates and templates.length
          templates[0].marketing = req.body.marketing
          templates[0].user = user
          templates[0].to = 'richard@vitalspace.co.uk'
          ndx.email.send templates[0]
    res.end 'OK'
  ndx.app.get '/api/properties/reset-progressions', ndx.authenticate(['admin','superadmin']), (req, res, next) ->
    ndx.database.select 'properties', null, (properties) ->
      if properties and properties.length
        for property in properties
          ndx.database.update 'properties',
            progressions: []
            milestone: ''
            milestoneIndex: ''
            milestoneStatus: ''
            cssMilestone: ''            
          ,
            _id: property._id
        ndx.property.checkNew()
      res.end 'OK'
  ndx.app.post '/api/properties/advance-progression', ndx.authenticate(), (req, res, next) ->
    milestones = []
    if req.body.milestone
      milestones.push req.body.milestone
    else
      for progression in req.body.property.progressions
        for branch in progression.milestones
          for milestone in branch
            if milestone.progressing and milestone.overdue
              milestones.push milestone
    advanceTo = req.body.advanceTo
    if advanceTo
      advanceTo = new Date advanceTo
    else
      noDays = +req.body.noDays
      advanceTo = new Date()
      advanceTo.setDate advanceTo.getDate() + noDays
    text = "## Advance Progression Request  \n#### Milestone#{if milestones.length>1 then 's' else ''}  \n"
    for milestone in milestones
      text += "`#{milestone.title}`  \n"
    text += "#### Advance to  \n`#{advanceTo.toDateString()}`  \n"
    text += "#### Requested by  \n`#{ndx.user.displayName or ndx.user.local.email}`  \n"
    text += "#### Reason  \n#{req.body.reason}  \n"
    advanceRequest =
      milestones: milestones 
      user: ndx.user
      roleId: req.body.property.roleId
      link: "#{req.protocol}://#{req.hostname}/case/#{req.body.property.roleId}"
      displayAddress: req.body.property.displayAddress
      advanceTo: advanceTo.valueOf()
      text: text
      reason: req.body.reason
      date: new Date()
    if ndx.email
      console.log 'got email'
      ndx.database.select 'emailtemplates',
        name: 'Advance Progression'
      , (templates) ->
        console.log 'got template'
        if templates and templates.length
          ndx.database.select 'users',
            roles:
              admin:
                $nnull: true
          , (users) ->
            if users and users.length
              console.log 'got user'
              for user in users
                Object.assign templates[0], advanceRequest
                templates[0].to = users[0].local.email
                templates[0].text = marked templates[0].text
                ndx.email.send templates[0]
    if not req.body.property.advanceRequests
      req.body.property.advanceRequests = []
    console.log 'advance requests', req.body.property.advanceRequests
    req.body.property.advanceRequests.push advanceRequest
    #save property
    ndx.database.update 'properties',
      advanceRequests: req.body.property.advanceRequests
    ,
      RoleId: req.body.property.roleId
    res.end 'OK'
  ndx.app.get '/api/properties/:roleId', ndx.authenticate(), (req, res, next) ->
    ndx.property.fetch req.params.roleId, (property) ->
      res.json property
  ndx.app.get '/api/properties/:roleId/progressions', ndx.authenticate(), (req, res, next) ->
    ndx.database.select 'properties',
      roleId: req.params.roleId
    , (properties) ->
      if properties and properties.length
        res.json properties[0].progressions
      else
        res.json []
  #startup
  ndx.database.on 'ready', ->
    if not ndx.database.count 'properties'
      console.log 'building database'
      superagent.post "#{process.env.PROPERTY_URL}/search"
      .set 'Content-Type', 'application/json'
      .set 'Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN
      .send
        RoleStatus: 'OfferAccepted'
        RoleType: 'Letting'
        IncludeStc: true
      .end (err, response) ->
        console.log 'building property database'
        if not err and response and response.body
          bar = new progress '  downloading [:bar] :percent :etas',
            complete: '='
            incomplete: ' '
            width: 20
            total: response.body.Collection.length
          fetchProp = (index) ->
            bar.tick 1
            if index < response.body.Collection.length
              ndx.property.fetch response.body.Collection[index].RoleId, ->
                fetchProp ++index
            else
              console.log '\ndatabase build complete'
          fetchProp 0
      