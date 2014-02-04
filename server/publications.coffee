Meteor.publish 'singlePost', (slug) ->
  check slug, String

  Post.find slug: slug

Meteor.publish 'posts', (limit) ->
  check limit, Match.Optional(Number)

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
