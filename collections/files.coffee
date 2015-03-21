############################################################################/
##        Local Filestore                                                  /
##########################################################################/
@FilesLocal = FileCollection
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
  FilesLocal.allow
    insert: (userId, file) ->
      !!userId
    remove: (userId, file) ->
      # Only owners can delete
      return file.metadata and file.metadata.userId and file.metadata.userId is userId
    write: ->
      # Anyone can POST a file
      true
    read: (userId, file) ->
      # Anyone can GET a file
      true


############################################################################/
##        Amazon S3 Filestore                                              /
##########################################################################/
useS3 = Meteor.settings?.public?.blog?.useS3

if Meteor.isClient and useS3
  @s3ImportStore = new FS.Store.S3 "s3Imports"

  @S3Files = new FS.Collection "s3Imports",
    stores: [s3ImportStore]
    filter:
      # maxSize: 3145728
      allow:
        contentTypes: [
          'image/*'
        ]
    onInvalid: (message) ->
      console.log message

  Meteor.subscribe "s3Imports"

if Meteor.isServer and useS3
  s3Config = Meteor.settings?.private?.blog?.s3Config
  @s3ImportStore = new FS.Store.S3 "s3Imports",
    accessKeyId:  s3Config.accessKeyId
    secretAccessKey:  s3Config.secretAccessKey
    bucket: s3Config.bucket
    ACL:  s3Config.s3ACL
    maxTries: s3Config.s3MaxTries
    region: s3Config.region

  @S3Files = new FS.Collection "s3Imports",
    stores: [s3ImportStore]
    filter:
      # maxSize: 3145728
      allow:
        contentTypes: [
          'image/*'
        ]
    onInvalid: (message) ->
      console.log message

  Meteor.publish 's3Imports', () ->
    S3Files.find()
  S3Files.allow
    insert: (userId, file) ->
      userId
    remove: (userId, file) ->
      # Only owners can delete
      return file.metadata and file.metadata.userId and file.metadata.userId is userId
    update: ->
      # Anyone can POST a file
      true
    download: (userId, file) ->
      # Anyone can GET a file
      true
