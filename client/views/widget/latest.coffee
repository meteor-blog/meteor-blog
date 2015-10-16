Template.blogLatest.onRendered () ->
  num = if @data?.num then @data.num else 3
  @autorun ->
    Meteor.subscribe 'blog.posts', num


Template.blogLatest.helpers
  latest: ->
    num = if @num then @num else 3
    Blog.Post.all limit: num

  date: (date) ->
    if date
      date = new Date(date)
      moment(date).format('MMMM Do, YYYY')




# Provide data to custom templates, if any
Meteor.startup ->
  if Blog.settings.blogLatestTemplate
    customLatest = Blog.settings.blogLatestTemplate
    Template[customLatest].onRendered Template.blogLatest._callbacks.rendered[0]
    Template[customLatest].helpers
      latest: Template.blogLatest.__helpers.get('latest')
      date: Template.blogLatest.__helpers.get('date')


  
