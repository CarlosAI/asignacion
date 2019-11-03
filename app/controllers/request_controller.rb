class RequestController < ApplicationController

	skip_before_action :verify_authenticity_token, :only => [:read]

  def index
  	# saludo = Operaciones.prueba 
  	# puts saludo
  end

  def read
    if params["_json"].present?
      salida = Operaciones.requestFedex(params["_json"])
      la_data = salida[1].to_json
      file_name = "datos_reporte.json"
      open(file_name, 'wb') do |file|
        file.write(la_data)
      end
      data = File.read(file_name)
    else
      salida = 404
    end

    if salida[0] == 200
      salida = salida.to_json
      render status: 200, json: {
        datos: salida, code: 200
      }.to_json
    elsif salida == 404
      render status: 201, json: {
        datos: "No seleccionaste los datos correctos", code: 202,
      }.to_json
    else
      render status: 400, json: {datos: "Internal Server Error",}.to_json
    end
  end

  def reporte_pdf
    puts "los params para report son"
    puts params
    nombre_pdf = "reporte"

    raw_data = File.read("datos_reporte.json")
    data = JSON.parse raw_data
    pdf = ReporteShipments.new(data)
    send_data pdf.render, filename: nombre_pdf, type: 'application/pdf', disposition: "inline"
  end
end
