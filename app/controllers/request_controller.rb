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

  def reporte_pdf
    puts "los params para report son"
    puts params
    # respond_to do |format|
    #   format.pdf do
    #     pdf = Prawn::Document.new
    #     pdf.text "Hellow World!"
    #     send_data pdf.render,
    #       filename: "export.pdf",
    #       type: 'application/pdf',
    #       disposition: 'inline'
    #   end
    # end
      # # puts skus
      nombre_pdf = "reporte"

      # respond_to do |format|
        # format.json { render json: [] }
        #format.html
        # format.pdf do
          pdf = ReporteShipments.new("hola")
          send_data pdf.render, filename: nombre_pdf, type: 'application/pdf', disposition: "inline"
        # end
      # end
  end
end
