class @Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @belongs_to: [
    name: 'user'
  ]

  @before_create: (post) ->
    post.slug = URLify2 post.title
    post

  excerpt: ->
    # Convert markdown to HTML
    html = marked @body

    # Find 1st non-empty paragraph
    matches = html.split /<\/div>|<\/p>|<br><br>|\\n\\n|\\r\\n\\r\\n/m

    i = 0
    ret = ''
    while not ret and matches[i]
      # Strip tags and clean up whitespaces
      ret += matches[i++].replace(/(<([^>]+)>)/ig, '').replace('&nbsp;', '').trim()

    ret

  author: ->
    #user = @user() # why doesn't this work?
    user = User.first @userId

    if user.profile.firstName and user.profile.lastName
      return "#{user.profile.firstName} #{user.profile.lastName}"
    else if user.profile.twitter
      return user.profile.twitter
    else if user.username
      return user.username
    else if user.emails and user.emails[0]
      return user.emails[0].address

    'Mystery blogger'

Post._collection.allow
  insert: (userId, item) ->
    userId

  update: (userId, item, fields) ->
    userId

  remove: (userId, item) ->
    userId
