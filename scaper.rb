require 'net/http'
#require 'nokogiri'
require 'pp'

class Connection
	attr_reader :host
	def initialize host
		@host = host
	end

	def start_connect
		uri = URI.parse host
		http = Net::HTTP.new uri.host, uri.port
		request = Net::HTTP::Get.new uri.request_uri
		response = http.request request
	end
end

class Crawler
	attr_reader :host, :response
	def initialize host
		@response = Connection.new(host).start_connect
		@host = host
	end

	def crawl deep=1
		case response
		when Net::HTTPSuccess
			crawl_it response.body
		when Net::HTTPRedirection
			redirect = response.header['location']
			puts "Found HTTP Redirect to #{redirect}..."
			follow_redirect response
		else
			puts "Sorry, something went wrong"
		end
	end

	def crawl_it html
		#deep.times do
		href = []
		link = /<a\s[^>]*href="([^"]*)"/x 
		html.scan(link) do |m|
    		href << m[0]
		end

			#body = Nokogiri::HTML html 	
			#links = body.xpath('//@href').map(&:value)
			return link_parser href
	end

	def follow_redirect redirect
		host = redirect.header['location']
		Crawler.new(host).crawl
	end

	def link_parser links		
		internal = []
		links.each do |link|
			internal << uri_parser(link, host)
		end
	end

	def uri_parser link, host
		begin
			URI.parse URI.encode link
			uri = URI.parse URI.encode host
			URI.join(host, link) if uri.route_to(uri+link).host.nil?
		rescue URI::InvalidURIError
			 puts "----------->  Sorry,\nbut i had found a BAD URI ( #{link} ) while crawling #{host}.\nWhy insert #{link} in an hfref attributes?"
		raise
		end
	end

end