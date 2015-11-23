class Project.Models.Comment extends Backbone.Model
  paramRoot: 'comment'

  validate: (attrs, options) =>
    if (attrs.body.length < 1)
      return "model validation error"

  defaults:
    body:             '...'
    user_id:          null
    username:         null
    likes_count:      0
    commentable_id:   null
    commentable_type: null
    current_user_can_edit: true # default stub


class Project.Collections.CommentsCollection extends Backbone.Collection

  model: Project.Models.Comment
  url: '/api/comments/'

  initialize: (models, options) =>
    @commentable  = options.commentable
    @current_user = options.current_user

    globalCh.vent.on 'global.comment.create.success', (message) =>
      @update_comment(message)
    globalCh.vent.on 'global.comment.update.success', (message) =>
      @update_comment(message)

    return this

  update_comment: (message) =>
    data = JSON.parse(message)
    comment = data.payload.model
    if (@commentable.id == comment.commentable_id && @commentable.type == comment.commentable_type)
      @add(comment, {merge: true})

    return this
