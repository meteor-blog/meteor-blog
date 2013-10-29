class @Post extends Minimongoid

  @_collection: new Meteor.Collection 'blog_posts'

  @belongs_to: [
    name: 'user'
  ]

  @before_create: (post) ->
    post.slug = URLify2 post.title
    post

  html: ->
    marked @body

  thumbnail: ->
    # Convert markdown to HTML
    html = marked @body
    regex = new RegExp /img src=[\'"]([^\'"]+)/ig

    while match = regex.exec html
      return match

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

    if user.profile and user.profile.firstName and user.profile.lastName
      return "#{user.profile.firstName} #{user.profile.lastName}"

    else if user.profile and user.profile.twitter
      return "<a href=\"http://twitter.com/#{user.profile.twitter}\">#{user.profile.twitter}</a>"

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
