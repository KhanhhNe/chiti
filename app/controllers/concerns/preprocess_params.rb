module PreprocessParams
  def parse_monetary_number(value)
    return nil if value.blank?

    value.to_s.gsub(/\D/, "").to_f
  end

  def update_hash_path!(hash, path, mapper)
    return if path.blank? || hash.blank?

    if path.length == 1
      key = path.first
      hash[key] = mapper.call(hash[key])
      return
    end

    key, *rest = path
    update_hash_path!(hash[key], rest, mapper)
  end
end
