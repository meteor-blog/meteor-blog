Meteor.publish 'singlePost', (slug) ->
  Post.find slug: slug

Meteor.publish 'posts', (limit) ->
  Post.find {},
    fields:
      body: 0
    sort:
      publishedAt: -1
    limit:
      limit

Meteor.publish 'authors', ->
  ids = _.pluck Post.all
    fields:
      id: 1
  , 'id'

  Author.find
    id:
      $in: ids
