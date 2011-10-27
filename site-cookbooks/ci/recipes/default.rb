package "xfsprogs" do
  action :install
end

directory node[:jenkins][:server][:home] do
  #owner node[:jenkins][:server][:user]
  #group node[:jenkins][:server][:group]
  recursive true
  action :create
end

mount node[:jenkins][:server][:home] do
  device node[:jenkins][:server][:ebs_device]
  options "rw noatime"
  fstype node[:jenkins][:server][:fstype]
  action [:enable, :mount]
  # Don't mount if this is already mounted. Is the needed?
  # not_if "cat /proc/mounts | grep " node[:jenkins][:server][:home]
end
