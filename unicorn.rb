worker_processes 2
working_directory './'

timeout 300
listen 4567

pid "./tmp/pids/unicorn.pid"

stderr_path "./log/unicorn.stderr.log"
stdout_path "./log/unicorn.stdout.log"