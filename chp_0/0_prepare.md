# 0 Prepare

**Requirments**
- 拥有一个基于ubuntu的linux系统(虚拟机/真实系统均可, 个人推荐Linux Mint)或者Mac OS。
- 对linux基本命令有一定的了解。
- 对版本控制系统有一定的了解。
- 基本的mvc认识。

**Destination**
- 学会安装一个开发环境。
- 学会新建和运行一个项目。
- 了解router的功能。
- 了解controller和view对应的模式和功能。

**源码**

https://github.com/jerry-tao/rails_little_book/tree/master/chp_0/source/eshop

## Step 1: Install a Ruby on Rails Environment

Ruby有很多种安装方式，其中包括通过系统的软件包管理(apt-get), 自己编译源码安装以及使用诸如rvm/rbenv的ruby管理工具。

- 软件包的格式。ruby更新还是很快的，各种软件包管理基本都落后一个大版本，所以并不推荐。
- 自己编译源码。这种格式需要一定的linux系统能力，手动的去指定系统依赖位置。
- rvm/rbenv这两种方式都比较灵活，并且可以同时存在多个版本的ruby。

下面介绍的是基于rbenv的安装方式（Ubuntu）。

安装系统依赖

```
sudo apt-get install -y wget vim build-essential openssl libreadline6 libreadline6-dev libsqlite3-dev libmysqlclient-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf automake libtool imagemagick libmagickwand-dev libpcre3-dev language-pack-zh-hans libevent-dev
```

安装rbenv
```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile #如果自己系统瞎是.bashrc 自己修改成.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile #如果自己系统瞎是.bashrc 自己修改成.bashrc
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source ~/.bash_profile #如果自己系统瞎是.bashrc 自己修改成.bashrc
```
rbenv的主页是https://github.com/sstephenson/rbenv  ，更多的安装使用细节可以去他们的网站查看。

安装ruby和rails
```
rbenv install 2.1.5 #自动安装ruby-2.1.5
rbenv global 2.1.5 #把ruby-2.1.5设为系统全局使用版本
ruby -v #确认ruby安装成功
gem install rails #安装rails
```

## Step 2: Create a New Rails Project

好了，基本的环境安装完了，下面我们建立一个简单的项目来测试一下。

新建一个项目
```
rails new eshop #eshop 我们接下来就完成这个项目
```

新建完成之后，我们进入到项目文件及运行一下这个项目。
```
cd eshop
rails s
```
打开浏览器，访问localhost:3000，如果你能成功的看到下面的图片你已经安装成功了。

下面我们把默认的页面替换掉，并简单介绍一下rails里面的view和controller。

执行下面的命令，rails会自动帮我们生成一个新的controller和里面的action，以及这个action对应的view还有一些css和javacript资源。
```
rails g controller home index
#g ＝ generate 可以使用rails generate controller home index 其中home代表的是controller名字 index代表的是action(method)名字
```
我们先来看一下config/routes.rb这个文件。这个文件的功能是把我们的请求映射到对应的方法去执行响应。

打开这个文件我们可以看到刚才我们生成的controller已经在里面了。
```
get 'home/index'
```
这行的意思是我们可以通过get方法访问http://localhost:3000/home/index 这个地址，并且默认会把这个请求映射给HomeController的index方法。

更多的语法细节我们以后会介绍，目前我们只需要关注这个文件是用来做什么的即可。

然后我们把这行删掉，添加下面一行：

```
root 'home#index'
```

这句的意思是把root请求（http://localhost:3000）映射到HomeController的index方法。注意一下这里面的命名约束，是小写并且不包含Controller的controller的名字

好了，现在我们再访问一下http://localhost:3000，这个时候应该已经可以看到默认的home/index的内容了。

让我们继续看一下controller的代码。

打开app/controller/home_controller.rb(注意文件名和类名的对应)，应该看到如下代码：

```
class HomeController < ApplicationController
  def index
  end
end
```
在这里我们可以看到类名和方法基本都是空的，那如何证明rails真的把root映射到这个方法了呢？

我们可以简单的修改一下index的代码：
```
def index
  p 'Hello, im home#index' #p代表在在stdout输出内容。
end
```
现在我们再访问一下http://localhost:3000，然后看一下运行server的终端，应该可以看到 'Hello, im home#index'这一句话在里面打印出来了。

那么我既然什么都没有做，为什么默认的页面会有内容呢？

让我们看一下app/views/home/index.html.erb这个文件，原来我们看到的内容都在这里。

如果你在controller的action里不指定一个view，那么默认会渲染app/view/#{controller}/#{action}.html.erb这个文件。

erb文件是rails默认的一种模板文件（还有其他类型的模板，比如slim和haml，本书不会介绍，感兴趣的读者请自行Google。），这种模板的语法基本与HTML一致，只是在其中可以潜入ruby带啊吗。

好了，回过头来我们修改一下controller和view，看一下他们是如何共享变量的还有在erb里如何使用ruby代码。

首先我们在index里新建一个变量。

```
def index
  @title ＝ 'Hello Rails' #@代表一个实例变量，可以在controller和view之间共享。
end
```

然后我们在app/views/home/index.html.erb里输出这个变量。

```
<h1><%= @title %></h1>
```

现在我们再刷新一下页面，应该可以看到页面上有一个h1的Hello Rails了。

- <%%> 在这个标签内的代码会以ruby代码来执行。

- <%= %> 这个＝号代表直接输出里面的内容。

## Step 3: Push Your Code to Github

首先去https://github.com 注册一个账号。

然后我们需要把我们的ssh-key添加到这个账号，

在你的系统里使用下面的命令生成一个ssh-key，ssh key就相当于你这个系统的身份信息，把这个添加到你的github账号这样你这个系统就有权限对你账号内的仓库进行操作。

```
ssh-keygen
cat .ssh/id_rsa.pub
```

把输出的内容复制一份，在你的gihub页面找到settings 找到ssh key那一项，选择Add 起一个名字并且把复制的ssh-key粘贴进去，保存。

现在回到你的github的主页，选择add repository. 在名字那里输入eshop，点击create repository。

回到我们的项目文件夹，执行下面的命令。

```
git init . #在当前文件夹初始化一个git仓库。
touch README.md #新建一个readme文件，默认会在你的项目主页显示。
git add . #把当前文件夹的所有内容都添加到git仓库。
git commit -m 'first commit'
git remote add origin git@github.com:#{你的用户名}/eshop.git
git push -u origin master
```
好了，现在回到你的github看你刚刚建立的项目，刷新一下，应该看见你的代码已经提交成功了。

## 额外知识
下面几个话题都是经常口水的话题，其争论程度和意义可以参考豆腐脑究竟是咸的还是甜的。我个人不喜欢参与争论，每个问题只简单介绍一下。

1. 系统
为什么不推荐windows，因为使用windows你会遇到很多稀奇古怪的坑，并且参考的经验很少，windows并不是不可以，而是非常不适合开发，极度不推荐。

并且将来部署等也需要对linux有一定的了解，使用linux开发熟悉一下环境也是好的。

2. Ruby的性能。
等你遇到了ruby的性能瓶颈，那么你的产品一定已经很成功了，你可以雇佣20个java/php程序员来重构或者买20台新的服务器来做负载均衡了。

我想表达的就是，也许ruby在某些领域对比其他语言并不具备性能优势，但是我们之中的大部分人不会遇到这个瓶颈。

3. IDE。
这也是经常口水的地方，部分人觉得我们不用ide，只用vim textmate sublime这种东西就足够了，不需要臃肿的IDE。同样的也有部分人觉得诸如rubymine这种IDE用起来更舒服，我觉得这个只要找一个自己使用起来很舒服的就可以了。

即不需要追求只用文本编辑器的能力也不需要看不起使用IDE的人。

好吧，最后问题来了，那么豆腐脑到底应该是甜的还是咸的？


#### TODO
- 补几张截图。
