

Blog.Router =
  routes: []

  replaceState: (path) ->
    if Package['iron:router']
      Iron.Location.go path, { replaceState: true, skipReactive: true }
    else if Package['kadira:flow-router']
      FlowRouter.withReplaceState -> FlowRouter.go path

  go: (nameOrPath, params, options) ->
    router =
      if Package['iron:router']
        Package['iron:router'].Router
      else if Package['kadira:flow-router']
        Package['kadira:flow-router'].FlowRouter

    if /^\/|http/.test(nameOrPath)
      path = nameOrPath
    else
      route = _.findWhere @routes, name: nameOrPath
      options ?= {}
      url = new Iron.Url route.path
      path = url.resolve params, options
    router.go path

  getLocation: ->
    if Package['iron:router']
      '/' + Router.current().params[0]
    else if Package['kadira:flow-router']
      FlowRouter.watchPathChange()
      FlowRouter.current().path

  getParam: (key) ->
    location = @getLocation()
    url = null
    match = _.find @routes, (route) ->
      url = new Iron.Url route.path
      url.test location
    if match
      params = url.params(location)
      return params[key]

  pathFor: (name, params, options) ->
    route = _.findWhere @routes, name: name
    opts = options and (options.hash or {})
    url = new Iron.Url route.path
    url.resolve params, opts

  getTemplate: ->
    location = @getLocation()
    url = null
    match = _.find routes, (route) ->
      url = new Iron.Url route.path
      url.test location
    if match
      name = match.name

      # Tagged view uses 'blogIndex' template
      if name is 'blogTagged'
        name = 'blogIndex'

      # Custom template?
      if Blog.settings["#{name}Template"]
        name = Blog.settings["#{name}Template"]
      return name

  routeAll: (routes) ->
    @routes = routes
    if Package['iron:router']
      # Fast Render
      if Meteor.isServer
        routes.forEach (route) ->
          if route.fastRender
            FastRender.route route.path, route.fastRender

      Package['iron:router'].Router.route '/(.*)',
        onBeforeAction: ->
          template = Blog.Router.getTemplate()
          if template
            if Blog.settings.blogLayoutTemplate
              @layout Blog.settings.blogLayoutTemplate
            @render template
          else
            @next()
        action: ->
          @next()


    else if Package['kadira:flow-router']
      Package['kadira:flow-router'].FlowRouter.route '/:any*',
        action: ->
          template = Blog.Router.getTemplate()
          if template
            if Blog.settings.blogLayoutTemplate
              layout = Blog.settings.blogLayoutTemplate
              BlazeLayout.render layout, template: template
            else
              BlazeLayout.render template


    else
      throw new Meteor.Error 500, 'Blog requires either iron:router or kadira:flow-router'
 

# ------------------------------------------------------------------------------
# PUBLIC ROUTES


routes = []

# BLOG INDEX

routes.push
  path: '/blog'
  name: 'blogIndex'
  fastRender: ->
    @subscribe 'blog.authors'
    @subscribe 'blog.posts'

# BLOG TAG

routes.push
  path: '/blog/tag/:tag'
  name: 'blogTagged'
  fastRender: (params) ->
    @subscribe 'blog.authors'
    @subscribe 'blog.taggedPosts', params.tag

# SHOW BLOG

routes.push
  path: '/blog/:slug'
  name: 'blogShow'
  fastRender: (params) ->
    @subscribe 'blog.authors'
    @subscribe 'blog.singlePostBySlug', params.slug
    @subscribe 'blog.commentsBySlug', params.slug


# ------------------------------------------------------------------------------
# ADMIN ROUTES


# BLOG ADMIN INDEX

routes.push
  path: '/admin/blog'
  name: 'blogAdmin'

# NEW/EDIT BLOG

routes.push
  path: '/admin/blog/edit/:id'
  name: 'blogAdminEdit'


# ------------------------------------------------------------------------------
# RSS


if Meteor.isServer
  JsonRoutes.add 'GET', '/rss/posts', (req, res, next) ->
    res.write Meteor.call 'serveRSS'
    res.end()


Meteor.startup ->
  Blog.Router.routeAll routes
