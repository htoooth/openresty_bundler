files = {
  :openresty => "ngx_openresty-1.9.7.2.tar.gz",
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

desc "Prerequisites"
task :preinstall do
  sh "apt-get install libreadline-dev libncurses5-dev libpcre3-dev"
  sh "apt-get install libssl-dev perl make build-essential"
end

desc "install openresty"
task :install do
  
  origin_dir = getwd()
  openresty = extract_file(files[:openresty])
  stream = extract_file(files[:stream])
  
  cd "ngx_openresty-1.9.7.2"
  sh %Q{./configure --prefix=/opt/#{openresty} \
          --with-stream \
          --with-stream_ssl_module \
          --add-module=../
}
  sh "make -j4"
  sh "make install"
  
  cd ".."
  rm_rf "#{openresty}"
  rm_rf "#{stream}"
  
end

task :clean do 
  rm_rf "ngx_openresty-1.9.7.2"
  rm_rf "stream-lua-nginx-module-master"
end

task :default => :install
