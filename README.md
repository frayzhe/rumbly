Rumbly - Generate UML Diagrams for Ruby Applications
====================================================

Overview
--------
[Rumbly](https://github.com/frayzhe/rumbly) is a Ruby gem that allows you to easily
generate UML class diagrams from models built using a variety of object mapping
libraries, e.g. ActiveRecord, DataMapper, Mongoid, etc., all with our without Rails.

Rumbly provides a set of generic, abstract classes that are used to describe the
key elements of an object model: classes, attributes, operations, and relationships.
These abstract classes are not tied to a specific object mapper; mapper-specific
subclasses are provided for ActiveRecord, DataMapper, and Mongoid that translate a
set of model classes and relationships built on a specific object mapper into the
generic model API defined by Rumbly.

These generic model objects are then used to generate UML class diagrams using a
variety of diagramming tools; a diagram generator is provided that works with (and
requires) Graphviz, but others can be created easily.

Althought Rumbly does not require Ruby on Rails, it provides a set of Rake tasks to
make it easy to generate UML class diagrams from within a Rails application, since
this is likely to be the most common use case.


Getting Started
---------------
First, install the gem:

<tt>gem install rumbly</tt>

To use Rumbly's default Graphviz output, install the latest version of Graphviz.

To run Rumbly within a Rails environment:

* add <tt>gem 'rumby'</tt> to your Gemfile
* run <tt>bundle install</tt>
* run <tt>rake rumbly</tt>


About Rumbly
------------

Rumbly was created by Dustin Frazier (ruby *at* frayzhe.net) based on the excellent
[Rails ERD](http://rails-erd.rubyforge.org/) by Rolf Timmermans.

Copyright © 2012 Dustin Frazier


License
-------

Rumbly is released under the MIT license.
