@Blog = {}

Blog.settings =
  comments: {}
  rss: {}

Blog.config = (appConfig) ->
  # No deep extend in underscore :-(
  if appConfig.comments
    @settings.comments = _.extend(@settings.comments, appConfig.comments)
    delete appConfig.comments
  @settings = _.extend(@settings, appConfig)


##############################################################################
# Server-side config
#


if Meteor.isServer
  Blog.config
    adminRole: null
    adminGroup: null
    authorRole: null
    authorGroup: null
    rss:
      title: ''
      description: ''


################################################################################
# Client-side config
#


if Meteor.isClient
  Blog.config
    title: ''
    blogIndexTemplate: null
    blogShowTemplate: null
    blogNotFoundTemplate: null
    blogAdminTemplate: null
    blogAdminEditTemplate: null
    blogLayoutTemplate: null
    pageSize: 20
    excerptFunction: null
    syntaxHighlighting: false
    syntaxHighlightingTheme: 'github'
    cdnFontAwesome: true
    comments:
      allowAnonymous: false
      useSideComments: false
      defaultImg: '/packages/blog/public/default-user.png'
      userImg: 'avatar'
      disqusShortname: null


################################################################################
# Both config
#


Blog.config
  basePath: '/blog'
  adminBasePath: '/admin/blog'
