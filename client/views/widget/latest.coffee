Template.blogLatest.rendered = ->
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
