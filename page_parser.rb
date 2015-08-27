class ProductFetcher
  REGEXP = {
    title:  Regexp.new('\s\d+[г|гр|грамм|кг|килограмм|шт|л|мл]+|\sкг\s|Украина|Россия|\s\d+,\d+[а-яА-Я]+|\sкг|\.$|в\/г|уп\.\d+[а-я]+|\sкг\s'),
    image:  Regexp.new('^http.+[jpg|png|jpeg|gif]$'),
    unit:   Regexp.new('(\s\d+[г|гр|грамм|кг|килограмм|шт|л|мл]+|\sкг\s)'),
    weight_and_measure: Regexp.new('(\s|\d+|\d+[,|.]\d+)(кг|г|л|мл|шт)\b')
  }

  attr_reader :element, :root_link

  def initialize element, root_link
    @element = element
    @root_link = root_link
  end

  def save
    novus_product.assign_attributes params
    novus_product.image_attributes = { picture: image }
    novus_product.touch unless novus_product.new_record?
    novus_product.save
  end

  def source
    @root_link + href_src
  end

  def title
    title_src.gsub(REGEXP[:title], '')
  end

  def price
    grn = element.at_css('.grivna.price').text
    coin = element.at_css('.kopeiki').text
    "#{grn}#{coin}".to_i
  end

  def image
    return URI.parse(image_src) if image_src[REGEXP[:image]]
    File.new('public/images/noimage.png', 'r')
  end

  def unit
    text = unit_src.text.split('/')
    regex = REGEXP[:unit]
    if text.count > 1
      text.last
    elsif regex.match(unit_src.text) || regex.match(title_src)
      $1.lstrip
    else
      "шт"
    end
  end

  def weight
    match_example = REGEXP[:weight_and_measure].match(title_src)

    return 1.0 if match_example.nil?

    overlap_measure = match_example[1].gsub(",", ".")
    overlap_unit = match_example[2]

    return 1.0 if overlap_measure.blank?

    if %w(г мл).include?(overlap_unit) && overlap_measure.present?
      Float(overlap_measure) / 1000
    else
      overlap_measure.to_f
    end
  end

  def measure
    REGEXP[:weight_and_measure].match(title_src)
    if $2.blank?
      REGEXP[:weight_and_measure].match(unit_src.text)
      if $2.blank?
        return unit
      end
    end
    $2
  end

  private
  def params
    {
      title: title,
      source: source,
      price: price,
      unit: unit,
      weight: weight,
      measure: formatted_measure
    }
  end

  def formatted_measure
    return "кг" if measure == "г"
    return "л" if measure == "мл"
    measure
  end

  def unit_src
    element.at_css('.one-product-price-hrn')
  end

  def title_src
    element.at_css('a')['title']
  end

  def image_src
    element.at_css('img')['src']
  end

  def href_src
    element.at_css('a')['href']
  end

  def novus_product
    @novus_product ||= NovusProduct.find_or_initialize_by(source: source)
  end

end
