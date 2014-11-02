################################################################################
# Config
#


Blog =
  settings:
    title: ''
    blogIndexTemplate: null
    blogShowTemplate: null
    blogNotFoundTemplate: null
    blogAdminTemplate: null
    blogAdminEditTemplate: null
    blogAdminRoute: "/blog/admin"
    pageSize: 20
    excerptFunction: null
    syntaxHighlighting: false
    syntaxHighlightingTheme: 'github'
    comments:
      allowAnonymous: false
      useSideComments: false
      defaultImg: '/packages/blog/public/default-user.png'
      userImg: 'avatar'
      disqusShortname: null

  config: (appConfig) ->
    for func in @configs
      func( appConfig )

  configs: [ 
    (appConfig) ->
      # No deep extend in underscore :-(
      if appConfig.comments
        @settings.comments = _.extend(@settings.comments, appConfig.comments)
        delete appConfig.comments
      @settings = _.extend(@settings, appConfig)

      if @settings.syntaxHighlightingTheme
        $('<link>',
          href: '//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/' + @settings.syntaxHighlightingTheme + '.min.css'
          rel: 'stylesheet'
        ).appendTo 'head'
  ]
  
  extend: (extended) ->
    extended.settings = _.extend(extended.settings, @settings)
    extended.settings.comments = _.extend(extended.settings.rss, @settings.comments)
    extended.configs = extended.configs.concat( @configs )
    return extended

@Blog = if @Blog then @Blog.extend( Blog ) else Blog
