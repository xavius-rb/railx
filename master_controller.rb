class MasterController
  %i(index show new create edit update destroy).each do |action|
    define_method(action) do
      [200, {"Content-Type" => "text/html"}, [dispatch(action)]]
    end
  end

  def initialize(rack_request)
    @request = rack_request
    @params = rack_request.params
    @logger = Logger.new(STDOUT)
  end

  def dispatch(action)
    action_response_method = "#{action}_response"
    @logger.debug "Method: #{action_response_method}"

    @logger.debug "#{self.respond_to?(action_response_method)}"
    if self.respond_to?(action_response_method)
      send(action_response_method)
    else
      "Action not found"
    end
  end

  # custom actions
  def submit
    [201, {"Content-Type" => "text/html"}, [submit_response]]
  end

  private
  def index_response
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>User Form</title>
          <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
          <style>
              /* Add your custom styles here */
          </style>
      </head>
      <body class="bg-gray-100 h-screen flex items-center justify-center">
          <div class="max-w-md p-8 bg-white rounded-md shadow-md">
              <h1 class="text-2xl font-bold mb-4">User Form</h1>
              <form action="/submit" method="post">
                  <div class="mb-4">
                      <label for="username" class="block text-gray-600">Username</label>
                      <input type="text" id="username" name="username" class="mt-1 p-2 border border-gray-300 rounded-md w-full" required>
                  </div>
                  <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded-md">Submit</button>
              </form>
          </div>
      </body>
      </html>
    HTML
  end

  def submit_response
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Request Counter</title>
          <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
          <style>
              /* Add your custom styles here */
          </style>
      </head>
      <body class="bg-gray-100 h-screen flex items-center justify-center">
          <div class="max-w-md p-8 bg-white rounded-md shadow-md">
              <h1 class="text-2xl font-bold mb-4">Hello #{@params['username']}!</h1>
          </div>
      </body>
      </html>
    HTML
  end

end