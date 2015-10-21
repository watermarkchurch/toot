# Toot 📯💨

Toot is a library for basic PubSub over HTTP. Toot fires off event
payloads, and provides simple Rack apps for handling event callbacks and
subscription management that you can mount up in any Rack compatible
app. All of these actions happen through Sidekiq providing asynchronous,
persistent, and fault-tolerant events.

## Usage

TODO: Provide a step-by-step walkthrough from publish to handler from
the perspective of the developer (short) and from the perspective of the
actual payload (technical details).

So let's say you have two applications: Contacts and Orders. The Orders
app uses data from the Contacts app and wants to keep its local cache of
records in sync with the Contacts app.

```ruby
# In the Orders app configuration
Toot.config do |c|
  c.channel_prefix = "com.example.myapp"
  c.callback_url = -> (channel) { "http://myapp.example.com/callback/#{channel}" }

  c.source :contacts, subscribe_url: "https://example.com/sub", channel_prefix: "com.example.contacts"

  c.subscribe :contacts, 'person.updated.v1', EventHandlers::ContactPersonUpdated
  c.subscribe :contacts, 'person.created.v1', EventHandlers::ContactPersonCreated
end
```

The Orders app will run a task that causes it to register these
subscriptions with the Contacts app. Now, when the Contacts app
publishes events the Orders app will receive a callback and the
specified event handler will be run with the payload provided by the
Contacts app keeping all the data in sync.

In order to make all of this work, Toot provides two Rack apps:

* `HandlerService` is a Rack app that receives the event callbacks and
  enqueues background jobs to process the callback and run the appropriate
  handlers.
* `SubscriptionsService` is a Rack app that receives the given
  channel name and a callback URL and registers it in Redis. This allows
  an app to add its `HandlerService` URL as a callback for a given Event
  channel.

These can be mounted into your application however is appropriate for
your web framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toot

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

