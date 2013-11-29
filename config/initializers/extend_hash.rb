class Hash
  def fetch_nested(*keys)
    keys.reduce(self){|acc, k| acc.try(:fetch, k, default)}
  end
end
