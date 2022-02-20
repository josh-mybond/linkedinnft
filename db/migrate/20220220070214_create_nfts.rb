class CreateNfts < ActiveRecord::Migration[7.0]
  def change
    create_table :nfts do |t|
      t.string :wallet_address
      t.string :link_to_nft_image
      t.string :customer_id

      t.timestamps
    end
  end
end
