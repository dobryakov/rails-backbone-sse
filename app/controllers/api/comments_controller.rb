class Api::CommentsController < ApplicationController
  before_action :set_model, only: [:show, :edit, :update, :destroy]

  def create
    @model = Comment.new(permitted_params.merge(:user => current_user))

    respond_to do |format|
      if @model.save
        format.json { render json: @model.to_json(:user => current_user), status: :created, :layout => false }
      else
        format.json { render json: @model.errors, status: :unprocessable_entity, :layout => false }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_model
    @model = Comment.find(params[:id])
  end

  def permitted_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  end

end
