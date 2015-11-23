About
-----

This is a complete example of two-ways realtime dataflow architecture (between frontend and backend) based on Rails, Backbone and Server-Site Events.

Why?
----

I was looking for a good solutions to organize realtime updates to web application by the most elegant way. I want to implement this: if you change some data (some model) at frontend - it will be changed at backend by "eventually consistent" principle. And if you change some data at backend - it will be changed at frontend (exactly!) in similar way.

Why not ...?
------------

Why not websockets? I have a huge experience in websockets, and I want to say - there are lot of problems. Corporative proxies, disconnects, too complex setup (for beginners), user's sessions, lack of out-of-the-box solutions, and so on.

Why not React.js? I like React, but it is not a magic. It is a technique. If you understand the technique - you can implement it with any tool. Backbone is an excellent way to build reactive web applications: if you change a data - the view will be changed consequently. With Backbone you have "reactive idea", all benefits of MVC and transport layer (out-of-the-box) to build communication with REST backend. Nice, isn't it?

You might like MVC or not, but you should agree: if I have similar MVC at BE and at FE - it could be very elegant idea to build two-ways communication between.

How it works?
-------------

Some setup:

    gem 'devise'
    gem 'redis' # you need a Redis server, of course
    gem 'puma'  # you need actually use it as webserver

The key idea:

When you interact with webpage, you changed the data in Backbone model. When model changed - Backbone sends it to backend and receives an answer. It is a very typical way, but let's ignore this answer and do more.

When comment 'saved' (persisted to database), the model dispatch an event 'global.comment.update.success' to queue with itself as payload (actually, as 'Global ID' string to prevent storing a lot of JSONs in the queue).

The browser setups a SSE long-polling connection to your backend, and actually with your Stream Controller in this example.

The Stream controller received this message from the queue, renders the object to json (like in typical controller action) and dispatch it to SSE channel.

We need to setup Server Side Events connector at frontend ('new EventSource') and subscribe to this event. Connector receives the event and publish it to 'Frontend ESB' (message bus) based on Backbone Radio (wreqr).

The CommentsCollection object receives this event and put it into collection. And - as you remember - when the data is changed, the view will be refreshed automagically.

Voila!

Benefits
--------

1. It's easy.
2. You have as many instances of StreamController as many people are on your website now (and not more).
3. Instances will be closed automatically when user has left your website.
4. In the StreamController you have full controll on the user session ('current_user') through standart tools, without any additional work.

Caveats
-------

When you are using Global ID, you are actually dealing with Rails cache, not with real 'objects loaded from database right now'. If you will use this technique for frequently updated content, uou can get a little out-of-date objects. It is not a lack of the idea - it is a basic behaviour of Rails, and you could change it as you wish (but I'm not).
