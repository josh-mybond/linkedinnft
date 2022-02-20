json.extract! customer, :id, :name, :email, :linkedin_profile_url, :linkedin_profile_image, :created_at, :updated_at
json.url customer_url(customer, format: :json)
json.linkedin_profile_image url_for(customer.linkedin_profile_image)
