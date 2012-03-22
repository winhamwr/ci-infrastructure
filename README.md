# Continuous Integration Boostrapper

Getting a fresh Jenkins server set up is kind of a pain and because of that,
fewer projects have one than should. This project is designed to make it easy
for people to fork and get set up with their very-own Jenkins server in the
cloud because CI is awesome. 

Right now it only supports Jenkins on Ubuntu 10.04 on Amazon EC2, but pull
requests are welcome.

## How does this work?

ci-infrastructure uses  [Chef](http://wiki.opscode.com/display/chef/Home)
driven via [littlechef](https://github.com/tobami/littlechef) to make the setup
as painless as possible. You fork this project, configure your ec2 credentials,
configure your SSH access and then you're a couple of commands away from a
maintanable CI setup that you can use to make your software more awesome.

## Usage

### 1. Fork and Clone This Repository

It's not required, but it's recommended that you fork this repository. This
allows you to make customizations and actually commit them in to source
control, which is a good thing. It also means you're only a little bit of work
from submitting pull requests to make this project better and remove some
manual work.

    $ git clone --recursive git://github.com/winhamwr/ci-infrastructure.git

### 2. Install Chef

Because of some recent changes to the way Chef uses ruby vs json metadata
files, we now need to install Chef and Knife locally for most cookbooks to
work. It's annoying, but hopefully will be solved by littlechef another way.
See [this issue](https://github.com/tobami/littlechef/issues/15) for details.

The [official chef installation
docs](http://wiki.opscode.com/display/chef/Workstation+Setup) are the place to
go if anything goes wrong, but on Ubuntu, assuming you already have rubygems,
you can just run:

    $ gem install chef --no-ri --no-rdoc

### 3. Install the Python Requirements

Littlechef is a python project that uses [Fabric](http://fabfile.org) under the
hood to allow most of the power that comes with a chef server only without the
overhead of configuring a server. If you're not familiar with python, you'll
want to read a quick tutorial on [Pip](http://pypi.python.org/pypi/pip) and
[virtualenv](http://www.virtualenv.org/) to make your life
easier (they're the rough python equivelents to RVM/Bundler/NPM etc). I
recommend this 
[pip + virtualenv introduction](http://www.mahdiyusuf.com/post/5282169518/beginners-guide-easy-install-pip-and-virtualenv).

Alternatively, you can just run these commands.

    $ easy_install pip
    $ pip install virtualenv
    $ mkdir ~/.virtualenvs
    $ virtualenv ~/.virtualenvs/ci-infrastructure
    $ pip install -r path/to/ci-infrastructure/requirements.txt

### 4. Launch Your EC2 Node

Note: I'd prefer to make this possible with a one-command solution via this
project, but for now, these are manual steps. Pull requests very welcome.

1. Sign in to the [aws console](http://console.aws.amazon.com)
2. Use the 32-bit instance root store Ubuntu 10.04 AMI in your preferred region
  from [this list](http://uec-images.ubuntu.com/releases/10.04/release/) to
  launch your ec2 instance. Click the ami links to redirect to the console launch
  screen for a handy shortcut. I recommend the High-CPU Medium instance.
3. Use the console to create a new 20GB EBS volume in the same availability zone as your freshly-launched instance.
4. Attach the new EBS volume to your instance as device `/dev/sdj` (or whatever you'd like).
5. Optionally, create and attach an elastic IP and point a DNS entry you
  control at that IP. eg. jenkins.yourproject.com

### 5. Configure SSH Authentication

Littlechef needs to know how to authenticate to your ec2 instance and gives you
the ability to set a username, password and private key. My preference though,
is to just use your existing `~/.ssh/config` file since that puts connecting to
your instances on the same level as all of the other SSH work you do. It also
means that if you konw how to use an ssh config, you can do other cool stuff.
Because of this, the auth.cfg that comes with this project just points to your
existing ssh configuration file.

There's an example bit of configuration located at `ssh_config.example` to get
you started. You can concatonate the example to your `~/.ssh/config`, edit a
few values and then keep rolling.

    $ cat ssh_config.example >> ~/.ssh/config

Then open your `~/.ssh/config` in your favorite text editor and change the
following values:

* `ec2_public_dns` should be whatever URL you're using to reach your instance
* `ec2_private_key` is the path to the AWS key pair file you used to create the instance

### 6. Configure Littlechef for Your Instance

Now it's time to create a `node` configuration for our ec2 instance so that
Littlechef knows where to go and what to do. Replace `ec2_public_dns` with your
actual value of course:

    $ cat nodes/example.json > nodes/ec2_public_dns.json

Now open that file and replace `ec2_public_dns` with the appropriate value. If
you used something other than `/dev/sdj` for your EBS volume mountpoint, you'll
want to change that also.

### 7. Put Littlechef to Work

Now it's time to let Littlechef mount your EBS volume, install and configure
Jenkins and then put an Nginx reverse-proxy in front of Jenkins.

    $ fix node:ec2_public_dns deploy_chef
    $ fix node:ec2_public_dns

### 8. Configure Jenkins

You're all set! Now go to the URL you've been using through your browser and
get your Jenkins instance configured to do what you need. Right off the bat,
I'd recommend going to `Manage Jenkins` - `Configure` and checking the `Enable
security` box so that you can set up user accounts. Keeping your build server
open to the internet is kind of a security risk.

## Contributing

We've got plenty of things to improve, so pull requests are very welcome. 

Future plans exists as github issues, so feel free to file issues if you'd
like to see something.



