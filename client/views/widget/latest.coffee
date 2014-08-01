Deps.autorun ->
  Meteor.subscribe 'posts', 3

Template.blogLatest.helpers
  latest: ->
    Post.all()

  date: (date) ->
    if date
      date = new Date(date)
      moment(date).format('MMMM Do, YYYY')
