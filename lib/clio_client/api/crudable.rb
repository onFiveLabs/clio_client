module ClioClient
  module Api
    module Crudable

      def new(params = {})
        data_item(params)
      end

      def create(params = {})
        new_params = {}
        params.each do |k, v|
          if k.to_s.include?('_id')
            new_params[k.to_s.split('_id')[0]] = { id: v }
          end
        end
        params.merge!(new_params)
        begin
          resource = params.is_a?(Array) ? create_plural(params) : create_singular(params)
        rescue ClioClient::UnknownResponse
          false
        end
      end

      def update(id, params = {})
        begin
          response = session.put("#{end_point_url}/#{id}", {singular_resource => params}.to_json)
          data_item(response[singular_resource])        
        rescue ClioClient::UnknownResponse
          false
        end
      end

      def destroy(id, params = {})
        begin
          session.delete("#{end_point_url}/#{id}", params, false)
        rescue ClioClient::UnknownResponse
          false
        end
      end

      private

      def create_singular(params)
        response = session.post(end_point_url, {singular_resource => params}.to_json)
        data_item(response[singular_resource])
      end

      def create_plural(params)
        response = session.post(end_point_url, {plural_resource => params}.to_json)
        response[plural_resource].map do |resource|
          # Errors are presented inline when doing bulk create via the Clio API
          if resource.key?("errors")
            resource
          else
            data_item(resource)
          end
        end
      end

    end
  end
end
