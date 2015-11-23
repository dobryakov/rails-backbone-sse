class Project.Routers.CommentsRouter extends Backbone.Router
  initialize: (options) ->
    @comments = new Project.Collections.CommentsCollection({}, options)
    @comments.reset options.comments
    @view = new Project.Views.Comments.IndexView(collection: @comments)
    $("#comments-list").html(@view.render().el)
    return this

