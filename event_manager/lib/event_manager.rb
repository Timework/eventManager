require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
                                  address: zip,
                                  levels: 'country',
                                  roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_numbers(first_number)
    numbers = "0123456789"
    phone_number = ""
    first_number.each_char do |x|
        if numbers.include? x
            phone_number += x
        end
    end
    if phone_number.nil?
        return "no number"
    end
    if phone_number.length == 10
        return phone_number
    elsif phone_number.length == 11 && phone_number[0] == "1"
        return phone_number[1..-1]
    else
        return "Bad Number"
    end
end

def getHour(time)
    hour = DateTime.strptime(time, '%m/%d/%Y %H:%M')
    return hour.hour
end

def getDay(time)
    day = DateTime.strptime(time, '%m/%d/%Y %H:%M')
    return day.wday
end

puts "EventManager Initialized!"

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents = CSV.open"event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
    id = row[0]
    time = row[:regdate]
    phone_number = row[:homephone]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)
    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)


end