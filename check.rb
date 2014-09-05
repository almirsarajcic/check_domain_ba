require 'mechanize'
require 'trollop'

def check_occupancy(name, extension)
  agent = Mechanize.new

  agent.get('http://nic.ba') do |page|
    page.form.field_with(name: 'naziv').value = name
    page.form.field_with(name: 'ekstenzija').options.each { |option| option.click if option.text == extension }
    result = page.form.submit

    text = result.search('.news_title_td span').first.text

    puts "#{name}.#{extension}: #{text}"
  end
end

def get_whois(name, extension)
  agent = Mechanize.new

  agent.get('http://nic.ba/lat/menu/view/13') do |page|
    page.form.field_with(name: 'whois_select_name').value = name
    page.form.field_with(name: 'whois_select_type').options.each { |option| option.click if option.text == extension }
    page.form.checkbox.click
    result = page.form.submit

    image = result.search('.textNormal img').first.attributes['src']
    agent.get(image).save_as("images/#{name}.#{extension}.png")
  end
end

opts = Trollop::options do
  opt :occupancy, 'Check domain occupancy?', default: true
  opt :whois, 'Get domain whois info?', default: true
  opt :domain, 'Domain to check (if this argument is provided filename will be ignored)', default: ''
  opt :filename, 'File where the domains are listed', default: 'domains.txt'
end

domains = []

if opts[:domain].length > 0
  domains << opts[:domain]
elsif File.exists?(opts[:filename])
  domains = File.readlines(opts[:filename])
else
  abort('File does not exist.')
end

domains.each do |domain|
  name, extension = domain.strip.split('.', 2)

  check_occupancy(name, extension) if opts[:occupancy]
  get_whois(name, extension) if opts[:whois]
end
