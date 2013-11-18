class User < ActiveRecord::Base  
  belongs_to :employee
  
  validates :loginid, :is_manager, presence: true 
  
  def role_symbols
    require 'net/http'
    require 'json'
    require 'yaml'

    # In case you receive SSL certificate verification errors
    require 'openssl'
    
    uri = URI(DSS_RM_SETTINGS['HOST'] + "/people/#{loginid}.json")
    req = Net::HTTP::Get.new(uri)
    req['Accept'] = "application/vnd.roles-management.v1"
    req.basic_auth(DSS_RM_SETTINGS['USER'], DSS_RM_SETTINGS['PASSWORD'])

    begin
      # Fetch URL
      resp = Net::HTTP.start( uri.hostname, uri.port, use_ssl: true ) { |http|
        http.request(req)
      }
      # Parse results
      buffer = resp.body
      result = JSON.parse(buffer)

      return result["role_assignments"]
        .find_all{ |r| r["application_id"] == STAFF_SCHEDULER_RM_ID }
        .map{ |r| r["token"].to_sym }
    rescue StandardError => e
      $stderr.puts "Could not fetch RM URL #{e}"
      return false
    end
  end
end
