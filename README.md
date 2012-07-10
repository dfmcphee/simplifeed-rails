Welcome to Simplifeed
=====================

About
-----

Simplifeed combines your social networks into a simple stream. It is based on RESTful principles and lets users request their feeds through its web services. It allows users to sort through lists of sources from their networks and group them into lists they can share. They also have the ability to star any of their favourite posts to create their own simplifeed that can be shared.

Requirements
------------

*These are only the versions tested on. Others may work but will not be supported.

Ruby 1.9.3
Rails 3.2.3

Getting Started
---------------

First add all your network api keys in config/oauth.yml

Edit your config/database.yml with your database authentication

To install all the gems necessary enter in the command line:
`bundle install`

To create your database run:
`rake db:create`

To run all the database migrations run:
`rake db:migrate`

Then start the web stack with:
`rails server`

If you want to use capistrano to deploy to your server through ssh for you, do the following:

1. Edit your config/deploy.rb and enter your server information
2. Use `cap deploy:setup` to create the directories on your server
3. Use `cap deploy:update` to deploy new code