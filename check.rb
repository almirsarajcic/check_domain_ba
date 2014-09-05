require 'mechanize'

domains = %w( naziv.net.ba druginaziv.ba trecinaziv.org.ba )

domains.each do |domain|
  name, extension = domain.split('.', 2)

  agent = Mechanize.new
  agent.get('http://nic.ba') do |page|
    form = page.form_with(name: 'novi')
    form.field_with(name: 'naziv').value = name
    form.field_with(name: 'ekstenzija').options.each { |option| option.click if option.text == extension }
    result = form.submit
    
    text = result.search('.news_title_td span').first.text

    puts "#{domain}: #{text}"
  end
end
