
# What ?

This is a vCard parser/generator released under te MIT license

# Support
For now only v3.0 is supported and the testing was done mostly with Apple
Addressbook and iOS contacts.

# Continuous integration ([![Build Status](https://secure.travis-ci.org/schmurfy/vcard_parser.png)](https://secure.travis-ci.org/schmurfy/vcard_parser.png))

This gem is tested against these ruby by travis-ci.org:

- mri 1.9.3

# Usage

```ruby
require 'vcard_parser'

cards = VCardParser::parse(...)

puts cards[0].fields
puts cards[0]['N']

# dump back the vcard
puts cards[0].to_s
```

# Setting up development environmeent

```bash
# clone the repository and:
$ bundle
$ bundle exec guard
```
