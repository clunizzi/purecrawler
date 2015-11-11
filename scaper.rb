require 'net/http'


host = "http://www.ansa.it"

uri = URI.parse host

http = Net::HTTP.new uri.host, uri.port
request = Net::HTTP::Get.new uri.request_uri

response = http.request request

link = /<a\s[^>]*href="([^"]*)"/x          
             

href = []
body = response.body

body.scan(link) do |m|
    href << m
end
 puts href