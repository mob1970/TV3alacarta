require 'nokogiri'
require 'open-uri'

TARGET_DIRECTORY = '~/Videos/TV3alacarta/'
#TEXT_TO_REPLACE = #VIDEO_ID#
XML_URL = "http://www.tv3.cat/su/tvc/tvcConditionalAccess.jsp?ID=#VIDEO_ID#&QUALITY=H&FORMAT=MP4"

##
#
#
def get_parameters(params_array)
  url, filename, resume = nil, nil, nil
  case ARGV.length()
    when 2
      url = ARGV[0]
      filename =  ARGV[1]
    when 3
      url = ARGV[0]
      filename = ARGV[1]
      resume = ARGV[2]
   end 
   
  [url, filename, resume]
end

##
#
#
def print_correct_syntax()
  puts "syntax:"
  puts "\tTV3alacartaDumper.rb url filename [--resume]"
  puts
end

##
#
#
def extract_video_id(url) 
  (url =~ /http:\/\/www.tv3.cat.*\/videos\/(\d+)\/.*/) ? $1 : nil
end

##
#
#
def mount_xml_url(video_id)
  XML_URL.gsub("#VIDEO_ID#", video_id)
end

##
#
#
def extract_video_url(video_id)
  video_url = nil
  doc = Nokogiri::XML(open(mount_xml_url(video_id)))
  rows = doc.xpath('//bbd/item/media')
  rows.each do |row|
    if (row.text =~ /(rtmp.+\.mp4).*/)
      video_url = $1
    end
  end
  video_url
end

##
#
#
def fetch_video(video_url, filename)
  system("rtmpdump -r \" #{video_url}\" -o #{filename}")
end


# Getting the source url and if it's a resume action
url_source, filename, resume = get_parameters(ARGV)
if (!url_source)
  puts "Error in parameters"
  print_correct_syntax()
  exit 1
end

video_id = extract_video_id(url_source)
if (!video_id)
  puts "Error extracting video_id from #{url_source}."
  exit 2
end

rtmp_url = extract_video_url(video_id)
if (!rtmp_url)
  puts "No rtmp url found for video_id #{video_id}."
  exit 3
end

fetch_video(rtmp_url, filename)

exit 0
