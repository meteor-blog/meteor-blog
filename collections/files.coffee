@Files = FileCollection
  resumable: false
  baseURL: '/fs'
  http: [
    method: 'get',
    path: '/:id',
    lookup: (params, query) ->
      _id: new Meteor.Collection.ObjectID(params.id)
  ,
    method: 'post',
    path: '/:id',
    lookup: (params, query) ->
      _id: new Meteor.Collection.ObjectID(params.id)
  ]

if Meteor.isServer
  Files.allow
    insert: (userId, file) ->
      userId
    remove: (userId, file) ->
      # Only owners can delete
      return file.metadata and file.metadata.userId and file.metadata.userId is userId
    write: ->
      # Anyone can POST a file
      true
    read: (userId, file) ->
      # Anyone can GET a file
      true