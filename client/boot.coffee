################################################################################
# Bootstrap Code
#


Meteor.startup ->
  # Load Font Awesome
  $('<link>',
    href: '//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css'
    rel: 'stylesheet'
  ).appendTo 'head'

  # Listen for any 'Load More' clicks
  $('body').on 'click', '.blog-load-more', (e) ->
    e.preventDefault()
    if Session.get 'postLimit'
      Session.set 'postLimit', Session.get('postLimit') + Blog.settings.pageSize

  # Notifications package
  _.extend Notifications.defaultOptions,
    timeout: 5000

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
    return new Spacebars.SafeString '<a class="blog-load-more btn" href="#">Load More</a>'
