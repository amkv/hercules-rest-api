#!/usr/bin/ruby
require "oauth2"
# require 'json'
# require "base64"

# 1 argument?
if ARGV.count != 1
	puts "usage:\n      ruby getinfo.rb <text_file>"
	exit
end

# file exist?
file = ARGV[0]
if !File.exist?(file)
	puts "bad file name \'#{file}\'"
	exit
end

# Color class
class String
	def colorize(color_code)
		"\e[#{color_code}m#{self}\e[0m"
	end
	def red
		colorize(31)
	end
	def green
		colorize(32)
	end
end

###############################################################################
## encription
secret_file_alias = "secret"
secret_key_file_alias = "key"
T_UID = "-----------------------------------"
T_SECRET = "-----------------------------------"
secret_file = secret_file_alias
secret_key_file = secret_key_file_alias
secrets = JSON.parse(File.read(secret_file))
UID_ENC = "#{secrets["UID"]}"
SECRET_ENC = "#{secrets["SECRET"]}"
secret_key = JSON.parse(File.read(secret_key_file))
KEY = secret_key["KEY"]
decipher = OpenSSL::Cipher.new('AES-128-CBC').decrypt
decipher.key = KEY
UID_ENC_PLAIN = Base64.decode64(UID_ENC)
UID = decipher.update(UID_ENC_PLAIN)
UID << decipher.final
SECRET_ENC_PLAIN = Base64.decode64(SECRET_ENC)
SECRET = decipher.update(SECRET_ENC_PLAIN)
SECRET << decipher.final
###############################################################################

#get a token
client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
token = client.client_credentials.get_token

#set counter
counter = 0
error = "!error: ".red

#get user by login
File.readlines(file).each do |line|

#chekers
if line.eql? "\n"
	puts "#{error} #{line}"
	next
elsif line[0] == '#'
	puts "#{error} #{line}"
	next
elsif line.length < 2
	puts "#{error} #{line}"
	next
end

#get info
begin
	user = token.get("/v2/users/#{line}").parsed
	counter += 1
rescue
	puts "#{error} #{line}"
	next
end

#get user name and location
loginname = user["login"]
location = user["location"]
firstname = user["first_name"]
lastname = user["last_name"]

#if string is empty
if !loginname
	loginname "#{error} !bad login"
end
if !location
	location = "!probably not at the school"
end
if !firstname
	firstname = "#{error} !bad name"
end
if !lastname
	lastname = "#{error} !bad last name"
end

#print the result
puts "[#{counter}] #{loginname} (#{firstname} #{lastname}) #{location}"
end
if counter == 0
	puts "#{error}no one"
end
exit
