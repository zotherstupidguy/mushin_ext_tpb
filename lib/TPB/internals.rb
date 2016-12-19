require 'nokogiri'
require 'open-uri'
require 'json'
require 'httparty'
require 'open3' 

module TPB
  module Internal
    class EmptyQuery < RuntimeError
    end

    def search(query)
      p query
      uri 	=  "https://thepiratebay.org/search/#{URI.escape(query)}"
      
      p "running #{File.dirname(__FILE__)}/IUAM.js #{uri}"
      stdin, scraped, stderr 	= Open3.popen3("node #{File.dirname(__FILE__)}/IUAM.js #{uri}")
      p scraped
      doc 			= Nokogiri::HTML(scraped)

      @results = Hash.new
      @results[:torrents] = []

      start_time = Time.now

      doc.xpath('//*[@id="searchResult"]').search('tr').each do |row|
	name = row.search('a.detLink')
	next if name.empty? # Skip empty names

	temp = row.search('font.detDesc').text
	match = temp.match /Uploaded (.*), ULed by .*/

	if !match.nil? then
	  description = match[1] unless match[1].nil?
	  upload_date, total_size = description.split(',')

	  total_size.slice! "Size" #removes the word 'Size'
	  total_size.strip! #removes empty spaces

	  temp = row.search('td')
	  seeders = temp[2].text unless temp[2].nil?
	  leechers = temp[3].text unless temp[3].nil?


	  magnet_link = ""
	  row.search('a').each do |a|
	    if a["href"].match /^magnet.*/
	      magnet_link = a["href"]
	      break
	    end
	  end
	end

	#TODO make the service make sure its .to_json
	@results[:torrents] << { :seeders => seeders, :leechers => leechers, :upload_date => upload_date, :total_size => total_size, :name => name.text, :magnet_link => magnet_link } 
      end

      finish_time = Time.now

      @results[:results_count] = @results[:torrents].count
      @results[:search_time] = finish_time - start_time

      #TODO use logger instead
      puts JSON.pretty_generate @results
      @results
    end
  end
end
