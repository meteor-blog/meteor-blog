Meteor.publish 'posts', ->
  Post.find()
