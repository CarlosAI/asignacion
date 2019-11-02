class RequestController < ApplicationController

	skip_before_action :verify_authenticity_token, :only => [:read]

  def index
  	# saludo = Operaciones.prueba 
  	# puts saludo
  end

  def read
  	puts "entro y params son"
  	puts params
  	salida = 200

    if params["_json"].present?
      salida = Operaciones.requestFedex(params["_json"])
    else
      salida = 400
    end

  	respond_to do |format|
        format.json { render json: salida}
    end
  end
end
