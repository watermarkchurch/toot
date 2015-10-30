# Toot :postal_horn: :dash:

Toot is a library for basic PubSub over HTTP. Toot fires off event
payloads, and provides lightweight Rack apps for handling event callbacks and
subscription management that you can mount up in any Rack compatible
app. All of these actions happen through Sidekiq providing asynchronous,
persistent, and fault-tolerant events.

## Usage

Toot is composed of several standalone components. An app can play the
rolls of an event publisher, subscriber, or both. It just depends on how
you configure it. Let's take a look at an example using two apps:
"publisher" and "subscriber".

### Overview

Here is how you could publish an event on the channel "users.updated.v1"
from the "publisher" app and then subscribe to that channel on the
"subscriber" app.

```ruby
# Publish an event
Toot.publish "users.updated.v1", id: 123

# Subscribe to an event
Toot.subscribe :publisher, "users.updated.v1", -> (event) {
  puts "User with id #{event["id"]} was updated."
}
```

The "subscriber" app has a named `source` called "publisher" that is
configured in the config block. Let's take a look at what configuration
looks like on both apps. First let's take a look at the publisher:

```ruby
# Configuration on the publisher
Toot.config do |c|
  c.channel_prefix = "org.example.publisher."
end

# Mount up the subscriptions service (e.g. For Rails in routes.rb)
match "/subscriptions", to: Toot::SubscriptionsService, via: :post
```

We set the `channel_prefix` which will prepend all events we publish
with this string. This ensures that we don't have name collisions with
other publishers we may introduce.

The `Toot::SubscriptionsService` is a lightweight Rack app that can be
mounted up in any Rack compatible application. You can mount it at
whatever path you like. We'll need the full URL when we configure our
subscriber.

Let's take a look at the subscriber configuration now:

```ruby
# Configuration on the subscriber
Toot.config do |c|
  c.callback_url = "https://subscriber.example.org/callbacks"
  c.source :publisher,
    subscription_url: "https://publisher.example.org/subscriptions",
    channel_prefix: "org.example.publisher."
end

# Mount up the handler service (e.g. For Rails in routes.rb)
match "/callbacks", to: Toot::HandlerService, via: :post
```

The `source` option defines a new event source called "publisher". We
reference this name in any calls to `Toot.subscribe`. We define the
`subscription_url` to match the URL that we mounted up the
`Toot::SubscriptionsService` Rack app on the publisher, and the
`channel_prefix` should match the publisher's.

The `Toot::HandlerService` is the Rack app that handles the event
callback from the publisher. The `callback_url` configuration option
should match whatever URL you mount this Rack app to on your
application. This is used in the subscibe process to let the publisher
know how to notify us about a new event.

### Event Lifecycle

If you're having trouble picturing how this is actually working let's
trace the journey of a newly published event from the "publisher" to the
"subscriber".

1. Event is published using the `Event.publish` method.
2. This enqueues a background job which checks the Database (Redis) for
   subscribers to this channel and enqueues another job for each
   subscriber it finds.
3. The subscriber's callback URL is called with the event's data payload
4. The subscriber enqueues a background job if it has a handler for this
   event.
5. This background job runs the actual event handler code.

### Subscribing

Subscribing is handled by a callable class called
`Toot::RegistersSusbcriptions`. There is also a rake task available that
does the same thing called `toot:register_subscriptions`. If you are
using Rails this rake task will be available to you automatically.

### Configuration

We've looked at an example, but let's look at the conifguration options
in greater detail.

* `channel_prefix`: This option sets a string that will be prepended to
  all events published from this app. In all of our examples we've been
  using the [reverse DNS notation][1], but you can use whatever
  convention you'd like.
* `callback_url`: The event handler URL that this application will
  register to remote publishers. It should match the full URL to
  wherever you have mounted the `Toot::HandlerService` for this app.
* `http_connection`: An instance of Faraday::Connection which is used
  for any external HTTP calls. You can use this to add custom middleware
  for authorization, logging, or debugging.
* `redis_connection`: If you'd like to use a custom Redis connection you
  can configure a callable here that yields a redis connection. By
  default the Sidekiq Redis connection pool is used.
* `source`: This is a method call that defines a named source. It should
  include a `subscription_url` option and a `channel_prefix` option.
  * The first argument is the name of this source
  * The `subscription_url` option is the URL to this source's
    `Toot::SubscriptionsService` app.
  * The `channel_prefix` should match this app's configured
    channel_prefix. This ensures that event channel names will be built
    correctly on the publisher side and on the subscriber side.
* `subscribe`: This is a method call that adds a subscription to a given
  source's channel. It takes three arguments:
  * The source name. This must match a previously defined source
  * The channel suffix. This will be joined with the `channel_prefix`
    configured on the source to form the full channel name.
  * A callable event handler. The event object will be passed in as the
    only argument.

### The Event Object

The schema of the publisher's payload is a contract between publisher
and subscriber and is outside of the scope of this library. However,
Toot does provide some extra information to aid in debugging and general
happiness:

```ruby
Toot.subscribe :publisher, "awesome.channel", -> (event) {
  event.id                # => "c6c4af6b-a227-4b0e-a7b5-5259d31cf98b"
  event.timestamp         # => 2015-10-23 11:50:09 -0500
  event.channel           # => "org.example.publisher.awesome.channel"
  event.payload           # => { "publisher_data" => 123 }
  event["publisher_data"] # => 123
}
```

### Authentication

It is important to note that there is no authentication baked into
Toot's services. If you aren't running in a trusted environment (almost
everybody) you will need to wrap these Rack apps in some kind of
authentication middleware. In Rails, you can use the [constraints
routing config][2], or more generically, you can just decorate the
service with another callable object that does the authentication
checks.

**TODO:** Currently we don't have the ability to add credentials to
outgoing requests. This will need to be added before this problem is
100% solved.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toot

### Requirements

* Sidekiq (and therefore Redis)
* Ruby 2.1+ (or at least that's what's tested)

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake rspec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and tags, and push the
`.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/watermarkchurch/toot.

[1]: https://en.wikipedia.org/wiki/Reverse_domain_name_notation
[2]: http://guides.rubyonrails.org/routing.html#advanced-constraints
