Ruby
require 'json'
require 'securerandom'
require 'socket'

class SecureChatbotMonitor
  def initialize
    @chat_log = {}
    @users = {}
  end

  def register_user(username, password)
    return false if @users.key?(username)
    @users[username] = password
    true
  end

  def authenticate_user(username, password)
    return false unless @users[username] == password
    generate_session_token(username)
  end

  def generate_session_token(username)
    token = SecureRandom.uuid
    @chat_log[token] = { username: username, messages: [] }
    token
  end

  def send_message(token, message)
    return false unless @chat_log.key?(token)
    @chat_log[token][:messages] << message
    true
  end

  def get_chat_history(token)
    return false unless @chat_log.key?(token)
    @chat_log[token][:messages]
  end

  def monitor_chat
    server = TCPServer.new('localhost', 2000)
    loop do
      client = server.accept
      token = client.recv(100)
      message = client.recv(1000)
      if send_message(token, message)
        client.puts 'Message sent successfully.'
      else
        client.puts 'Unauthorized access.'
      end
      client.close
    end
  end
end

# Test case
monitor = SecureChatbotMonitor.new
puts monitor.register_user('user1', 'password1') # true
puts monitor.authenticate_user('user1', 'password1') # token
token = monitor.authenticate_user('user1', 'password1')
puts monitor.send_message(token, 'Hello, world!') # true
puts monitor.get_chat_history(token) # ["Hello, world!"]
monitor.monitor_chat