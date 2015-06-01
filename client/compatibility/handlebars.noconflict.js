// medium-editor-insert-plugin needs its own Handlebars, not Meteor's
// Handlebars. Fortunately, the local one is still available before Meteor's
// takes over.
Handlebars = window.Handlebars;
