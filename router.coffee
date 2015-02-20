subs = new SubsManager
  cacheLimit: 10, # Maximum number of cache subscriptions
  expireIn: 5 # Any subscription will be expire after 5 minute, if it's not subscribed again

if Meteor.isClient
  Router.onBeforeAction ->
    @notFoundTemplate =
      if Blog.settings.blogNotFoundTemplate
        Blog.settings.blogNotFoundTemplate
      else
        'blogNotFound'
    Iron.Router.hooks.dataNotFound.call @
  , only: ['blogShow']

# RSS

Router.route '/rss/posts',
  name: 'rss'
  where: 'server'
  action: ->
    @response.write Meteor.call 'serveRSS'
    @response.end()

# BLOG INDEX

Router.route '/blog',
  name: 'blogIndex'
  template: 'custom'
  onRun: ->
    if not Session.get('postLimit') and Blog.settings.pageSize
      Session.set 'postLimit', Blog.settings.pageSize
    @next()
  waitOn: ->
    if (typeof Session isnt 'undefined')
      [
        subs.subscribe 'posts', Session.get('postLimit')
        subs.subscribe 'authors'
      ]
  fastRender: true
  data: ->
    posts: Post.where {},
      sort: publishedAt: -1

# BLOG TAG

Router.route '/blog/tag/:tag',
  name: 'blogTagged'
  template: 'custom'
  waitOn: -> [
    subs.subscribe 'taggedPosts', @params.tag
    subs.subscribe 'authors'
  ]
  fastRender: true
  data: ->
    posts: Post.where
      tags: @params.tag
    ,
      sort: publishedAt: -1

# SHOW BLOG

Router.route '/blog/:slug',
  name: 'blogShow'
  template: 'custom'
  onRun: ->
    Session.set('slug', @params.slug)
    @next()
  onBeforeAction: ->
    if Blog.settings.blogShowTemplate
      tpl = Blog.settings.blogShowTemplate

      # If the user has a custom template, and not using the helper, then
      # maintain the package Javascript.
      pkgFunc = Template.blogShowBody.rendered
      userFunc = Template[tpl].rendered

      if userFunc
        Template[tpl].rendered = ->
          pkgFunc.call(@)
          userFunc.call(@)
      else
        Template[tpl].rendered = pkgFunc

    if !Blog.settings.publicDrafts and !Post.first().published
      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        return @redirect('/blog') unless authorized
    Session.set 'postHasFeaturedImage', Post.first({slug: @params.slug}).featuredImage?.length > 0
    @next()
  action: ->
    @render() if @ready()
  waitOn: -> [
    Meteor.subscribe 'singlePostBySlug', @params.slug
    subs.subscribe 'commentsBySlug', @params.slug
    subs.subscribe 'authors'
  ]
  data: ->
    Post.first slug: @params.slug

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
    [ Meteor.subscribe 'postForAdmin'
      Meteor.subscribe 'authors' ]

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
    Meteor.subscribe 'singlePostById', @params.id
    Meteor.subscribe 'authors'
    Meteor.subscribe 'postTags'
  ]