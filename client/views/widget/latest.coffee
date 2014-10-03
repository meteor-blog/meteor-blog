Template.blogLatest.rendered = ->
  num = if @data?.num then @data.num else 3

  @autorun ->
    Meteor.subscribe 'posts', num


Template.blogLatest.helpers
  latest: ->
    Post.all()

  date: (date) ->
    if date
      date = new Date(date)
      moment(date).format('MMMM Do, YYYY')
