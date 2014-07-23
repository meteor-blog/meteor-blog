Template.dynamic.helpers
  template: ->
    name = Router.current().route.name

    # Tagged view uses 'blogIndex' template
    if name is 'blogTagged'
      name = 'blogIndex'

    if Blog.settings["#{name}Template"]
      return Blog.settings["#{name}Template"]

    name
