# 2 First Association

**Requirments**
- 了解ORM。
- 了解HTML。

**Destination**
- Migration的细节。
- 了解validation。
- 了解rails里的association。
- 了解rake。
- 了解db:seed。
- 完成给商品添加分类。

**源码**

https://github.com/jerry-tao/rails_little_book/tree/master/chp_2/source/eshop

## Step 0: 需求描述

我们今天将添加一些简单的功能。

给我们的product添加一个分类，这个分类由管理员来进行管理，我们在新建一个商品的时候必须选择一个分类，并且这个商品的name不允许为空。

给我们的product添加一个价格，并且验证product的name不能为空。

## Step 1: 生成Category Model并修改Product

不要忘记新建一个分支来完成今天的代码。

```
git branch category_feature
git checkout category_feature
```

执行下面的命令来生成一个category 的model和migration。

```
rails g model category
```

这个命令可以理解为我们上一张介绍的scaffold的model部分，即只生成跟model相关的migration，model和测试文件。

还记得我们的migration都在哪里吗？ 如果你还记得，找到category的migration让我们来修改一下。

```
class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
	  t.string :name, null: false
      t.timestamps null: false
    end
  end
end
```

跟product的并没有太多区别对吧，主要是我们多传递了一个参数，null: false, 这个参数代表我们这一列不允许是空。

这里我们可以注意一下 create_table 这个方法，第一个参数接受的是表名，我们可以看到已经自动的帮我们把category用复数形式表现出来了。

接下来我们需要修改一下products的表，添加category的关联和价格。

我们先生成一个migration:

```
rails g migration change_products
```



这条命令你可以看到，并没有为我们生成model文件，而是仅仅生成了一个migration文件，这里需要注意的是，migration的名字具有唯一性，也就是说下次你不可以再生成一个 change_products的migration了，所以migration的名字要尽量取得有意义并且详细（比如说 add_price_and_category_to_product）。
接下来我们打开修改一下：

```
class ChangeProducts < ActiveRecord::Migration
  def change
  	add_column :products, :price, :decimal, precision: 5, scale: 2
  	add_reference :products, :category, index: true #= add_column :products,:cetegory_id,:integer, index: true
  end
end
```

这里我们可以看到两个方法，一个是add_column，这个方法的第一个参数是表名，第二个参数是新添加的column名称，第三个参数是类型，我们这里类型是decimal，有效位数是9，保留小数点后两位。

(对:price, scale:2 这种语法有疑问的请自行搜索ruby symble，简单地说 你可以把:price理解为"price",把price:2理解为一个键值对，key是:price, value是2，并且，键值对的参数的顺序并没有任何约束，比如你想写成scale: 2, precision: 5也是可以的，去查看一下ruby的方法参数的使用说明你会对这个问题有更深刻的认识。)

第二个方法是添加一个引用列，我们的product需要引用一个category，即products表里有一个category_id column，跟我注释的地方完成的功能是一致的。

这里最cool的地方就在于我们修改了数据库的结构，却不需要在model里面添加一个price的方法，model会自动的去根据数据库的结构来帮我们添加price相关的方法。

migration是rails对数据库结构操作的核心，rails并不推荐直接去数据库里修改数据库的结构，而是把所有的操作都放到migration里面，便于回滚和协作开发。

生成migration有两种方法（scaffold那个我们就不算了），一就是通过生成model（products, categories）来生成对应的migration，二是通过直接生成一个migration（修改products表）。

如果是model或者rails能理解的migration名称，里面的方法都是change，如果rails不能理解的，里面会帮你生成up和down两个操作。

我们先说一下change，假设我们的一个migration运行失败，那么默认是要回滚回去的，或者我们觉得这次的migration并不是我们想要的，需要回滚到上一个版本的数据库结构，也是要进行回滚操作的。对于那些rails知道如何回滚的操作，比如create_table, 就可以仅仅定义一个change方法。

而对一些rails不知道如何进行回滚的操作，或者一些复杂的数据库结构操作，你就需要分别定义up和down两个方法。up方法表示执行这个migration进行的操作，down方法表示回滚的时候进行的操作。

在我们修改数据库结构的时候，比较常见的是新建表和修改表的结构，还有一些诸如删除列删除表的功能以及每个方法可以接受的详细参数还有如何执行一条SQL命令可以去官方的api里面查看。

migration这个话题除了我们需要使用postgresql的uuid的时候，已经不会再仔细研究了。

## Step 2: 添加Association

上面我们已经在数据库层面完成了对product和category的关联，不过我们还是需要在model里完成一下这个工作的。

修改一下product和category对应的model（找不到的请回到第一章重新阅读）：

```
class Category < ActiveRecord::Base
  has_many :products
end

class Product < ActiveRecord::Base
  belongs_to :category
end
```

我们可以看到，在category里面我们添加了has_many(这也是个方法)，使用的是复数的products，在product里面添加了belongs_to(真的只是一个方法)，来完成两个model之间的双向关联，剩下的工作rails就会自动帮我们完成了，我们可以随便写一些代码测试一下(rails c 的终端里)：

```
category ＝ Category.create(name:'电子产品') #create方法会直接保存到数据库
product ＝ Product.new(name:'iPhone', description:'Just another phone.') #new方法并不会保存到数据库
product.category = category
product.save #这里才保存到数据库
product.category.name 
product.category_id #这个就是正常的属性 上面的是association
```

在这里，当你写了belongs_to rails就会默认使用category_id来查找product的category，同样的，在category里，查找所属于这个category的model的时候也会去products表里面找category_id。

这些都是默认的，同时我也想强调一下，在rails里面默认的都是可以修改的，比如你不想用category_id或者不想用category来做这个关联，都是可以的。

然后，我们是category has_many products, 而不是products has_one category，是因为这样比较符合语意，大多数情况下，我们只需要考虑如何做出符合语意的model就可以了，部分特别情况下，比如需要做关联表，或者1：1关系不得不把key放在另一段，有一个很简单的辨别技巧，如果你想不明白model的关系，可以反过来从数据表设计的关系上考虑一下，写belongs_to这一端，是包含关联key的一端。

## Step 3: 添加Validation

一般来说，我们对一条数据的验证会发生在三个地方，前端验证（Javascript），model验证（我们马上要说的），还有数据库验证（上面的null: false）。 这三者的安全性也是依次递增的。

这里我们在model层面对product的一些属性进行验证，打开product的model代码：

```
class Product < ActiveRecord::Base
  belongs_to :category
  
  validates :name, presence: true #必填
  validates :price, presence: true ,numericality: {greater_than: 0} #必填，必须是数字，必须大于0
  validates :category_id, presence: true # 必填
end
```

在这里面的validates依旧是个方法，接受的第一个参数是我们model的属性，后面的参数是验证的规则。

然后我们在终端里面测试一下（rails c）：

```
product  = Product.new
product.save #这里我们应该可以看到回滚了，并没有保存成功
product.errors #输出一下错误
product.valid? #问号是方法名称的一部分，通常代表返回的是bool值
product.name = 'iphone'
product.price = '4999'
product.category_id = 1
product.save
product.valid?
product.errors 
```

## Step 4: 修改Controller和View

在开始修改我们的controller和view之前，我们需要先在数据库里添加一些category的数据。

打开db/seeds.rb ：

```
Category.create([{name:'电子产品'},{name:'日用品'},{name:'书籍'}])
```
我们添加上面一行，这一行代码的意思是新建了三个category，我们还需要执行一下seeds的命令：

```
rake db:seed
```

这里面就会把我们的seed数据添加到数据库里去了。关于rake的一些说明后面还会有说明。

接下来我们需要修改一下product的controller方法，来允许接收category_id和price这两个属性。

找到product_prarms方法，添加category_id和price两个参数到允许添加的范围内：

```
def product_params
  params.require(:product).permit(:name, :description, :price, :category_id)
end
```

在前面我们已经介绍过这个方法，controller的其他部分不需要修改。

然后我们修改一下view页面，为new和edit product的表达添加一个category的select域。

打开app/views/products/_form.html.erb:

```
<%= form_for(@product) do |f| %>
  <% if @product.errors.any? %>
  <!--现在这部分代码你至少应该可以猜出来是做什么的了-->
    <div id="error_explanation">
      <h2><%= pluralize(@product.errors.count, "error") %> prohibited this product from being saved:</h2>

      <ul>
      <% @product.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :description %><br>
    <%= f.text_field :description %>
  </div>
  <div class="field">
    <%= f.label :price %><br>
    <%= f.text_field :price %>
  </div>
  <div class="field">
    <%= f.label :category %><br>
    <%= f.select :category_id, Category.all.collect { |c| [ c.name, c.id ] }, include_blank: true %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>

```
注意f.select这个方法，这个方法就是生成一个select域的方法，其中第一个参数是要提交的key，第二个参数是一个`[['value','key'],['value','key']]`这种格式的数组而已，include_blank表示是否要包含空的一项用来显示。

然后运行一下服务器，看一下如果直接点submit的新建操作会不会报错给你。

## Step 5: 如何参与到别人的开源项目中去

如果你想参与别人的开源项目，你可以使用github的pull/requet功能。

以本书为例，如果你发现哪里有错误，可以先在我的项目页面点击fork，复制一份这个项目到你自己的git，你clone到本地，修改之后提交到你自己的项目库。

然后打开你自己的这个项目的页面，选择pull/request，新建一个pull/request并填写一些信息之后就可以完成一个pull/request。

这样你的修改就会提交到这个项目的原作者那里，原作者会决定是否接受你这个pull/request。

## 总结

这一章的migration是重点的内容，在这一本书里migration的深度也就到这里了，个人建议还是要去查一下官方的guide来了解一下migration都有哪些方法，以后用的时候可以方便一些。

这一章的其他内容依然只做了解需求，这一章完成之后我希望达到的结果是如果需要你去修改一个表结构你可以操作成功，看见其他的认识是什么，这样就满足了预期。



## 额外知识（自己想办法掌握吧）

1. symble和sting还有key:value
2. ruby方法的参数

## 最后

我们今天加一点额外的小任务，请自己完成在index页面和show页面显示product的price和category。