Welcome to the OAuth Rails Kit
==============================

This Kit will help you get a quick start on building web
applications that need to interact with 3rd-party services such as
Facebook or Twitter that use OAuth (and OAuth2) for providing
access to their users' data. Once you get this Kit up and running,
you'll be able to log in to Twitter, Facebook, and LinkedIn, fetch
updates for the logged-in user from those services, and post
updates for the logged-in user to those services.  You'll also be
able to list a user's Google docs and work with the user's Google
spreadsheets.

Getting Started
===============

This code provides a complete, running Rails application. There
are a few things you need to do to get started, though. First, get
all the necessary gems by running the following command (you may
need to install the bundler gem first):

`bundle install`

Then run the following rake command on the command line:

`rake bootstrap`

This will create your database (by default the app is configured
to use sqlite) and change the secret token for your app's sessions.

After that is done, you'll need to edit config/oauth.yml and add
the credentials for the various services to which you want to
connect. To get these credentials, go to the developer sites
listed below, sign up if necessary, and go through the process of
creating an application. In the case of Facebook and Twitter,
you'll need to specify what domain you'll be using, and what the
callback URLs are. I strongly recommend you use
[pow](http://pow.cx) to run the app on your development box. In
the examples below, I'm going to assume you are doing that, and
that the app can be accessed at http://oauthkit.dev/ in your browser.

After setting up the providers as listed below, you'll be ready
to browse to the app and start using it.

Twitter
-------

1. Go to https://developer.twitter.com
2. Create your app with the Application Type set to Browser,
the Callback URL set to http://oauthkit.dev/auth/twitter/callback
and the Default Access Type set to Read & Write
3. Use the provided Consumer key as the `app_id` and the Consumer
secret as the `app_secret` in oauth.yml

You can use a single app for development and production if add
your production domain via the Manage Domains link in the sidebar
when looking at the settings page for your app.

Facebook
--------

1. Go to http://www.facebook.com/developers/ and click the Set Up
New App button
2. Set the Site URL to http://oauthkit.dev/ and the Site Domain to 
oauthkit.dev
3. Use the provided App ID as the `app_id` and the App Secret as
the `app_secret` in oauth.yml
4. The available values for the scopes key in the yaml are available at http://developers.facebook.com/docs/authentication/permissions/

You'll need to create separate Facebook apps for each environment
(each different domain) for your app.

LinkedIn
--------

1. Go to https://www.linkedin.com/secure/developer
2. Use the provided API Key as the `app_id` and the Secret Key as
the `app_secret` in oauth.yml

Google
--------

1. Go to https://www.google.com/accounts/ManageDomains
2. Add your domain (it won't be hit for callbacks -- you can 
still develop locally)
3. Validate the domain
4. Click on the domain and enter http://oauthkit.dev/ as the 
Target URL prefix path
5. Use the provided OAuth Consumer Key as the `app_id` and the 
OAuth Consumer Secret as the `app_secret` in oauth.yml

Usage
=====

Once you have a User with an Authentication created by logging
in to the third-party site, you can do the following:

Post to the user's feed
-----------------------

An example of this in app/controllers/users_controller.rb

`user.authentications.find_by_provider('twitter').service.post("here's my tweet")`

Read from the user's feed
-------------------------

An example of this is in app/views/users/show.html.haml

`user.authentications.find_by_provider('twitter').service.feed`

View the user's Google docs
---------------------------

An example of this is in app/controllers/documents_controller.rb

`user.authentications.find_by_provider('google').service.documents`

Contents
========

Most of the work is done by the omniauth gem (for logging in to
the services and getting access tokens) and by the twitter,
linkedin, and koala gems (for getting data from the services using
the access tokens obtained during login). 

You'll find a shim module in lib/service.rb that unifies the
interfaces of those three gems for the posting and fetching of
updates. This shim is used by UsersController to interact with the
services. It is also used by DocumentsController to work with the
user's Google docs and spreadsheets (via the
google-spreadsheet-ruby gem).

Logging in is handled via AuthenticationsController, which creates
Authentication records and associates them with a User. The oauth
access token and secret is stored in Authentication, and a User
has many Authentications so that you can have the same user log in
via all three services.

The setup for omniauth and the twitter and linkedin gems is in
config/initializers/oauth.rb.

Integrating With Other Authentication Systems
=============================================

So you want to allow users of your site who already have a
username and password to also connect their third-party profiles?
No problem! If you are using something like Devise or Authlogic,
just add a before filter to the AuthenticationsController (e.g.,
`before_filter authenticate_user!` in the case of Devise) that
requires the user to be logged in before authenticating with the
third-party. Then `current_user` will already be set when the user
returns from authenticating, so the newly-created Authentication
will be associated with that existing User record. Use the connect
action to ensure the user is logged in to your site before being
redirected to the third-party:

`link_to('connect your account to facebook', '/connect/facebook')`

Things get a little trickier if you want to allow users to create
accounts via a third-party *and* you want users to be able to
create accounts with a email/password at your site. This is
because Twitter and LinkedIn won't give you an email address for
the user (and for Facebook you have to ask for it), so you'll have
to make sure you can create User records without an email address
(or you'll have to fake an email address somehow from the UID you
get back from the third-party). You'll also need to decide how you
want to handle duplicate User records for the person who happened
to create an account via a third party *and* created a different
account with an email address and password.

Either way, you won't need the `current_user` stuff defined in
ApplicationController, since your existing authentication system
will provide that.

Images
======

The images used in the Kit require attribution or a license if
you'll be using them:
http://www.komodomedia.com/blog/2009/06/sign-in-with-twitter-facebook-and-openid/