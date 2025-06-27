class OrderablesController < ApplicationController

  def update_notes
    orderable = Orderable.find(params[:id])
    if orderable.update(notes: params[:notes])
      head :ok
    else
      head :unprocessable_entity
    end
  end
end