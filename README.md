
# What ?

This is a vCard parser/generator released under te MIT license

# Support
For now only v3.0 is supported and the testing was done mostly with Apple
Addressbook and iOS contacts.

# Usage

```ruby
require 'vcard_parser'

cards = VCardParser:parse(...)

puts cards[0].fields
puts cards[0]['N']

# dump back the vcard
puts cards[0].to_s
```

# Setting up deve environmeent

```bash
# clone the repository and:
$ bundle
$ bundle exec guard
```
