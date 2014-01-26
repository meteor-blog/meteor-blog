Meteor.startup ->

  ##############################################################################
  # Migrations and such
  #

  Post._collection._ensureIndex 'slug': 1

  # Create 'excerpt' field if none
  if Post.where({ excerpt: { $exists: 0 }}).length
    arr = Post.where({ excerpt: { $exists: 0 }})
    i = 0
    while i < arr.length
      obj = arr[i++]
      obj.update({ excerpt: Post.excerpt(obj.body) })

  ##############################################################################
  # Server-side config
  #

  Blog =
    settings:
      adminRole: null

    config: (appConfig) ->
      @settings = _.extend(@settings, appConfig)

  @Blog = Blog

  ##############################################################################
  # Server-side methods
  #

  Meteor.methods
    isAuthorized: () ->
      if not Meteor.user()
        return false

      if Blog.settings.adminRole and not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
        return false

      true
