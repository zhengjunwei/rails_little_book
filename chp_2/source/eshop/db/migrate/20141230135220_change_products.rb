class ChangeProducts < ActiveRecord::Migration
  def change
  	add_column :products, :price, :decimal, precision: 5, scale: 2
  	add_reference :products, :category, index: true #= add_column :products,:cetegory_id,:integer, index: true
  end
end
