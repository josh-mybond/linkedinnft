json.extract! nft, :id, :wallet_address, :link_to_nft_image, :customer_id, :created_at, :updated_at
json.url nft_url(nft, format: :json)
