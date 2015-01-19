# 3 Basic User System

**Destination**
- Association的细节。
- *使用devise。
- view的细节。
- *routes。

**Warning**
- 这一张完成的很匆忙，可能会有些错误或者逻辑不通顺的地方。
- 从这章开始将不再提供源码。

## Step 0: 需求描述

我们目前的功能是任何人都可以对product进行操作，现在我们要加入一个用户系统，包含两种用户角色，partner用户可以对自己的product进行增删改查，普通用户只可以浏览product。

## Step 1: 添加devise并进行配置

devise是一个功能强大的用于构建用户系统的ruby gem，常见的用户系统功能比如注册，邮件验证，锁定等功能该gem都可以实现。项目主页：https://github.com/plataformatec/devise。

首先修改Gemfile添加下面一行：

```
gem 'devise'
```

然后执行`bundle install`。跟rspec一样，我们在使用devise之前也要进行一些配置。

```
rails g devise:install
```

在这里rails g = rails generate 跟rails s ＝ rails server，rails c ＝ rails console一样，也只是一个简写。

generate命令会执行一些generator，例如我们生成model和migration的generator（rails自带一些，gem里经常也会有一些，你也可以自己写一些），并不是每一个gem都会包含自定义的generator。。

上面这个generator是用来生成devise的config文件。

新建的devise.rb在config/initializers/文件夹下，这个文件夹下的内容会在当你运行rails s或者rails c的时候被执行，类似于初始化一些配置，所以如果你修改了这里面的内容是需要重启服务器的。

执行完这一步之后我们应该可以看到很多devise带的提示信息，

我们先添加一个叫做partner的用户用来操作product：

```
$rails g devise partner
invoke  active_record
create    db/migrate/20150118144537_devise_create_partners.rb
create    app/models/partner.rb
insert    app/models/partner.rb
route  devise_for :partners

```

正如你看到的，这个generator会帮我们生成一个model以及他的migration文件，还有稍微修改了一下路由。

让我们先看一下migration:

```
class DeviseCreatePartners < ActiveRecord::Migration
  def change
    create_table(:partners) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""  #默认使用email注册
      t.string :encrypted_password, null: false, default: ""  #密码是加密过的

      ## Recoverable 这部分在使用email重设密码的时候使用
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable 记住用户的登陆信息
      t.datetime :remember_created_at

      ## Trackable 追踪用户登陆信息使用
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable 注册之后是否需要确认邮件
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable 是否使用锁定用户功能
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps
    end

    add_index :partners, :email,                unique: true
    add_index :partners, :reset_password_token, unique: true
    # add_index :partners, :confirmation_token,   unique: true
    # add_index :partners, :unlock_token,         unique: true
  end
end

```

注：在这里如果使用confirmable和recoverable我们需要配置一下我们的email服务，以后会介绍，所以暂时这两部分功能不会成功。

同样的，在partner的model里你会看到：

```
# Include default devise modules. Others available are:
# :confirmable, :lockable, :timeoutable and :omniauthable
devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
```

所以，这两部分是对应的，例如你想启用confirmable的功能，你需要同时把:confirmable加入到model的devise方法的参数列表内同时把confirmable部分加入到partner的数据表。

在routes.rb内我们会看到下面一行：

```
devise_for :partner
```

这个会帮我们生成一系列的mapping，可以使用`rake routes`查看详细地址。默认情况下登陆地址会是 `/partners/sign_in`。

更多的细节你都可以去devise的项目主页查看，因为devise的文档写的非常详细，包括wiki页，基本涵盖了我们经常使用到的功能。

注：devise里还有很多细节值得介绍，可是一方面我觉得我很难比他们官方的文档写得好，另一方面我觉得如果我完全把他们的官方文档copy一份也并没有意义，所以如果在你的使用过程中有哪里不明白可以留言给我，我会考虑在这里详细解释一下。


## Step 2: 修改product模型

在这里我们需要再次修改我们的product模型，让我们的product belongs to partner:

```
rails g migration add_partner_to_product
```

打开新建的migration文件：

```
def change
  add_column :products, :partner_id, :integer
  add_index :products, :partner_id
end
```

然后修改partner和product的model：

```
class Product < ActiveRecord::Base
  belongs_to :partner
  ...
end
class Partner < ActiveRecord::Base
  has_many :products
  ...
end
```

在这里我们建立里products和partners的关联，下一步让我们来修改一下controllers和views来完成需求。

## Step 3: routes

在开始修改controllers和views之前，我们首先需要详细的介绍一下rails的route。

执行一下`rake routes` 你会看到目前app内所有的mapping，其中第一列是mapping的名称（可以为空），第二列是HTTP verb （GET POST PUT DELETE），第三列是访问的地址，第四列是对应的方法。

如果一条route有name，例如produts，那么rails会自动帮我们生成两个方法：`products_path`和`products_url`。前者的返回值是`/products`，后者是`http://ip:prot/products`, 所以在这里我们可以重新认识一下link_to这个生成a标签的方法：

```
<%=link_to 'New Product', new_product_path%> #这个就会生成一个 <a href='/products/new'>New Product<a> 的a标签。
```

*_url这种方法一般用于controller的redirect_to，一般是在执行某个操作成功之后跳转到某个页面（这个以后还会介绍）。

然后我们想把普通用户和partner用户访问products的地址分开，普通用户访问/products 来查看products，partner用户访问/backend/products 来对自己的products进行管理。

我们先找到旧的products的路由:
```
resources :products
```

修改成：
```
resources :products, omly:[:show, :index] #只使用7个路由中的两个
```

然后再为partner添加下面的新路由：

```
namespace :backend do
  resources :products
end
```

在这里我们使用里namespace，namespace是一个很好的来细分我们功能的方式，在routes中使用上面的namespaces，将会在url的mapping和controller的mapping前面都加上admin

例如：`/backend/products` => `backend/products#index` #backend模块下的products controller的index方法。

## Step 4: View&Controller

然后我们需要在controller下新建一个文件夹backend，并且新建一个base_controller的controller:

```
mkdir app/controllers/backend
touch app/controllers/backend/base_controller.rb
```

然后修改一下base_controller.rb的内容：

```
class Backend::BaseController < ApplicationController
  before_filter :authenticate_partner!
end
```

before_filter 会在每个action之前执行，在其中做一些拦截的操作，在这里我们使用authenticate_partner! 这个方法来要求必须登陆的partner用户才可以访问。

然后再新建一个products_controller.rb:

```
touch app/controllers/backend/products_controller.rb
```

然后你可以把app/controllers/products_controller.rb里的内容copy过来 我们稍微修改一下：

```
class Backend::ProductsController < Backend::Basecontroller # 注意这里继承了base_controller所以里面的操作都是需要partner登陆之后的。
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @products = current_partner.products # current_partner 是devise为我们生成的 代表当前登陆的partner current_partner.products代表当前登陆用户的所有商品，在这个关系集上可以进行跟Product类似的操作。
    respond_with(@products)
  end

  def show
    respond_with(@product)
  end

  def new
    @product = current_partner.products.new
    respond_with(@product)
  end

  def edit
  end

  def create
    @product = current_partner.products.new(product_params)
    @product.save
    respond_with(@product)
  end

  def update
    @product.update(product_params)
    respond_with(@product)
  end

  def destroy
    @product.destroy
    respond_with(@product)
  end

  private
  def set_product
    @product = current_partner.products.find(params[:id])
  end

  def product_params
    params[:product]
  end
end

```

同样的，我们需要为backend namespace新建一个view的文件夹：

```
mkdir app/views/backend/products
```

然后你可以把app/views/products/下的文件都copy一份过来，然后修改里面的link_to和form_for。

```
link_to 'Show', product => link_to 'Show', [:backend,product]
# 这句话原本的意思是访问product默认的url 即/products/:id, 再加入namespace之后，你需要把namespace作为一个sym参数使用。这样生成的链接就是/backend/products/:id
link_to 'Edit', edit_product_path(product) => link_to 'Edit',edit_backend_product_path(product)
# 这里你可以参考rake routes的结果了。
form_for(@product) => form_for([:backend,@product)
# 这里跟show标签一致。
```

其余的部分可以参考上面继续修改。

接下来我们需要修改一下我们用户访问的products_controller.rb，app/controllers/products_controller.rb:

```
class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  respond_to :html

  def index
    @products = Product.all
    respond_with(@products)
  end

  def show
    respond_with(@product)
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end
end

```

删掉那些普通用户不会访问的action即可，同样的，你也可以删掉app/views/products下的_form.html.erb、new.html.erb还有edit.html.erb。

并且修改一下剩下的index.html.erb还有show.html.erb，删掉那些用不到的link_to。

然后你可以运行服务器访问http://localhost:3000/backend/products 来测试一下是否需要你登陆（这里你可以随便注册一个新的用户即可），登陆之后所有功能是否如预期一样正常，同样的你可以访问http://localhost:3000/products/ 来检测一下普通用户访问是否正常。

## 总结

这一章主要讲的是devise的使用，或者说，第三方Gem的使用。

在rails的项目中，你将会使用很多其他人开发的gem来帮助我们实现各种基本功能，比如用户系统，权限系统，分页，上传文件，后台任务等等。

大部分的gem使用方法在他们gem的readme主页都可以找到，在这里devise的使用比较有代表性，所以在这里详细的介绍了一下使用一个第三方gem都会发生什么。

还有关于route的namespace，这部分没什么复杂的内容，注意一下名称的对应就可以。

## 最后

我们今天加一点额外的小任务，自己添加rails_admin gem并且使用其配置一个基本的包含administrator验证的后台管理模块。
- 你需要添加rails_admin gem。
- 你需要通过devise新建一个administrator的模型。
- 你需要仔细查看rails_admin 的文档去找到如何配置使用administrator验证。
