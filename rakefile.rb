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

desc "Prerequisites"
task :preinstall do
  sh "apt-get install libreadline-dev libncurses5-dev libpcre3-dev"
  sh "apt-get install libssl-dev perl make build-essential"
end

desc "install openresty"
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
  ln_sf "sudo #{args[:output]}/#{base}",sym_name
  
end

task :default => :install
