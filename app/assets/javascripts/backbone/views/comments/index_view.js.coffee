Project.Views.Comments ||= {}

class Project.Views.Comments.IndexView extends Backbone.View
  template: JST["backbone/templates/comments/index"]

  events: {
    "keypress .add-comment" : "add",
  },

  initialize: () ->
    @collection.bind('reset',  @addAll)
    @collection.bind('add',    @addOne)
    return this

  add: (e) =>
    if (e.keyCode == 13)
      e.preventDefault()
      e.stopPropagation()
      element = $(e.target)
      @collection.create({
        body:             element.val(),
        commentable_id:   element.attr('data-commentable-id'),
        commentable_type: element.attr('data-commentable-type')
      }, {
        wait: true,
        success: (result) =>
          element.val("")
          element.focus()
          showSuccess('Saved')
      })
      return this

  addAll: () =>
    @collection.each(@addOne)

  addOne: (comment) =>
    view = new Project.Views.Comments.CommentView({model : comment})
    @$(".comments").append(view.render().el)

  render: =>
    @$el.html(@template(commentable: @collection.commentable, comments: @collection.toJSON(), current_user: @collection.current_user))
    @addAll()

    return this
