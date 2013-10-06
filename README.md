# Inflectionizer

Inflectionizer is a set of handlebars helpers for working with strings.  This is based off inflections.js, which is in turn based off Rails activesupport inflections.

## Getting Started

````
mrt add inflectionizer
````

## Usage

In your handelbars html template you just call it like this:

````
{{pluralize 1 'people'}}
{{pluralize 3 'person'}}
````

This will output:

````
1 person
3 people
````
