getPost = ->
  Post.first Session.get('postId')
 
Template.blogAdminEdit.rendered = ->
  @editor = new MediumEditor '.editable',
    placeholder: 'Start typing...'
    buttons:
      ['bold', 'italic', 'underline', 'anchor', 'pre', 'header1', 'header2', 'orderedlist', 'unorderedlist', 'quote']

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

    if not body
      return alert 'Blog body is required'

    attrs =
      userId: Meteor.userId()
      title: $('[name=title]', form).val()
      tags: $('[name=tags]', form).val()
      slug: $('[name=slug]', form).val()
      body: body
      updatedAt: new Date()

    if getPost()
      post = getPost().update attrs
    else
      post = Post.create attrs

    if post.errors
      return alert(_(post.errors[0]).values()[0])

    Router.go 'blogAdmin'
