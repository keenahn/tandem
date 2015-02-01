json.array!(@pairs) do |pair|
  json.extract! pair, :id, :group_id, :user_id
  json.url pair_url(pair, format: :json)
end
