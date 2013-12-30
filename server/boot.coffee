Meteor.startup ->
  Post._collection._ensureIndex 'slug': 1
