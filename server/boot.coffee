##############################################################################
# Server-side config
#

Blog.settings =
  adminRole: null
  adminGroup: null
  authorRole: null
  authorGroup: null
  rss:
    title: ''
    description: ''

Blog.config = (appConfig) ->
  @settings = _.extend(@settings, appConfig)


################################################################################
# Bootstrap Code
#

Meteor.startup ->

  ##############################################################################
  # Migrations
  #

  Blog.Post._collection._ensureIndex 'slug': 1
  Blog.Comment._collection._ensureIndex 'slug': 1

  # Create 'excerpt' field if none
  if Blog.Post.where({ excerpt: { $exists: 0 }}).length
    arr = Blog.Post.where({ excerpt: { $exists: 0 }})
    i = 0
    while i < arr.length
      obj = arr[i++]
      obj.update({ excerpt: Blog.Post.excerpt(obj.body) })

  # Set version flag
  if not Blog.Config.first()
    Blog.Config.create versions: ['0.5.0']
  else
    Blog.Config.first().push versions: '0.5.0'

  # Add side comments
  arr = Blog.Post.all()
  i = 0
  while i < arr.length
    obj = arr[i++]
    html = obj.body
    para = /<p[^>]*>/g
    classPattern = /class=[\"|\'].*[\"|\']/g
    if html?.indexOf('commentable-section') < 0
      index = 0
      html = html.replace(para, (ele) ->
        if classPattern.test(ele)
          newEle = ele.replace('class=\"', 'class=\"commentable-section')
        else
          newEle = ele.replace('>', ' class=\"commentable-section\">')
        newEle = newEle.replace('>', " data-section-id=\"#{index}\">")
        index++
        return newEle
      )
      obj.update body: html

  # Ensure tags collection is non-empty
  if Blog.Tag.count() == 0
    Blog.Tag.create
      tags: ['meteor']

  # Convert 'published' field to 'mode' field
  arr = Blog.Post.all()
  i = 0
  while i < arr.length
    obj = arr[i++]
    if obj.published
      obj.update mode: 'public'
    else
      if Blog.settings.publicDrafts
        obj.update mode: 'private'
      else
        obj.update mode: 'draft'
