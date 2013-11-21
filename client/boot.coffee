################################################################################
# Blog Config
#


Blog =
  settings:
    blogIndexTemplate: 'blogIndex'
    blogShowTemplate: 'blogShow'

  config: (appConfig) ->
    @settings = _.extend(@settings, appConfig)

@Blog = Blog


################################################################################
# Bootstrap Code
#


Meteor.startup ->
  $('<link>',
    href: '//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css'
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


################################################################################
# Register Global Helpers
#

Handlebars.registerHelper "blogFormatDate", (date) ->
  moment(new Date(date)).format "MMM Do, YYYY"

Handlebars.registerHelper "blogIndex", ->
  new Handlebars.SafeString Template.blogIndexLoop(this)

Handlebars.registerHelper "blogShow", ->
  new Handlebars.SafeString Template.blogShowBody(this)
