
class ProjectEvent

  def self.publish(event_name, payload = {})

    unless ENV['REDIS_CHANNEL_NAME'].nil?

      require 'redis'
      redis = Redis.new
      redis.publish ENV['REDIS_CHANNEL_NAME'], { 'event_name' => event_name, 'gid' => payload[:model].to_global_id.to_s }.to_json

    end

  end

end