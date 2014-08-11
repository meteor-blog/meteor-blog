class @Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @belongs_to: [
    name: 'author'
    identifier: 'userId'
  ]

  @after_save: (post) ->
    post.tags = Post.splitTags post.tags
    post.excerpt = Post.excerpt post.body if post.body

    @_collection.update _id: post.id,
      $set:
        tags: post.tags
        excerpt: post.excerpt

  @slugify: (str) ->
    str.toLowerCase().replace(/[^\w ]+/g, "").replace(RegExp(" +", "g"), "-")

  @splitTags: (str) ->
    if str and typeof str is 'string'
      return str.split(/,\s*/)
    str

  validate: ->
    if not @title
      @error 'title', "Blog title is required"

    if not @slug
      @error 'slug', "Blog slug is required"

  html: ->
    @body

  thumbnail: ->
    regex = new RegExp /img src=[\'"]([^\'"]+)/ig

    while match = regex.exec @body
      return match[1]

  @excerpt: (html) ->
    if Blog.settings.excerptFunction?
      Blog.settings.excerptFunction html
    else
      # Find 1st non-empty paragraph
      matches = html.split /<\/div>|<\/p>|<\/blockquote>|<br><br>|\\n\\n|\\r\\n\\r\\n/m

      i = 0
      ret = ''
      while not ret and matches[i]
        # Strip tags and clean up whitespaces
        ret += matches[i++].replace(/(<([^>]+)>)/ig, ' ').replace('&nbsp;', ' ').trim()
      ret

  authorName: ->
    author = @author()

    if author
      if author.profile and author.profile.name
        return author.profile.name
        
      else if author.profile and author.profile.firstName and author.profile.lastName
        return "#{author.profile.firstName} #{author.profile.lastName}"

      else if author.profile and author.profile.twitter
        return "<a href=\"http://twitter.com/#{author.profile.twitter}\">#{author.profile.twitter}</a>"

      else if author.username
        return author.username

      else if author.emails and author.emails[0]
        return author.emails[0].address

    'Mystery blogger'


#
# Server Methods
#

if Meteor.isServer
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
        check arguments[0], Match.OneOf(Object, Number, String)
        
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


#
# Authorization
#

Post._collection.allow
  insert: (userId, item) ->
    Meteor.call 'isBlogAuthorized', item

  update: (userId, item, fields) ->
    Meteor.call 'isBlogAuthorized', item

  remove: (userId, item) ->
    Meteor.call 'isBlogAuthorized', item
