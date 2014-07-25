require 'httparty'
require 'json'

# The AssignmentManager class represents an interface for programmatic
# interaction with Contingent Staffing/Recruiting Solution, offering
# the same capabilities as the Universal Assignment Manager.
module UAMiR
  class AssignmentManager
    include HTTParty
    class ResponseError < StandardError; end
    class ActionError < StandardError; end
    class RequestError < StandardError; end

    # Initialize an Assignment Manager, which ov
    #
    # @param  rss_url  [String]  the sitename of the Recruiting Solution product.
    # @param  tss_url  [String]  the sitename of the Contingent Staffing product.
    # @param  rss_admin_user_id  [String, Integer]  the id of the Recruition Solution
    #   administrative user that is able to assign documents to the candidates in question.
    def initialize(rss_url, tss_url, rss_admin_user_id)
      @parameters = {
        'AssignedBy' => rss_admin_user_id,
        'TSSUserID' => '0',
        'TempID' => '0',
        'RSSAdminUserID' => rss_admin_user_id,
        'RSSDSN' => 'FCVA765_RSS_Live',
        'RSSURL' => rss_url,
        'RSSBASE' => 'agencyrecruiting.apihealthcare.com',
        'RSSHTTP' => 'https',
        'PacketUser' => '0',
        'TSSURL' => tss_url
      }

      @parameters['sessionKey'] = get_session_key
    end
    
    # Assign document given the user id, document id, document type, and version id (optional).
    #
    # @param  rss_user_id  [String, Integer]  the id of the candidate
    #   to assign the document to.
    # @param  rss_doc_id  [String, Integer]  the id of the document to assign.
    # @param  type  [String]  the type of the document
    def assign_document(rss_user_id, rss_doc_id, type, vers_id = 0)
      action = 'assign'

      url_params = {
        "RSSURL" => @parameters['RSSURL'],
        "action" => action,
        "RSSDSN" => @parameters['RSSDSN'],
        "RSSBASE" => @parameters['RSSBASE'],
        "sessionKey" => @parameters['sessionKey']
      }
      
      data_params = {
        "tempid" => @parameters['TempID'],
        "RSSID" => rss_doc_id,
        "RSSUserID" => rss_user_id,
        "type" => type,
        "TSSUserID" => @parameters['TSSUserID'],
        "AssignedBy" => @parameters['AssignedBy'],
        "VERSID" => vers_id
      }
      
      begin
        res = post_request(url_params, data_params).body
        parsed_res = JSON.parse(res)
        if parsed_res["assignobj"]
          if parsed_res["assignobj"]["code"] != "OK"
            raise AssignmentManager::ActionError, "Error assigning document: #{parsed_res["assignobj"].inspect}"
          else
            return parsed_res
          end
        else
          raise AssignmentManager::ActionError, "Malformed response when deleting request: #{parsed_res.inspect}"
        end
      rescue JSON::JSONError => e
        raise AssignmentManager::RequestError, %{Response was not JSON-parseable
          likely issue with a request value or the session key.\nRequest parameters:
          URL:#{url_params}\nData:#{data_params}\nJSON error:#{e.inspect}}
      end 
    end

    # TODO: Proper documentation
    # Returns array of hashes, each one corresponding to an assigned document for a temp
    # Each hash has: rsscredid, remindedby, assignedby, assignmentid, firstname, adminusername, 
    # credentialname, versionid, username, remindersent, dateassigned, type, lastname
    def get_assigned_documents(rss_user_id)
      action = 'GetTempCredentials'

      url_params = {
        "RSSURL" => @parameters['RSSURL'],
        "action" => action,
        "RSSBASE" => @parameters['RSSBASE'],
        "RSSUserID" => rss_user_id,
        "TSSUserID" => @parameters['TSSUserID'],
        "sessionKey" => @parameters['sessionKey'],
        "ADUserID" => @parameters['RSSAdminUserID'],
        "TempID" => @parameters['TempID']
      }
      
      begin
        res = get_request(url_params).body
        parsed_res = JSON.parse(res)
        if parsed_res["obj"]
          if parsed_res["obj"]["data"]
            request_data = parsed_res["obj"]["data"]
            assigned_documents = request_data.select { |doc| !(doc["rsscredid"].to_s.empty?) }
            return assigned_documents
          else
            raise AssignmentManager::ActionError, "Error retrieving credentials: #{parsed_res["emailobj"].inspect}"
          end
        else
          raise AssignmentManager::ActionError, "Malformed response when retrieving credentials: #{parsed_res.inspect}"
        end
      rescue JSON::JSONError => e
        raise AssignmentManager::RequestError, %{Response was not JSON-parseable
          likely issue with a request value or the session key.\nRequest parameters:
          URL:#{url_params}\nData:#{data_params}\nJSON error:#{e.inspect}}
      end 
    end

    # Sends reminder for all currently assigned documents.
    #
    # @param  rss_user_id  the id of the user who should be sent a reminder
    def send_reminder_for_all(rss_user_id)
      assigned_documents = get_assigned_documents(rss_user_id)
      ids = []
      types = []
      assigned_documents.each do |doc|
        ids << doc['assignmentid']
        types << doc['type']
      end
      reminder_ids = ids.join(',')
      reminder_types = types.join(',')
      send_reminder(rss_user_id, reminder_ids, reminder_types)
    end
    
    # Takes array of ids (which correspond to the assignmentid field) and
    # another array with the type of doc.
    # May raise AssignmentManager::ActionError if returned JSON does not reflect a successful assignment
    #
    # @param  rss_user_id  [String, Integer]  the rss id of the user to send a reminder to
    # @param  ids [Array]  an array of assignment ids for the requests to send reminders for.
    # @param  types [Array]  an array of types for the specified assignment ids. Must be in the same order
    def send_reminder(rss_user_id, ids, types)
      action = 'sendEmail'
      
      url_params = {
        "RSSURL" => @parameters['RSSURL'],
        "action" => action,
        "RSSDSN" => @parameters['RSSDSN'],
        "RSSBASE" => @parameters['RSSBASE'],
        "sessionKey" => @parameters['sessionKey']
      }

      data_params = {
        "tempid" => @parameters['TempID'],
        "IDs" => ids,
        "RSSUserID" => rss_user_id,
        "type" => types,
        "TSSUserID" => @parameters['TSSUserID'],
        "AssignedBy" => @parameters['AssignedBy']
      }

      begin
        res = post_request(url_params, data_params).body
        parsed_res = JSON.parse(res)
        if parsed_res["emailobj"]
          if parsed_res["emailobj"]["code"] != "OK"
            raise AssignmentManager::ActionError, "Error sending reminder: #{parsed_res["emailobj"].inspect}"
          else
            return parsed_res
          end
        else
          raise AssignmentManager::ActionError, "Malformed response when sending reminder: #{parsed_res.inspect}"
        end
      rescue JSON::JSONError => e
        raise AssignmentManager::RequestError, %{Response was not JSON-parseable
          likely issue with a request value or the session key.\nRequest parameters:
          URL:#{url_params}\nData:#{data_params}\nJSON error:#{e.inspect}}
      end 
    end

    # Removes the request for the document matching the given doc id and
    # type from the RSS user corresponding to the rss_user_id. The return
    # value is the parsed return value, usually a generic OK message. If
    # the return value is not formatted properly then an
    # AssignmentManager::ActionError is thrown. If there was another
    # error (usually bad session key), then an AssignmentManager::RequestError
    # is thrown. Even if the item to be deleted is not present in the RSS
    # user's assigned documents, the return value will still be the same.
    #
    # @param  rss_user_id  [String, Integer]  the id of the user to remove the request for
    # @param  rss_doc_id  [String, Integer]  the id of the document to remove
    # @param  type  [String]  the type of the document to remove
    def delete_request(rss_user_id, rss_doc_id, type)
      action = 'delete'

      url_params = {
        "RSSURL" => @parameters['RSSURL'],
        "action" => action,
        "RSSDSN" => @parameters['RSSDSN'],
        "RSSBASE" => @parameters['RSSBASE'],
        "sessionKey" => @parameters['sessionKey']
      }
      
      data_params = {
        "id" => @parameters['TempID'],
        "RSSID" => rss_doc_id,
        "RSSUserID" => rss_user_id,
        "type" => type,
        "TSSUserID" => @parameters['TSSUserID'],
      }

      begin
        res = post_request(url_params, data_params).body
        parsed_res = JSON.parse(res)
        if parsed_res["assignobj"]
          if parsed_res["assignobj"]["code"] != "OK"
            raise AssignmentManager::ActionError, "Error deleting request: #{parsed_res["assignobj"].inspect}"
          else
            return parsed_res
          end
        else
          raise AssignmentManager::ActionError, "Malformed response when deleting request: #{parsed_res.inspect}"
        end
      rescue JSON::JSONError => e
        raise AssignmentManager::RequestError, %{Response was not JSON-parseable
          likely issue with a request value or the session key.\nRequest parameters:
          URL:#{url_params}\nData:#{data_params}\nJSON error:#{e.inspect}}
      end 
    end

    ###################
    #                 #
    # Utility methods #
    #                 #
    ###################

    # Returns the session key for interacting with the UAM REST API as a string
    # - If there was an error parsing the session key from the request, an error will be raised.
    def get_session_key
      action = 'uam'

      url_params = {
        'action' => action,
        'rssuserid' => @parameters['RSSAdminUserID'],
        'rssurl' => @parameters['RSSURL'],
        'rssdsn' => @parameters['RSSDSN'],
        'packetuser' => @parameters['PacketUser'],
        'assignedby' => @parameters['RSSAdminUserID'],
        'tssurl' => @parameters['TSSURL']
      }

      response_body = get_request(url_params).body
      
      key = response_body.match(/sessionKey = '(.*?)';/)[1]
      if key.nil?
        raise StandardError, "Session key not found"
      else
        return key
      end
    end

    # Method to update the session key, if needed.
    def update_session_key
      @parameters['sessionKey'] = get_session_key
    end

    ###############################
    #                             #
    # Formatting and HTTP methods #
    #                             #
    ###############################

    # Formats data for URL/POST data. Takes a hash and returns a string representing the contained data as follows:
    # * String/integer key-value pairs are converted to "key=value"
    # * String/integer keys with a value that is an array of strings are converted to "key=value1&key=value2"
    # * All of the above are joined together with "&" after processing
    #
    # @param  data  [Hash]  the key-value arguments to be converted.
    # @return  [String]  the formatted arguments.
    def format_arguments(data)
      data_array = []
      data.each_pair do |parameter, argument|
        if argument.is_a? Array
          argument.each do |single_argument|
            data_array << "#{parameter}=#{single_argument}"
          end
        else
          data_array << "#{parameter}=#{argument}"
        end
      end
      data = data_array.join("&")
      return data
    end

    # Formats UAM query url given a hash of the arguments.
    #
    # @param  url_params  [Hash]  the arguments to append to the url. For format specification (see #format_arguments)
    # @return  [String]  the url with the formatted arguments.
    def format_url(url_params)
      url_base = "https://agencyrecruiting.apihealthcare.com/UAM2/index.cfm"
      args = format_arguments(url_params)
      url = "#{url_base}?#{args}"
      return url
    end

    # Execute GET request with passed arguments. If response
    # has HTTP code other than 200 then an AssignmentManager::ResponseError
    # is raised.
    #
    # @param  url_params  [Hash]  the arguments to pass to the hash of arguments to be passed. For format specification (see #format_arguments)
    # TODO: @return  [Hash]  ruby hash corresponding to JSON response?
    def get_request(url_params)
      url = format_url(url_params)
      response = self.class.get(url)
      if response.code != 200
        raise AssignmentManager::ResponseError, "GET request response encountered HTTP error #{response.code}"
      end
      return response
    end
    
    # Execute POST request with passed url parameters and passed data.
    #
    # @param  url_params  [Hash]  hash of arguments to be passed in the url
    # @param  data_params  [Hash]  hash of the arguments to be passed as post data
    # TODO: @return  [Hash]  ruby hash corresponding to JSON response?
    def post_request(url_params, data_params)
      # URL to POST to
      url = format_url(url_params)
      
      # Data to include
      data = format_arguments(data_params)
      
      response = self.class.post(url, :body => data)
      if response.code != 200
        raise AssignmentManager::ResponseError, "Post request was met with error #{response.code}"
      end
      return response
    end
  end
end
