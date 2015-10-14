################################################################################
# Bootstrap Code
#


Blog.subs = new SubsManager
  cacheLimit: 10, # Maximum number of cache subscriptions
  expireIn: 5 # Any subscription will be expire after 5 minute, if it's not subscribed again

Meteor.startup ->
  if Blog.settings.syntaxHighlightingTheme
    # Syntax Highlighting
    $('<link>',
      href: '//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.1/styles/' + Blog.settings.syntaxHighlightingTheme + '.min.css'
      rel: 'stylesheet'
    ).appendTo 'head'

  if Blog.settings.cdnFontAwesome
    # Load Font Awesome
    $('<link>',
      href: '//netdna.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.css'
      rel: 'stylesheet'
    ).appendTo 'head'

  # Listen for any 'Load More' clicks
  $('body').on 'click', '.blog-load-more', (e) ->
    e.preventDefault()
    if Session.get 'blog.postLimit'
      Session.set 'blog.postLimit', Session.get('blog.postLimit') + Blog.settings.pageSize

################################################################################
# Register Global Helpers
#

Template.registerHelper 'BlogLanguage', () ->
  return Blog.settings.language

Template.registerHelper "blogFormatDate", (date) ->
  moment(new Date(date)).format "MMM Do, YYYY"

Template.registerHelper "blogFormatTags", (tags) ->
  return if !tags?

  for tag in tags
    path = Blog.Router.pathFor 'blogTagged', tag: tag
    if str?
      str += ", <a href=\"#{path}\">#{tag}</a>"
    else
      str = "<a href=\"#{path}\">#{tag}</a>"
  return new Spacebars.SafeString str

Template.registerHelper "blogJoinTags", (list) ->
  if list
    list.join ', '

Template.registerHelper "blogPager", ->
  if Blog.Post.count() is Session.get 'blog.postLimit'
    return new Spacebars.SafeString '<a class="blog-load-more btn" href="#">Load More</a>'

Template.registerHelper 'blogPathFor', (name, options) ->
  return Blog.Router.pathFor name, @, options
