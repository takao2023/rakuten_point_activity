#!/bin/bash
# Start Sidekiq in the background
bundle exec sidekiq -C config/sidekiq.yml &

# Start a dummy HTTP server so Cloud Run marks the container as healthy
ruby -rsocket -e 'server = TCPServer.new(ENV.fetch("PORT", 8080).to_i); loop do client = server.accept; client.puts "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nSidekiq running"; client.close end'
