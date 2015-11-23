class Comment < ActiveRecord::Base

  # ...

  after_commit :dispatch_event, :on => [ :create, :update ]

  def dispatch_event
    MeetplayEvent.publish 'global.comment.update.success', { model: self }
  end

end
