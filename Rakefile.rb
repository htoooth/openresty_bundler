files = {
  :openresty => "openresty-1.9.7.3.tar.gz",
  :stream    => "stream-lua-nginx-module-master.zip"
}

def extract_file name
  action = {}
  action['.tar.bz2'] = 'tar -jxvf'
  action['.tar.gz'] = 'tar -zxvf'
  action['.bz2'] = 'bzip2 -d'
  action['.7z'] = 'p7zip -d'
  action['.zip'] = 'unzip'
  
  extension = name.scan(/\.[a-z]+\S+/).join
  base_name = File.basename(name,extension)
  sh "#{action[extension]} #{name}"
  base_name
end

desc "Prerequisites some package."
task :preinstall do
  sh "apt-get -y install libreadline-dev libncurses5-dev libpcre3-dev"
  sh "apt-get -y install libssl-dev perl make build-essential"
end

desc "install openresty in output dir, such as: rake install[/opt]"
task :install,[:output] do |t,args|
  
  origin_dir = getwd()
  openresty = extract_file(files[:openresty])
  stream = extract_file(files[:stream])
  
  cd "#{openresty}"
  sh %Q{./configure --prefix=#{args[:output]}/#{openresty} \
          --with-stream \
          --with-stream_ssl_module \
          --add-module=../#{stream} \
          -j4
}
  sh "make -j10"
  sh "sudo make install"
  
  cd ".."
  rm_rf "#{openresty}"
  rm_rf "#{stream}"
  
  sym_name = openresty.split("-")[0]
  cd "#{args[:output]}"
  sh "sudo ln -sf #{args[:output]}/#{openresty},#{sym_name}"
  
end

