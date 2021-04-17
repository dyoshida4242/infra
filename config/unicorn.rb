rails_root = File.expand_path('../../', __FILE__)

# プロセスの数
worker_processes 2

# 指定しなくても良い。
# Unicornの起動コマンドを実行するディレクトリを指定します。
# （記載しておけば他のディレクトリでこのファイルを叩けなくなる。）
working_directory rails_root

# プロセスの停止などに必要なPIDファイルの保存先を指定。
pid "#{rails_root}/tmp/pids/unicorn.pid"


# Nginxで使用する場合は以下の設定を行う。
listen "#{rails_root}/tmp/sockets/unicorn.sock"
# とりあえず起動して動作確認をしたい場合は以下の設定を行う。
# listen 8080
# ※「backlog」や「tcp_nopush」の設定もあるけど、よくわかって無い。

# Unicornのエラーログと通常ログの位置を指定。
stderr_path "#{rails_root}/log/unicorn_error.log"
stdout_path "#{rails_root}/log/unicorn.log"


# before_fork
# それぞれのワーカプロセスを fork する前にマスタープロセスから呼ばれる。 Unicorn::Worker オブジェクトを作成したらすぐ呼ばれている
# 読んでもいまいち分からなかったが、参考記事　→　http://ganmacs.hatenablog.com/entry/2017/05/21/170038
before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
