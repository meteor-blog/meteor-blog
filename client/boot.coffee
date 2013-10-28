Meteor.startup ->
  $('<link>',
    href: '//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css'
    rel: 'stylesheet'
  ).appendTo 'head'

#
# Register global helpers
#

# Get the current path for URL 
curPath = ->
  c = window.location.pathname
  b = c.slice(0, -1)
  a = c.slice(-1)
  if b is ""
    "/"
  else
    if a is "/"
      b
    else
      c

# Use the pattern {{active '/path'}} inside of the class="" to have an active
# class added end add active class to navigation
Handlebars.registerHelper "active", (path) ->
  (if curPath() is path then "active" else "")

Handlebars.registerHelper "formatDate", (date) ->
  moment(new Date(date)).format "MMM Do, YYYY"
