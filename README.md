# Topobook

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/topobook`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Pre-requirements: Ruby/Bundler, Homebrew, Node/Npm

```sh
brew install pdf2svg pandoc imagemagick

brew cask install kindlegen kindle-previewer

npm i -g svgo
```

Add this line to your application's Gemfile:

```ruby
gem 'topobook'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install topobook

## Usage

    $ topobook PDF_FILE

Processes the Topographic PDF and generates an ebook (in *ePub* and *Mobi* formats).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/topobook.

# TODO

* Make a cover image by using Imagemagick montage to put together the color JPEGs image tiles extracted from the SVG.
* Extract map information items from SVG and create a page for that.
* Make a simplified version of the overall map with page indicators for the detail pages
* Scale the full page appropriately for kindle resolution
* Look into reducing resolution that is tough to see (may not be possible)
* Break up each detail page from the overall file
    - Allow for overlap
    - Eliminate the map edges
    - Would it be possible to determine the lat-long bounds of each page?
    - Figure out the right page size/resolution for best viewing
    - Make each page SVG smaller by deleting items outside the viewbox boundary (possibly with Chrome)
