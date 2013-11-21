Meteor.publish 'posts', ->
  Post.find()

Meteor.publish 'authors', ->
  Author.find()
