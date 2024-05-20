require 'logger'
require 'rack'
require_relative 'routes'
require_relative 'users_controller'
require_relative 'master_controller'

class MasterServer
  attr_reader :rack_request, :logger

  Routes.draw do
    get '/', to: 'master_controller#index'
    post '/submit', to: 'master_controller#submit'
    get '/wrong', to: 'master_controller#edit'

    get '/users', to: 'users_controller#index'
    get '/users/new', to: 'users_controller#new'
  end

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
  end

  def call(env)
    @rack_request = Rack::Request.new(env)
    log_request
    route_request
  end

  def self.call(env)
    new.call(env)
  end

  private
  def log_request
    logger.debug "Request received: #{rack_request.request_method} #{rack_request.path_info}"
    logger.debug "Params: #{rack_request.params}"
  end

  def route_request
    return if rack_request.path_info == '/favicon.ico'

    begin
      route = find_route(@rack_request.path_info)
      if route
        logger.info "Route found: #{route[:path]}"
        logger.info "Route options: #{route[:options]}"

        controller_name, action_name = route[:options][:to].split('#')
        logger.info "Controller: #{controller_name}, Action: #{action_name}"

        if controller_class = find_controller(controller_name)
          controller_instance = controller_class.new(@rack_request)
          if controller_instance.respond_to?(action_name)
            return controller_instance.send(action_name)
          end
        end
      end
      not_found_response
    rescue => e
      logger.debug "Error: #{e.message}"
      not_found_response
    end
  end

  def find_controller(controller_name)
    class_name = controller_name.split('_').map(&:capitalize).join
    logger.info "#{class_name} defined: #{Object.const_defined?(class_name)}"
    Object.const_get(class_name) if Object.const_defined?(class_name)
  end

  def find_route(path_info)
    Routes.all.find { |route| route[:path] == path_info }
  end

  def not_found_response
    [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
  end
end
