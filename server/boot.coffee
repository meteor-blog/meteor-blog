##############################################################################
# Server-side config
#

Blog =
  settings:
    adminRole: null
    adminGroup: null
    authorRole: null
    authorGroup: null
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

  # Set version flag
  if not Config.first()
    Config.create versions: ['0.5.0']
  else
    Config.first().push versions: '0.5.0'

  # Add side comments
  arr = Post.all()
  i = 0
  while i < arr.length
    obj = arr[i++]
    html = obj.body
    para = /<p[^>]*>/g
    classPattern = /class=[\"|\'].*[\"|\']/g
    if html.indexOf('commentable-section') < 0
      index = 0
      html = html.replace(para, (ele) ->
        if classPattern.test(ele)
          newEle = ele.replace('class=\"', 'class=\"commentable-section')
        else
          newEle = ele.replace('>', ' class=\"commentable-section\">')
        newEle = newEle.replace('>', " data-section-id=\"#{index}\">")
        index++
        return newEle
      )
      obj.update body: html

  # Ensure tags collection is non-empty
  if Tag.count() == 0
    Tag.create
      tags: ['meteor']

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

      # If no roles are set, allow all
      if not Blog.settings.adminRole and not Blog.settings.authorRole
        return true

      # If admin role is set
      if Blog.settings.adminRole
        # And if admin group is set
        if Blog.settings.adminGroup
          # And if user is admin
          if Roles.userIsInRole(@userId, Blog.settings.adminRole, Blog.settings.adminGroup)
            # Then they can do anything
            return true

        # If only admin role is set, and if user is admin
        else if Roles.userIsInRole(@userId, Blog.settings.adminRole)
          # Then they can do anything
          return true
 
 
      # If author role is set
      if Blog.settings.authorRole
 
        # Get the post
        if _.isObject arguments[0]
          post = arguments[0]
        else if _.isNumber(arguments[0]) or _.isString(arguments[0])
          post = Post.first arguments[0]
        else
          post = null

        # And if author group is set
        if Blog.settings.authorGroup
          # And if user is author
          if Roles.userIsInRole(@userId, Blog.settings.authorRole, Blog.settings.authorGroup)
            if post
              # And if user is author of this post
              if Meteor.userId() is post.userId
                return true
            else
              return true

        # If only author role is passed, and if user is author
        else if Roles.userIsInRole(@userId, Blog.settings.authorRole)
          if post
            # And if user is author of this post
            if Meteor.userId() is post.userId
              return true
          else
            return true

 
      false
