#!/usr/bin/env ruby
# An HTTP/HTTPS/FTP file downloader library/CLI based upon MiniPortile's
# HTTP implementation.
#
# Author: Jon Maken
# License: 3-clause BSD
# Revision: 2012-03-25 23:01:19 -0600

require 'net/http'
require 'net/https' if RUBY_VERSION < '1.9'
require 'net/ftp'
require 'fileutils'
require 'tempfile'
require 'openssl'

class Downloader

  VERSION = '0.1.0'

  # class attributes
  class << self
    attr_accessor :logger, :max_ca_verify_depth, :ftp_data_chunk_size
  end

  @logger = STDOUT.binmode
  @max_ca_verify_depth = 5
  @ftp_data_chunk_size = 8192 


  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.download_file(url, full_path, count = 3)
    
    puts "downloading to #{full_path}"
    
    return if File.exist?(full_path)

    uri = URI.parse(url)
    
    case uri.scheme.downcase
    when /ftp/
      ftp_download(uri, full_path)
    when /http|https/
      http_download(url, full_path, count)
    end
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------
  
  private

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------
  
  def self.message(text)
    @logger.print text
    @logger.flush
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------
  
  def self.output(text = '')
    @logger.puts text
    @logger.flush
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------

  def self.http_download(url, full_path, count)

    begin
      uri = URI.parse(url)
      filename = File.basename(uri.path)

      if ENV['HTTP_PROXY']
        protocol, userinfo, proxy_host, proxy_port  = URI::split(ENV['HTTP_PROXY'])
        proxy_user, proxy_pass = userinfo.split(/:/) if userinfo
        http = Net::HTTP.new(uri.host, uri.port, proxy_host, proxy_port, proxy_user, proxy_pass)
      else
        http = Net::HTTP.new(uri.host, uri.port)
      end

      if uri.scheme.downcase == 'https'
        http.use_ssl = true
        if ENV['CA_CERT_FILE']
          cert_file = ENV['CA_CERT_FILE'].dup
          cert_file.gsub!(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
        end
        if cert_file && File.exists?(cert_file)
          http.ca_file = cert_file
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.verify_depth = @max_ca_verify_depth
        else
          raise <<-EOT
To download using HTTPS you must first set the CA_CERT_FILE
environment variable to the path of a valid CA certificate file.
A file of bundled public CA certs may be downloaded from:
   http://curl.haxx.se/ca/cacert.pem
          EOT
        end
      end
      
      http.request_get(uri.path) do |response|
        case response
        when Net::HTTPNotFound
          output "404 - Not Found"
          return false

        when Net::HTTPClientError
          output "Error: Client Error: #{response.inspect}"
          return false

        when Net::HTTPRedirection
          raise "Too many redirections for the original URL, halting." if count <= 0
          url = response["location"]
          return http_download(url, full_path, count - 1)

        when Net::HTTPOK
          temp_file = Tempfile.new("download-#{filename}")
          temp_file.binmode

          size = 0
          progress = 0
          total = response.header["Content-Length"].to_i

          response.read_body do |chunk|
            temp_file << chunk
            size += chunk.size
            new_progress = (size * 100) / total
            unless new_progress == progress
              message "\rDownloading %s (%3d%%) " % [filename, new_progress]
            end
            progress = new_progress
          end

          output

          temp_file.close
          File.unlink full_path if File.exists?(full_path)
          FileUtils.mkdir_p File.dirname(full_path)
          FileUtils.mv temp_file.path, full_path, :force => true
        end
      end

    rescue Exception => e
      File.unlink full_path if File.exists?(full_path)
      output "ERROR: #{e.message}"
      raise "Failed to download file"
    end
  end

  #-------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------
  
  def self.ftp_download(parsed_uri, full_path)
    filename = File.basename(parsed_uri.path)

    begin
      temp_file = Tempfile.new("download-#{filename}")
      temp_file.binmode

      size = 0
      progress = 0

      # TODO add user/pw support
      Net::FTP.open(parsed_uri.host) do |ftp|
        ftp.passive = true
        ftp.login
        remote_dir = File.dirname(parsed_uri.path)
        ftp.chdir(remote_dir) unless remote_dir == '.'

        total = ftp.size(filename)

        ftp.getbinaryfile(filename, nil, @ftp_data_chunk_size) do |chunk|
          temp_file << chunk
          size += chunk.size
          new_progress = (size * 100) / total
          unless new_progress == progress
            message "\rDownloading %s (%3d%%) " % [filename, new_progress]
          end
          progress = new_progress
        end
      end

      output

      temp_file.close
      File.unlink full_path if File.exists?(full_path)
      FileUtils.mkdir_p File.dirname(full_path)
      FileUtils.mv temp_file.path, full_path, :force => true

    rescue Exception => e
      File.unlink full_path if File.exists?(full_path)
      output "ERROR: #{e.message}"
      raise "Failed to download file"
    end
  end

end  # Downloader

=begin
if __FILE__ == $0
  usage = <<-EOU
HTTP/HTTPS/FTP File Downloader, v#{Downloader::VERSION}
Usage: ruby download.rb URL FILE
  URL   http/https/ftp location of the file to download
  FILE  full local path at which to save downloaded file
influential environment variables:
  HTTP_PROXY    url to http proxy
  CA_CERT_FILE  full path to CA certificate file
  EOU

  abort usage if ARGV.length != 2

  Downloader.download_file(ARGV[0], ARGV[1])
end



  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.http_download_uri(uri, filename)
    puts "Starting HTTP download for: " + uri.to_s
    http_object = Net::HTTP.new(uri.host, uri.port)
    http_object.use_ssl = true if uri.scheme == 'https'
    begin
      http_object.start do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.read_timeout = 500
        http.request request do |response|
          open filename, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    rescue Exception => e
      puts "=> Exception: '#{e}'. Skipping download."
      return
    end
    puts "Stored download as " + filename + "."
  end
=end
