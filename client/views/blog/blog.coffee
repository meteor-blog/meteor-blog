Template.blogIndex.helpers

  author: ->
    #user = @user() # doesn't work?
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

  excerpt: ->
    html = marked @body

    # Find 1st non-empty paragraph
    matches = html.split /<\/div>|<\/p>|<br><br>|\\n\\n|\\r\\n\\r\\n/m

    i = 0
    ret = ''
    while not ret and matches[i]
      ret += matches[i++].trim().replace(/(<([^>]+)>)/ig, '').replace('&nbsp;', '')

    ret
