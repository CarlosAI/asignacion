class Operaciones

	def self.requestFedex(shipments)
		puts "Entramos a fedex y los params son"
		puts shipments

		require 'fedex'
		fedex = Fedex::Shipment.new(:key => ENV.fetch('FEDEX_KEY'),
		                            :password => ENV.fetch('FEDEX_PASSWORD'),
		                            :account_number => ENV.fetch('FEDEX_ACCOUNT'),
		                            :meter => ENV.fetch('FEDEX_METER'),
		                            :mode => ENV.fetch('FEDEX_MODE')
		                            )
		results = fedex.track(:tracking_number => "1234567890123")
		
		return 200
	end
end