#/usr/bin/ruby
require "oauth2"

##
## Script helps you create two files: secret and key
##
## UID = "your_uid"
## SECRET = "your_secret"
## password = "enter you password here"
## secret_file = "file name for store encrypted UID and SECRET"
## key = "file name for store key info for decryption"
##
UID = "----------------------------------------------------"
SECRET = "----------------------------------------------------"
password = "----------------------------------------------------"
secret_file = "secret"
key_file = "key"

## show the encription methods
# puts OpenSSL::Cipher.ciphers
# exit
## encryption method
cipher = OpenSSL::Cipher.new('AES-128-CBC').encrypt
## create a key
key =  Digest::SHA1.hexdigest(password)
cipher.key = key

## encrypt data
TEMP_UID_ENC = cipher.update(UID)
TEMP_UID_ENC << cipher.final
UID_ENC = Base64.encode64(TEMP_UID_ENC)
UID_ENC.delete!("\n")

TEMP_SECRET_ENC = cipher.update(SECRET)
TEMP_SECRET_ENC << cipher.final
SECRET_ENC = Base64.encode64(TEMP_SECRET_ENC)
SECRET_ENC.delete!("\n")

## create secret file
if !File.exist?(secret_file)
	File.new(secret_file, "w+")
	puts "#{secret_file} file created"
else
	puts "#{secret_file} exist"
end
## create key file
if !File.exist?(key_file)
	File.new(key_file, "w+")
	puts "#{key_file} file created"
else
	puts "#{key_file} exist"
end
## write to secret file
File.open(secret_file, "w") do |sfile|
	sfile.write("{\n")
	sfile.write("\t\"UID\" : \"#{UID_ENC}\", \n")
	sfile.write("\t\"SECRET\" : \"#{SECRET_ENC}\"\n")
	sfile.write("}\n")
end
## write to key file
File.open(key_file, "w") do |kfile|
	kfile.write("{\n")
	kfile.write("\t\"KEY\" : \"#{key}\"\n")
	kfile.write("}\n")
end

puts "DONE"
exit
