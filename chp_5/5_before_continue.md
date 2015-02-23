# 5 Before Continue

**Destination**
- Assets。
- Upload files。
- Pagination。

在开始下一步之前，我们先完善一下现有的内容。主要完成以下三部分内容：

- 添加一个前端框架，bootstrap。
- 为product添加一个图片。
- 为product添加分页功能。

## Step 0： Rails Assets

assets代表着图片，css，js，font这种资源。在rails中assets的使用有些时候还是蛮麻烦的。

首先介绍一下可以放以上内容的位置：

- public

放在public文件夹里的内容将以static的方式对外开放，例如pulic/demo.jpg,你就可以通过访问http://localhost:3000/demo.jpg 来直接访问。

- app/assets, vendor/assets, lib/assets

这三个文件夹的访问方式类似，例如你有一个app/assets/images/demo.jpg, 那么你就可以通过http://localhost:3000/assets/demo.jpg 来直接访问。

一般来说，app/assets下放的是你自己写的内容，vendor/assets下放的是你引用的各种框架，lib内可以放你其他地方需要的assets，不过这些都不是强制性的约束。

并且在你部署之后使用production模式来运行还会涉及到是否需要压缩css，js，编译coffee script，sass，less等等。

我这里将采用最简单的方式来让我们自己添加的框架工作，这部分等我们部署的时候还会介绍一下。

## Step 1: Add Bootstrap

首先到 [http://getbootstrap.com/][1] 下载一份最新的bootstrap压缩包，解压缩之后文件结构如下：

```
├── css
│   ├── bootstrap-theme.css
│   ├── bootstrap-theme.css.map
│   ├── bootstrap-theme.min.css
│   ├── bootstrap.css
│   ├── bootstrap.css.map
│   └── bootstrap.min.css
├── fonts
│   ├── glyphicons-halflings-regular.eot
│   ├── glyphicons-halflings-regular.svg
│   ├── glyphicons-halflings-regular.ttf
│   ├── glyphicons-halflings-regular.woff
│   └── glyphicons-halflings-regular.woff2
└── js
├── bootstrap.js
├── bootstrap.min.js
└── npm.js
```
在这里把bootstrap.css两个文件拷贝到app/assets/stylesheets下，把bootstrap.js拷贝到app/assets/javascripts下，把fonts文件夹拷贝到public下。

在完成之后，我们首先需要修改一下bootstrap.css里的内容，使用搜索功能在这个文件里找到@font-face，把里面的相对路径../fonts修改为绝对路径/fonts/ 并且删掉最后一行指向css.map的注释。

然后修改一下app/assets/javascripts/applications.js， 修改成如下格式：


```
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .
```

然后应该删掉那些自动生成的assets文件，此时文件结构如下：

```
app/assets/
├── images
├── javascripts
│   ├── application.js
│   └── bootstrap.js
└── stylesheets
├── application.css
└── bootstrap.css
```

然后你可以根据bootstrap官网的文档来自定义你的页面了。

这里面额外补充的几句：

- 其实rails是有几个bootstrap的gem包的，我并没有直接使用，是因为考虑到并不是每个css框架都有gem包，并且我个人不喜欢使用那种gem包。
- 其实rails的assets里面还有很多复杂的内容，包括turbolinks， 还有每个assets的指纹标识，这个具体的可以去参考[The Asset Pipeline][2]
- 在这里我想说的是，无论你想做什么，在rails一般都不会只有一种方式，并且很难说有哪一种是’最好的’实现方式，大多数时候你都要根据你自己的应用场景和能力来进行选择。

## Step 2: Product Picture

接下来我们为我们的product模型添加一个上传图片的功能，使用的gems是[CarrierWave][3]。

首先添加`gem 'carrierwave'`到你的Gemfile，然后执行`bundle install` 来安装一下新的gem。

然后为product增加一列用来存储图片的url。

```
rails g migration add_picture_to_products picture:string
rake db:migrate
```

然后来生成一个picture uploader:

```
rails g uploader picture
```

然后修改一下product的model来设置一下uploader：


```
# app/models/product.rb
  mount_uploader :picture, PictureUploader
```

然后修改一下backend/products\_controller.rb把picture添加到允许的params中：

```
params.require(:product).permit(:name, :description, :price, :category_id, :picture)
```

然后我们需要在创建product的表单里添加一个上传文件的field:

```
    <div class="field">
      <%= f.label :picture %>
      <br>
      <%= f.file_field :picture %>
    </div>
```

然后你就可以测试一下上传文件的功能了。

在你想显示图片的地方使用：`<img src="<%= @product.picture_url %>">`即可，这部分就不再描述了。

## Step 3: Paginations

分页功能是很常见的一个功能，所以我们依旧使用一个gem来完成，[kaminari][4]。

使用方法依旧，添加`gem 'kaminari' `到你的Gemfile，然后执行`bundle install`。

操作完成之后我们现在application\_controller.rb里定义一个page方法：

```
private
def page
  param[:page]()
end
```

然后在我们的两个products#index方法上进行一些修改：

```
# app/controllers/products_controller.rb
@products = Product.page page
# app/controllers/backend/products_controller.rb
@products = current_partner.products.page page
```

同样的，在两个index.html.erb的最后加上：


```
# app/views/products/index.html.erb && #app/views/backend/products/index.html.erb
<%= paginate @users %>
```

用来显示页码部分。

至此，我们今天的工作全部完成。

## Step 4: Git ignore
在使用git来进行版本控制的过程中，有些内容我们并不想提交到版本库，例如上面使用CarrieWave在我们开发过程中上传的图片，所有不想提交到版本库的内容你都需要添加到.gitignore文件中。

```
echo '/public/uploads' >> .gitignore
```

## 任务：
- 请参考carrier\_wave的readme来为picture实现resize不同大小用于不同地方显示的功能。
- 参考kaminari的readme来设置每页显示50条内容。
- 使用seed来生成超过100条的product用来检查分页效果。
- 参考[http://getbootstrap.com][6]来美化一下你的页面。

[1]:	http://getbootstrap.com/
[2]:	http://guides.rubyonrails.org/asset_pipeline.html
[3]:	https://github.com/carrierwaveuploader/carrierwave
[4]:	https://github.com/amatsuda/kaminari
[6]:	http://getbootstrap.com/