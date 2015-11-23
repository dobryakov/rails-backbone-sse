class StreamsController < ApplicationController
  include ActionController::Live

  def index

    response.headers['Content-Type'] = 'text/event-stream'

    unless ENV['REDIS_CHANNEL_NAME'].nil?

      redis = Redis.new
      redis.subscribe(ENV['REDIS_CHANNEL_NAME']) do |on|
        on.message do |channel, data|
          event = JSON.parse(data)
          object = GlobalID::Locator.locate event['gid']
          data = {'payload' => { 'model' => JSON.parse(object.to_json(:user => current_user)) } }
          response.stream.write("event: #{event['event_name']}\n")
          response.stream.write("data: #{data.to_json}\n\n")
        end
      end

    end

    render :nothing => true

  rescue IOError
    logger.info 'Stream closed'
  ensure
    response.stream.close # Prevents stream from being open forever
  end

end
