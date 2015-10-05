
# ------------------------------------------------------------------------------
# RSS

Router.route '/rss/posts',
  name: 'rss'
  where: 'server'
  action: ->
    @response.write Meteor.call 'serveRSS'
    @response.end()


# ------------------------------------------------------------------------------
# PUBLIC ROUTES


# BLOG INDEX

Router.route '/blog',
  name: 'blogIndex'
  template: 'custom'

if Meteor.isServer
  FastRender.route '/blog', ->
    @subscribe 'blog.authors'
    @subscribe 'blog.posts'

# BLOG TAG

Router.route '/blog/tag/:tag',
  name: 'blogTagged'
  template: 'custom'
  data: -> tag: @params.tag

if Meteor.isServer
  FastRender.route '/blog/tag/:tag', (params) ->
    @subscribe 'blog.authors'
    @subscribe 'blog.taggedPosts', params.tag

# SHOW BLOG

Router.route '/blog/:slug',
  name: 'blogShow'
  template: 'custom'
  data: -> slug: @params.slug

if Meteor.isServer
  FastRender.route '/blog/:slug', (params) ->
    @subscribe 'blog.authors'
    @subscribe 'blog.singlePostBySlug', params.slug
    @subscribe 'blog.commentsBySlug', params.slug


# ------------------------------------------------------------------------------
# ADMIN ROUTES


# BLOG ADMIN INDEX

Router.route '/admin/blog',
  name: 'blogAdmin'
  template: 'custom'
  onBeforeAction: ->
    if Meteor.loggingIn()
      return

    Deps.autorun () ->
      Router.go 'blogIndex' if not Meteor.userId()

    Meteor.call 'isBlogAuthorized', (err, authorized) =>
      if not authorized
        return @redirect('/blog')

    @next()
  waitOn: ->
    [ Meteor.subscribe 'blog.postForAdmin'
      Meteor.subscribe 'blog.authors' ]

# NEW/EDIT BLOG

Router.route '/admin/blog/edit/:id',
  name: 'blogAdminEdit'
  template: 'custom'
  onBeforeAction: ->
    if Meteor.loggingIn()
      return

    Deps.autorun () ->
      Router.go 'blogIndex' if not Meteor.userId()

    Meteor.call 'isBlogAuthorized', @params.id, (err, authorized) =>
      if not authorized
        return @redirect('/blog')

    Session.set 'postId', @params.id
    @next() if Session.get("postId").length?
  action: ->
    @render() if @ready()
  waitOn: -> [
    Meteor.subscribe 'blog.singlePostById', @params.id
    Meteor.subscribe 'blog.authors'
    Meteor.subscribe 'blog.postTags'
  ]
