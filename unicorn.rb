@dir = __dir__

worker_processes 2
working_directory @dir

timeout 300
# listen 4567
listen "/tmp/unicorn.sock", backlog: 1024 # UNIXソケットを見るように変更

pid "#{@dir}tmp/pids/unicorn.pid"

stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"