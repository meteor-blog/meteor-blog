Template.blogLatest.rendered = ->
  num = if @data?.num then @data.num else 3

  @autorun ->
    Meteor.subscribe 'blog.posts', num


Template.blogLatest.helpers
  latest: ->
    Blog.Post.all()

  date: (date) ->
    if date
      date = new Date(date)
      moment(date).format('MMMM Do, YYYY')
