# 1 First MVC

**Requirments**
- 有一些其他web框架的经验。
- 数据库的基本认识。

**Destination**
- 了解git branch。
- 了解Gemfile。
- 了解rails的文件结构和框架组成。
- 了解rspec。
- 了解dsl。
- 了解REST。
- 完成一个完整的增删改查操作（^.^）。

**源码**

https://github.com/jerry-tao/rails_little_book/tree/master/chp_1/source/eshop

## Step 0: git branch

在开始之前，我们需要先在我们的项目上新建一个git分支，新建的分支与当前分支的代码完全一致（默认情况下我们是在master分支上，即主干）。
分支的作用在于，当我们协作开发时，可以完成各自的工作而互不干扰，并且可以保证项目的主干永远是可运行的代码。

```
cd eshop #进入项目文件夹。
git branch #列出所有分支，*号表示当前所在分支。
git branch -b product_feature #新建一个名为product_feature的分支，注意，此时我们还在master分支上并没有切换过去。
git checkout product_feature #切换到product_feature分支。
```

## Step 1: 替换默认的测试框架

这里我们先要介绍一下项目目录下的Gemfile。

gem是ruby的代码包格式，例如rails也是以gem包发行的（还记得上一节的gem install rails吗）。Gemfile里面包含了我们这个项目里使用的gem包。

打开这个文件我们可以看到诸如下面的信息：

```
gem 'rails', '~> 4.2' #使用rails，版本4.2
```
这个文件里还有很多其他的gem，以后如果我们用到会介绍的。

目前为止，让我们先添加两个gem：

```
gem 'rspec-rails'
gem 'factory_girl_rails'
```
保存之后记得重新执行一下`bundle install`，这个命令会根据Gemfile自动的帮我们安装好gem。

在解释上面两个gem之前我们首先需要了解一下rails的组成。

其实，rails仅仅是个引用（这个词用的不好）的框架，其实rails框架包含很多部分，rails把他们引用在一起。

常见的部分包括：

- activesupport：基础扩展库。
- active_record: 数据库操作相关。
- action_pack: controoler、 router相关。
- action_view: view相关。
- action_mailer: email相关。
- ...

所以，我们可以轻易的对其中的某一部分进行替换，一般来说我们都会使用rspec来替代默认的测试框架，factory_girl来替换默认的测试数据生成的fixture。

在这里加入这两个框架之后我们还需要修改一下引用rails的部分。

打开config/application.rb，找到`require 'rails/all'` 替换成下面的require：
```
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie" 这个是默认的测试框架
```

然后在终端执行下面的命令安装一下rspec：

```
rails g rspec:install
```

加入这个仅仅是为了让大家熟悉一下Gemfile还有rails框架的结构，以及稍后我们会简单介绍下rspec，真正的使用这一章我们并不会涉及，如果大家感兴趣可以自行去https://github.com/dchelimsky/rspec 和 https://github.com/thoughtbot/factory_girl 先了解一下。

## Step 2: 建立商品的scaffold

好了，下面让我们来新建一下关于商品的MVC，我们的商品包含两个字段，name和description。

执行一下下面的命令：

```
rails g scaffold products name:string description:string
rake db:migrate
```

好了，我们已经完成了。运行一下rails s 访问一下 http://localhost:3000/products。是不是已经可以看到一些链接和文字了？

你可以操作一下增删改查，看看是不是基本的增删改查功能都已经具备了？

## Step 3: “是的，但是。。。到底发生了什么？”

`rails g(generate) scaffold` 这句命令（scaffold一般翻译为脚手架，个人觉得很别扭，就不翻译了）这句命令会帮你生成对一个资源进行增删改查操作的所有文件，包括前台的ejb模板一直到对数据库进行修改的命令。让我们一个文件一个文件的走过去。

** migration **

在db/migrate/下你会找到一个20xxxxxxxxx_create_product.rb的文件，我们打开看一眼，这个里面的代码大概如下：

```
class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t| #新建一张名叫products的表
      t.string :name #这个表包含一个name字段，类型是string。
      t.string :description #这个表包含一个description字段，类型是string。

      t.timestamps null: false #这是rails框架自动（默认添加，5.0可能改成默认不添加）添加的，会在你的数据表里添加created_at和updated_at两个字段，前者在创建时被自动赋值，后者在每次更新时被自动赋值。
    end
  end
end
```

在这里要注意一下表的名称，一般来说rails使用复数形式作为表名称，这样model的名称就是Product，诸如person＝>people这种不规则复数也会自动匹配（当然，你也可以自己在model里面指定表名）。

在这个文件里保存了对数据库结构进行更改的操作，以后我们无论修改表结构还是增加删除新表一般都通过不同的migration来完成，这个文件名的时间戳就相当于我们数据库结构的版本号，我们以后可以根据这个进行回滚等操作，并且多人合作的时候不会冲突。

在我们的第二行操作，rake db:migrate这一步，就相当于‘执行db/migration下的所有rb文件’，完成对我们数据库的修改。

在这里有一个疑问，我们的数据库在哪？

打开config/database.yml看一下里面的代码：

```
# SQLite version 3.x
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3

```

我们使用数据库的设置基本都在这个文件里，在我们没有进行修改的情况下默认使用的是sqlite3(一种文件数据库，支持sql语法并且足够简单，一般用于开发阶段。)，其中分为development，test，和production三个数据库（刚才我们默认执行的是development环境），这三种环境分别对应不同的数据库。

所以这个时候你应该看到在db文件夹下有一个development.sqlite3的文件生成，这个就是我们目前使用的数据库。

** Model **

OK，让我们打开app/models/product.rb文件看一下（注意文件名，里面的类名还有migration的文件名，类名之间都是有对应关系的，不要轻易修改。）：

```
class Product < ActiveRecord::Base
end
```

只有一个类声明对吧，那么这个model是否可以被正常使用呢？

来让我们测试一下，在你的项目目录执行`rails c`（加载所有我们在development环境使用的gem，然后运行一个交互式窗口）

```
Product.all # 查看所有的商品。
product = Product.new # 新建一个商品。
product.name = 'iPhone' # 给商品的name赋值。
product.description = 'another phone' # 给商品的description赋值。
product.save # 保存到数据库，
Product.all # 再看一次所有商品。
product = Product.find(1) # 根据id找到商品。
product.description = 'Just another phone' # 修改这个商品的description。
product.save # 保存到数据库。
product = Product.first # 取数据库里的第一条记录。
product.description #输出这个商品的description。
```

通过上面的测试我们可以看到所有必备的操作Product都已经有了，部分方法是继承自ActiveRecord::Base, 比如all save find first等，还有部分方法是ActiveRecord读取我们对应的数据库表结构自动为我们生成的，比如 name=（注意，name=是一个完整的方法名，并不是我们常见的等号赋值操作），name
（name也是一个方法，里面返回值是数据库里的值）等。

** Route && Controller **

打开我们的config/routes.rb，会发现里面多了下面一行，

```
resources :products
```

上次我们说过，routes.rb记录的是请求地址到controller对应方法的映射，这个resource会自动为我们生成下面7条映射规则。

```
GET /products => products#index (代表ProductsController的index方法，下同)
GET /products/:id(代表是个变量，后台可以获取到) => products#show
GET /products/new => products#new
POST /products => products#create
GET /products/:id/edit => products#edit
PUT /products/:id => products#update
DELETE /products/:id => products#destroy
```

这里面都是比较标准的增删改查的操作（以后我们还会涉及到一些自定义的操作），其中你可以看到好多操作都是同一个url，所以HTTP VERB（即GET, POST, PUT, DELETE）在rails里有很重要的意义，其中GET代表这个仅仅是读取，POST代表是新建，PUT代表是修改，DELETE代表是删除。

然后让我们看一下controoler(app/controllers/products_controller.rb)。

注：这里面有很多默认的规则，文件名和类名，controller名称与model名称的对应，可能很难记住，不过写多了也就熟悉了。

```
class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :edit, :update, :destroy] # 在show edit update 和destroy方法之前执行set_product, 这四个方法都需要先得到一个product。
  ...
  private # 只有在自己内部可以使用的内容

    def set_product # 根据参数里的id取到一个product
      @product = Product.find(params[:id])
    end

    def product_params # 允许提交的参数，<input type='text' name='product[name]'>，这种格式的参数后台就会得到一个类似这样格式的hash参数 {product: {name: ''}}。
      params.require(:product).permit(:name, :description) # 然后我们在这里要求我们必须要product这个节点，并且只允许这个节点下的name和description被读取，这样可以防止前台恶意提交其他参数。
    end

end
```

product_controller中其他代码主要是对上面七个地址响应的操作，我们可以自己先看一下其中涉及到model的操作方法，具体细节以后会介绍。

** View **

在app/views/products/文件夹下我们可以看到5个ejb文件（jbuilder文件先不讨论。），除了4个是跟action对应的我们还能看到一个_form.html.erb，一般来说，在rails里以_开头的文件表示这是一个被其他view引用的view。
所以我们打开new和edit都可以看到下面这一句（其他的内容都先跳过）。

```
<%= render 'form' %>
```

这行代码就代表吧form这个erb加载进来（注意，省略了_)。

所以new和edit我们都去_form.html.erb里看一下:

```
<%= form_for(@product) do |f| %>
  ...
<% end %>

```

额，是的，我们的重点就在第一行，第一行我们可以看到一个form_for方法，这个方法接受一个model的实例作为参数，如果你有查看controller里的代码，你会发现在new方法里的product是`@product = Product.new`, 而在edit方法里`@product = Product.find(params[:id])`, 所以这两个model一个是新的空的没有被保存到数据库里的，一个是从数据库里取出来的，form_for方法会根据这个区别分别生成两种不同的表单：

```
<form action='/products' method='POST'> # new页面里的效果
<form action='/products/:id' method='PUT'> # edit页面里的效果。
```

注意：这里面我说form_for是个方法，是因为本身他真的是个helper方法，其次我觉得把它当作一个方法来理解要比通常的把它当作一个标签来理解更容易，不需要引入新的概念。

show.html.erb这个仅仅是把product的值显示出来了，我觉得大家可以完全无障碍的看懂了。

index.html.erb里面主要是通过一个循环把取到的所有 `@products` 数组输出出来，

```
<% @products.each do |product| %> <!--这个是ruby进行枚举操作的一种语法，以后也会介绍。-->
  <tr>
    <td><%= product.name %></td>
    <td><%= product.description %></td>
    <td><%= link_to 'Show', product %></td>
    <td><%= link_to 'Edit', edit_product_path(product) %></td>
    <td><%= link_to 'Destroy', product, method: :delete, data: { confirm: 'Are you sure?' } %></td>  <!-- 这一行是一个删除的操作，具体完成功能的跟jquery_ujs这个javascript lib有关，日后会介绍。-->
  </tr>
<% end %>

```

** RSpec **

我们的测试代码在spec文件夹下，代码组织结构跟app类似，因为我们是scaffold生成的代码，所以在spec/controllers/products_controller_spec.rb里也为我们自动生成了对基本操作的测试。

运行这个测试的方法是：

```
rspec spec/controllers/products_controller_spec.rb # 你也可以运行 rspec spec 就会运行spec下的所有测试文件。
```

这里面的具体语法我不想介绍，只是希望你们看一下describe 和 it这种看起来非常不像 "代码"的东西，貌似它有自己的语法，其实就像我上面说的，这些类似关键字的东西都只是个方法，后面的都是他的参数，在这一章里我也一直强调，大部分在ruby里稀奇古怪的语法一般都是方法，因为在ruby里一个方法并不强制要求（）而且可以把代码块作为参数传递进去，所以很容易做这种非常不像代码，更加具有各自语意的代码。

有一个专门的名词叫做DSL（领域特定语言），就是指根据各种不同的场景制定出针对性的语法，比如上面的describe和it只是两个方法而已。


我真的一次又一次的强调这个也是方法，那个也是方法，只要把这些rails里面稀奇古怪的东西都当作方法来理解，在掌握一下ruby关于方法的知识，在以后无论是理解代码还是排查错误上都非常的容易。

## Step 4: 提交代码

最后让我们把今天写的代码继续提交到我们的版本库：

```
git add . #把当前目录添加进要提交的内容。
git commit -m 'add product feature' #提交代码，提交message是add product feature。
git push origin product_feature #把本地分支提交到远程。
git checkout master #切换回master分支。
git merge product_feature #合并product_feature分支。
git push #把合并后的更新提交到远程。
```

## 总结

这一章以及上一章并没有多少动手内容，大部分内容都是为了理解rails框架的，所以暂时不用纠结在各个细节之上，尽量的对rails框架和项目内的各个文件有一个直观的认识。下一章开始会继续介绍rails并且慢慢的加入一些细节。
