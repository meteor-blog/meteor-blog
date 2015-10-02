############################################################################/
##        Local Filestore                                                  /
##########################################################################/
@filesStore = new FS.Store.GridFS 'blog_images'

@FilesLocal = new FS.Collection 'blog_images',
  stores: [filesStore]
  filter:
    # maxSize: 3145728
    allow:
      contentTypes: [
        'image/*'
      ]
  onInvalid: (message) ->
    console.log message

if Meteor.isClient
  Meteor.subscribe "blog.images"
else
  Meteor.publish 'blog.images', () -> FilesLocal.find()
  FilesLocal.allow
    insert: (userId, file) ->
      !!userId
    remove: (userId, file) ->
      # Only owners can delete
      return file.metadata and file.metadata.userId and file.metadata.userId is userId
    update: ->
      # Anyone can POST a file
      true
    download: (userId, file) ->
      # Anyone can GET a file
      true


############################################################################/
##        Amazon S3 Filestore                                              /
##########################################################################/
useS3 = Meteor.settings?.public?.blog?.useS3

if Meteor.isClient and useS3
  @s3ImportStore = new FS.Store.S3 "blog_s3Imports"

  @S3Files = new FS.Collection "blog_s3Imports",
    stores: [s3ImportStore]
    filter:
      # maxSize: 3145728
      allow:
        contentTypes: [
          'image/*'
        ]
    onInvalid: (message) ->
      console.log message

  Meteor.subscribe "blog.s3Imports"

if Meteor.isServer and useS3
  s3Config = Meteor.settings?.private?.blog?.s3Config
  @s3ImportStore = new FS.Store.S3 "blog_s3Imports",
    accessKeyId:  s3Config.accessKeyId
    secretAccessKey:  s3Config.secretAccessKey
    bucket: s3Config.bucket
    ACL:  s3Config.s3ACL
    maxTries: s3Config.s3MaxTries
    region: s3Config.region

  @S3Files = new FS.Collection "blog_s3Imports",
    stores: [s3ImportStore]
    filter:
      # maxSize: 3145728
      allow:
        contentTypes: [
          'image/*'
        ]
    onInvalid: (message) ->
      console.log message

  Meteor.publish 'blog.s3Imports', () -> S3Files.find()
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
