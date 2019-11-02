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
				res = response.body
				info = Hash.from_xml(res)

				if info["TrackReply"]["Notifications"]["Severity"] == "SUCCESS"
					results = fedex.track(:tracking_number => shp["tracking_number"])
					if results.present?
						tracking_info = results.first
						a = tracking_info.to_json
						res = JSON.parse a
						shp["fedex_parcel"] = {}
						if res["details"]["notification"]["severity"] == "SUCCESS"
							detalles = res["details"]
							detalles["package_weight"]
							if detalles["package_weight"]["units"] == "LB"
								shp["fedex_parcel"]["weight"] = (2.54)*(detalles["package_weight"]["value"].to_f)
							else
								shp["fedex_parcel"]["weight"] = detalles["package_weight"]["value"].to_f
							end
							if detalles["package_dimensions"]["units"] == "IN"
								shp["fedex_parcel"]["length"] = (0.453592)*(detalles["package_dimensions"]["length"].to_f)
								shp["fedex_parcel"]["width"] = (0.453592)*(detalles["package_dimensions"]["width"].to_f)
								shp["fedex_parcel"]["height"] = (0.453592)*(detalles["package_dimensions"]["height"].to_f)
							else
								shp["fedex_parcel"]["length"] = detalles["package_dimensions"]["length"].to_f
								shp["fedex_parcel"]["width"] = detalles["package_dimensions"]["width"].to_f
								shp["fedex_parcel"]["height"] = detalles["package_dimensions"]["height"].to_f
							end
						else
							trackings_error << [ shp["tracking_number"], "Error: No se obtuvo ningun resultado para esta guia" ]
						end
					else
						trackings_error << [ shp["tracking_number"], "Error conexion con Fedex" ]
					end
				else
					trackings_error << [ shp["tracking_number"] , info["TrackReply"]["Notifications"]["Message"] ]
				end
			else
				trackings_error << [ shp["tracking_number"], "Error conexion con Fedex" ]
			end
		end

		puts "El hash final es"
		puts shipments
		return 200
	end

	def self.toCentimeters(pulgadas)
		return pulgadas * 2.54.to_f
	end

	def self.toKg(libras)
		return libras * 0.453592.to_f
	end
end