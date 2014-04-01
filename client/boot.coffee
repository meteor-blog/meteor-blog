################################################################################
# Client-side Config
#


Blog =
  settings:
    blogIndexTemplate: 'blogIndex'
    blogShowTemplate: 'blogShow'
    blogAdminTemplate: 'blogAdmin'
    blogAdminNewTemplate:'blogAdminNew'
    blogAdminEditTemplate: 'blogAdminEdit'
    pageSize: 20

  config: (appConfig) ->
    @settings = _.extend(@settings, appConfig)

@Blog = Blog


################################################################################
# Bootstrap Code
#


Meteor.startup ->
  $('<link>',
    href: '//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css'
    rel: 'stylesheet'
  ).appendTo 'head'

  # Twitter
  window.twttr = do (d = document, s = 'script', id = 'twitter-wjs') ->
    t = undefined
    js = undefined
    fjs = d.getElementsByTagName(s)[0]
    return  if d.getElementById(id)
    js = d.createElement(s)
    js.id = id
    js.src = "https://platform.twitter.com/widgets.js"
    fjs.parentNode.insertBefore js, fjs
    window.twttr or (t =
      _e: []
      ready: (f) ->
        t._e.push f
    )

  # Facebook
  js = undefined
  id = "facebook-jssdk"
  ref = document.getElementsByTagName("script")[0]
  return  if document.getElementById(id)
  js = document.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all.js"
  ref.parentNode.insertBefore js, ref

  # Listen for any 'Load More' clicks
  $('body').on 'click', '.load-more', (e) ->
    e.preventDefault()
    if Session.get 'postLimit'
      Session.set 'postLimit', Session.get('postLimit') + Blog.settings.pageSize

################################################################################
# Register Global Helpers
#

UI.registerHelper "blogFormatDate", (date) ->
  moment(new Date(date)).format "MMM Do, YYYY"

UI.registerHelper "blogFormatTags", (tags) ->
  return if !tags?

  for tag in tags
    path = Router.path 'blogTagged', tag: tag
    if str?
      str += ", <a href=\"#{path}\">#{tag}</a>"
    else
      str = "<a href=\"#{path}\">#{tag}</a>"
  return new Spacebars.SafeString str

UI.registerHelper "joinTags", (list) ->
  if list
    list.join ', '

UI.registerHelper "blogPager", ->
  if Post.count() is Session.get 'postLimit'
    return new Spacebars.SafeString '<a class="load-more btn" href="#">Load More</a>'

UI.registerHelper "blogIndex", ->
  new Spacebars.SafeString Template.blogIndexLoop(this)

UI.registerHelper "blogShow", ->
  new Spacebars.SafeString Template.blogShowBody(this)
