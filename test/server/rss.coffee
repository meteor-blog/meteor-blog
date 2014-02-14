Tinytest.add "blog - RSS", (test)->

  rss = Meteor.call('serveRSS')

  test.notEqual(rss.indexOf("<title>Untitled RSS Feed</title>"), -1, "feed includes site title")
