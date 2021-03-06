About
-----

This is a complete example of two-ways realtime dataflow architecture (between frontend and backend) based on Rails, Backbone and Server-Side Events.

![Two ways dataflow](/two-ways-dataflow-sse.png?raw=true "Two ways dataflow")

Why?
----

I was looking for the good solutions to organize realtime updates to web application in the most elegant way. I wanted to implement this: if you change some data (a model) at frontend - it will be changed at backend by "eventually consistent" principle. And if you change some data at backend - it will be changed at frontend (exactly!) in similar way.

There are a blog post on this topic: [Microservices in a frontend](http://www.dobryakov.net/blog/21/)

Why not ...?
------------

Why not websockets? I have a huge experience in websockets, and I want to say - there are lot of problems. Corporative proxies, disconnects, too complex setup (for beginners), user's sessions, lack of out-of-the-box solutions, and so on.

Why not React.js? I like React, but it is not a magic. It is a technique. If you understand the technique you can implement it with any tool. Backbone is an excellent way to build reactive web applications: if you change the data - the view will be changed consequently. With Backbone you have "reactive idea", all benefits of MVC and transport layer (out-of-the-box) to build communication with REST backend. Nice, isn't it?

You might like MVC or not, but in my opinion, if I have similar MVCs, one at backend and other at frontend, it could be a very elegant idea to build two-ways communication between them.

How it works?
-------------

Some setup:

    gem 'devise'
    gem 'redis' # you need a Redis server, of course
    gem 'puma'  # you need actually use it as webserver

And you need to setup an environment variable:

    ENV['REDIS_CHANNEL_NAME']

I suggest you to use 'dotenv-rails' gem.

The key idea
------------

When you interact with webpage, you change the data in Backbone model ('Comment' in this example). When model changed, Backbone sends it to the backend API and receives an answer (full JSON representation of the object). It is a very typical way, but let's ignore this answer and do more.

When comment is 'saved' (persisted to database), the backend model dispatches an internal event 'global.comment.update.success' to queue with itself as payload (actually, as 'Global ID' string to prevent storing a lot of JSONs in the queue).

The browser setups an 'SSE' (long-polling) connection to your backend, and actually with your Stream Controller in this example. The javascript mechanism subscribes to this event by special connector ('EventSource').

The Stream controller receives this message from the queue, renders the object to json (like in typical controller action), and dispatches it to SSE channel.

We need to setup Server Side Events connector at frontend ('new EventSource') and subscribe to this event. Connector receives the event and publishes it to 'Frontend ESB' (message bus) based on Backbone Radio (wreqr).

The CommentsCollection object receives this event and puts it into collection (adds or merges, actually). And - as you remember - when the data is changed, the view will be refreshed automagically.

Voila!

You can use as many Backbone models or collections to handle many different events as you want, of course. You can use frontend 'ESB' to communicate between your models at frontend only, of course. And several events could be dispatched from backend originally to maintain your frontend application in the consistent state.

Benefits
--------

1. It's easy.
2. It is an ordinary HTTP (no 'switching protocols'), and it should reconnect automagically (as described in the docs).
3. You have as many instances of StreamController as many people are interacting with your website now (and not more).
4. Each instance will be closed automatically when user has left your website.
5. In the StreamController you have full control on the user session ('current_user') through standart tools, without any additional work.

Caveats
-------

1. You need a lot of conversions between 'internal data' and JSON representations. Just use it as a black box.
2. You need to setup a 'heartbeat' (publish stub message to the Redis queue every N seconds) to avoid 'halting' of the connection pool without any messages.
3. When you are using Global ID, you are actually dealing with Rails cache, not with real 'objects just loaded from database'. If you use this technique for frequently updated content, uou can get a little out-of-date objects. It is not a lack of the idea - it is a basic behaviour of Rails, and you could change it as you wish (but I'm not).
