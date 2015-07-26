@dir = File.join(__dir__, '../')

worker_processes 2
working_directory @dir

timeout 300
listen "/var/sockets/ikashot.sock", backlog: 1024

pid "#{@dir}tmp/pids/unicorn.pid"

stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"