Project.Views.Comments ||= {}

class Project.Views.Comments.CommentView extends Backbone.View
  template: JST["backbone/templates/comments/comment"]

  events:
    "keypress .wall-comment-input-editable" : "fixcomment",
    "click    .wall-comment-destroy" : "destroy"

  tagName:   'div'
  className: 'comment'

  initialize: () ->
    @model.on('change', this.render, this)

  fixcomment: (e) =>
    if (e.keyCode == 13)
      e.preventDefault()
      e.stopPropagation()
      element = $(e.target)
      element.prop('readonly', true)
      @model.save({body: element.val()},
        success: (result) =>
          showSuccess('Saved')
      )
      return this

  destroy: () ->

    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template( comment: @model.toJSON(), current_user: @model.collection.current_user ))
    return this
