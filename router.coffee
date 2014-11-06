subs = new SubsManager
  cacheLimit: 10, # Maximum number of cache subscriptions
  expireIn: 5 # Any subscription will be expire after 5 minute, if it's not subscribed again

if Meteor.isClient
  Router.onBeforeAction ->
    if @lookupOption('data') is undefined
      return @next()

    Iron.Router.hooks.dataNotFound.call @

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
  notFoundTemplate: 'blogNotFound'
  onRun: ->
    Session.set('slug', @params.slug)
  onBeforeAction: ->
    if Blog.settings.blogNotFoundTemplate
      @notFoundTemplate = Blog.settings.blogNotFoundTemplate

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
  data: ->
    true

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

    @next()
  action: ->
    @render() if @ready()
  onRun: ->
    Session.set 'postId', @params.id
  waitOn: -> [
    Meteor.subscribe 'singlePostById', @params.id
    Meteor.subscribe 'authors'
    Meteor.subscribe 'postTags'
  ]
  data: ->
    true
