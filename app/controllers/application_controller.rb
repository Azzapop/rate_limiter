class ApplicationController < ActionController::API

  def rand
    render json: { num: Random.rand(27) }, status: 200
  end
end
