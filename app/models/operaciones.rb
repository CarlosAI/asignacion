class Operaciones

	def self.requestFedex(shipments)
		puts "Entramos a fedex y los params son"
		puts shipments
		trackings_error = []
		path = ENV.fetch('FEDEX_PATH')
		fedex = Fedex::Shipment.new(:key => ENV.fetch('FEDEX_KEY'),
			                            :password => ENV.fetch('FEDEX_PASSWORD'),
			                            :account_number => ENV.fetch('FEDEX_ACCOUNT'),
			                            :meter => ENV.fetch('FEDEX_METER'),
			                            :mode => ENV.fetch('FEDEX_MODE')
			                            )
		shipments.each do |shp|
			puts "Vamos con el tracking_number #{shp["tracking_number"]}"
			fedex_parcel = {}
			shp["errors"] = {}
			xml_req = 
				"<TrackRequest xmlns='http://fedex.com/ws/track/v3'>
					<WebAuthenticationDetail>
						<UserCredential>
							<Key>"+ENV.fetch('FEDEX_KEY')+"</Key>
							<Password>"+ENV.fetch('FEDEX_PASSWORD')+"</Password>
						</UserCredential>
					</WebAuthenticationDetail>
					<ClientDetail>
						<AccountNumber>"+ENV.fetch('FEDEX_ACCOUNT')+"</AccountNumber>
						<MeterNumber>"+ENV.fetch('FEDEX_METER')+"</MeterNumber>
					</ClientDetail>
					<TransactionDetail><CustomerTransactionId>ActiveShipping</CustomerTransactionId></TransactionDetail>
					<Version><ServiceId>trck</ServiceId><Major>3</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version>
					<PackageIdentifier><Value>#{shp["tracking_number"]}</Value><Type>TRACKING_NUMBER_OR_DOORTAG</Type></PackageIdentifier>
					<IncludeDetailedScans>1</IncludeDetailedScans>
				</TrackRequest>"

			url = URI.parse(path)
			http = Net::HTTP.new(url.host,url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE

			response =  http.post(url.path, xml_req)

			if response.code == "200" || response.code == 200
				info = Hash.from_xml(response.body)

				if info["TrackReply"]["Notifications"]["Severity"] == "SUCCESS"
					results = fedex.track(:tracking_number => shp["tracking_number"])
					if results.present?
						tracking_info = results.first
						a = tracking_info.to_json
						res = JSON.parse a
						if res["details"]["notification"]["severity"] == "SUCCESS"
							detalles = res["details"]
							detalles["package_weight"]
							puts "Hasta aqui shp original es es"
							puts shp
							if detalles["package_weight"]["units"] == "LB"
								peso = (2.54)*(detalles["package_weight"]["value"].to_f)
								fedex_parcel["weight"] = peso
							else
								fedex_parcel["weight"] = detalles["package_weight"]["value"].to_f
							end
							# puts "Hasta aqui shp 1 es es"
							# puts shp
							if detalles["package_dimensions"]["units"] == "IN"
								fedex_parcel["length"] = (0.453592)*(detalles["package_dimensions"]["length"].to_f)
								fedex_parcel["width"] = (0.453592)*(detalles["package_dimensions"]["width"].to_f)
								fedex_parcel["height"] = (0.453592)*(detalles["package_dimensions"]["height"].to_f)
							else
								fedex_parcel["length"] = detalles["package_dimensions"]["length"].to_f
								fedex_parcel["width"] = detalles["package_dimensions"]["width"].to_f
								fedex_parcel["height"] = detalles["package_dimensions"]["height"].to_f
							end
							shp["fedex_parcel"] = fedex_parcel
							puts "Hasta aqui shp 2 es"
							puts shp
						else
							trackings_error << [ shp["tracking_number"], "Error: No se obtuvo ningun resultado para esta guia" ]
							shp["errors"] = trackings_error
						end
					else
						trackings_error << [ shp["tracking_number"], "Error conexion con Fedex" ]
						shp["errors"] = trackings_error
					end
				else
					trackings_error << [ shp["tracking_number"] , info["TrackReply"]["Notifications"]["Message"] ]
					shp["errors"] = trackings_error
				end
			else
				trackings_error << [ shp["tracking_number"], "Error conexion con Fedex" ]
				shp["errors"] = trackings_error
			end
		end
		return [200,shipments]
	end

	def self.ValidarJson(params)
		puts "entramos a validar json"
		puts params.class
		puts params
		salida = 400
		homogeno = []
		total_params = params.size
		if total_params > 20
			return salida
		end
		keys_expected = ["tracking_number", "carrier", "parcel"]
		parcel_expected = ["length", "width", "height", "weight", "distance_unit", "mass_unit"]
		if params.class == Array
			puts "paso primer filtro"
			params.each do |shipment|
				puts "llego para el salto del primero"
				puts "vamos con shipment y salida es #{shipment.class}"
				puts shipment
				if shipment.class == Hash
					keys = shipment.keys
					puts "paso segundo filtro"
					if keys.size >= 3
						puts "paso tercer filtro"
						keys_correctas = true
						keys.map { |i| keys_correctas = false if keys_expected.exclude?(i)}
						if keys_correctas
							puts "paso 4 filtro"
							if shipment[keys_expected[0]].class == String || shipment[keys_expected[0]].class == Integer
								puts "paso 5 filtro"
								if shipment[keys_expected[1]].class == String
									puts "paso 6 filtro"
									if shipment[keys_expected[2]].class == Hash
										puts "paso 7 filtro"
										parcel_keys = shipment[keys_expected[2]].keys
										if parcel_keys.size >= 6
											puts "paso 8 filtro"
											keys_correctas = true
											parcel_keys.map { |i| keys_correctas = false if parcel_expected.exclude?(i)}
											if keys_correctas
												puts "paso 9 filtro"
												parcel = shipment[keys_expected[2]]
												data_types = true
												parcel_expected[0..3].map { |k| data_types = false if parcel[k].class != Integer && parcel[k].class != Float && parcel[k].class != String }
												if data_types
													puts "paso 10 filtro"
													parcel_expected[4..5].map { |k| data_types = false if parcel[k].class != String }
													if data_types
														puts "paso 11 filtro"
														puts "llego al ultimo filtro"
														homogeno << 200
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if homogeno.size == total_params
			salida = 200
		end
		return salida
	end
end