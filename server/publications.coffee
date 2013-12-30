Meteor.publish 'singlePost', (slug) ->
  Post.find({slug: slug})

Meteor.publish 'posts', ->
  Post.find()

Meteor.publish 'authors', ->
  ids = _.pluck Post.all
    fields:
      id: 1
  , 'id'

  Author.find
    id:
      $in: ids
