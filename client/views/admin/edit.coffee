getPost = ->
  Post.first Session.get('postId')
 
Template.blogAdminEdit.rendered = ->
  @editor = new MediumEditor '.editable',
    placeholder: 'Start typing...'
    buttons:
      ['bold', 'italic', 'underline', 'anchor', 'pre', 'header1', 'header2', 'orderedlist', 'unorderedlist', 'quote', 'image']

Template.blogAdminEdit.helpers
  post: ->
    getPost() or {}

Template.blogAdminEdit.events

  'blur [name=title]': (e, tpl) ->
    e.preventDefault()
    slug = tpl.$('[name=slug]')
    title = $(e.currentTarget).val()

    if not slug.val()
      slug.val Post.slugify(title)

  'submit form': (e, tpl) ->
    e.preventDefault()
    form = $(e.currentTarget)

    body = $('.editable', form).html().trim()
    slug = $('[name=slug]', form).val()

    if not body
      return alert 'Blog body is required'

    attrs =
      title: $('[name=title]', form).val()
      tags: $('[name=tags]', form).val()
      slug: slug
      body: body
      updatedAt: new Date()

    if getPost()
      post = getPost().update attrs
      if post.errors
        return alert(_(post.errors[0]).values()[0])

      Router.go 'blogAdmin'
    else
      Meteor.call 'doesBlogExist', slug, (err, exists) ->
        if not exists
          attrs.userId = Meteor.userId()
          post = Post.create attrs

          if post.errors
            return alert(_(post.errors[0]).values()[0])

          Router.go 'blogAdmin'

        else
          return alert 'Blog with this slug already exists'
