##############################################################################
# Server-side config
#

Blog =
  settings:
    adminRole: null
    adminGroup: null
    comments:
      allowAnonymous: null
      useSideComments: null
    rss:
      title: ''
      description: ''

  config: (appConfig) ->
    @settings = _.extend(@settings, appConfig)

@Blog = Blog

################################################################################
# Bootstrap Code
#

Meteor.startup ->

  ##############################################################################
  # Migrations
  #

  Post._collection._ensureIndex 'slug': 1

  # Create 'excerpt' field if none
  if Post.where({ excerpt: { $exists: 0 }}).length
    arr = Post.where({ excerpt: { $exists: 0 }})
    i = 0
    while i < arr.length
      obj = arr[i++]
      obj.update({ excerpt: Post.excerpt(obj.body) })

  # If no version flag
  if not Config.where(versions: '0.4.0').length
    arr = Post.all()
    i = 0
    # Convert blog post markdown to HTML
    while i < arr.length
      obj = arr[i++]
      html = marked obj.body
      obj.update body: html
    # Set version flag
    Config.create versions: ['0.4.0']

  ##############################################################################
  # Server-side methods
  #

  Meteor.methods
    doesBlogExist: (slug) ->
      check slug, String

      !! Post.first slug: slug

    isBlogAuthorized: () ->
      if not Meteor.user()
        return false

      # If role AND group is passed
      if Blog.settings.adminRole and Blog.settings.adminGroup
        if not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole, Blog.settings.adminGroup)
          return false

      # If only role is passed
      else if Blog.settings.adminRole
        if not Roles.userIsInRole(Meteor.user(), Blog.settings.adminRole)
          return false

      true

    sideCommentsSettings: () ->
      useSideComments: Blog.settings.comments.useSideComments
      allowAnonymous: Blog.settings.comments.allowAnonymous
