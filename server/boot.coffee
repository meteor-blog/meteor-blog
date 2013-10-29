Meteor.publish 'posts', ->
  Post.find()

Meteor.publish 'users', ->
  User.find()
