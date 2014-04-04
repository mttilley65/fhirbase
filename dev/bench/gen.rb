require 'faker'

def gen(number, &block)
  n = if number.is_a?(Range)
        number.last < Float::INFINITY ? number.last : number
      else
        number
      end
  min = number.is_a?(Range) ? number.first : 0

  res = (rand(n + 1) + min).times.map(&block)
  res.empty? ? nil : res
end

def gen_identifier(number = 1)
  tpls = [
    { use: 'official', label: 'BSN', system: 'urn:oid:2.16.840.1.113883.2.4.6.3', value: '123123' },
    { use: "official", label:"SSN", system:"urn:oid:2.16.840.1.113883.2.4.6.7", value:"123456789" }]

  gen(3) do
    tpls.sample.merge value: (1000000 + rand(1000000)).to_s, use: %w(usual  official  temp  secondary).sample
  end
end

def gen_active(number = 1)
  [true, false].sample
end

def gen_codeable_concept(number = 1)
  res = {}
  # object :coding, (0..Float::INFINITY) do
  #   # Coding Code defined by a terminology system
  # end
  gen(0..1) do
    res[:text] = Faker::Lorem.sentence # Plain text representation of the concept
  end

  res unless res.empty?
end

def gen_category(number = 1)
  gen(3) do
    { scheme: Faker::Internet.url('http://hl7.org/fhir/tag/'), term: Faker::Internet.url, label: Faker::Lorem.sentence }
  end
end

def gen_name(number = 1)
  gen(1) do 
    {
      use: %w(usual  official  temp  nickname  anonymous  old  maiden).sample,
      text: Faker::Name.name,
      family: gen(2) { Faker::Name.last_name },
      given: gen(2) { Faker::Name.first_name },
      prefix: gen(1) { Faker::Name.prefix }
    }
  end
end

def gen_telecom(number = 1)
  gen(2) do
    [
      {
        system: %w(phone fax).sample,
        value: Faker::PhoneNumber.cell_phone,
        use: %w(home  work  temp  old  mobile).sample
      },
      {
        system: 'email',
        value: Faker::Internet.email,
        use: %w(home  work  temp  old  mobile).sample
      }
    ].sample
  end
end

def gen_gender(number)
  gen(1) do
    {
      coding: [{ system: 'http://hl7.org/fhir/v3/AdministrativeGender', code: %w(M F).sample, display: %w(Male Female).sample }] # bug
    }
  end
end

def gen_birthDate(number = 1)
  Time.at(rand * Time.now.to_i)
end

def gen_deceasedBoolean(number = 1)
  rand % 100 == 0
end

def address
  gen(2) do
    res = { use: %w(home work temp old).sample,
      line: [Faker::Address.street_address],
      city: Faker::Address.city,
      zip: Faker::Address.zip,
      state: Faker::Address.state
    }
    res[:text] = [res[:line].join("\n"), res[:state], res[:zip]].join(", ")
    res
  end
end

def gen_address(number = 1) end
def gen_maritalStatus(number = 1) end
def gen_photo(number = 1) end
def gen_contact(number = 1) end
def gen_communication(number = 1) end
def gen_careProvider(number = 1) end

def gen_managingOrganization(number = 1)
  res = {}
  identifier = gen_identifier(0..Float::INFINITY)
  if identifier
    res[:identifier] = identifier # Identifier Identifies this organization  across multiple systems
  end
  gen(0..1) do
    res[:name] =  Faker::Company.name # Name used for the organization
  end
  gen(0..1) do
    type = gen_codeable_concept(0..1)
    if type
      res[:type] = type # Kind of organization
    end
  end

  res unless res.empty?
end

def gen_patient(number)
  gen(number) do
    res = { resourceType: 'Patient' }

    {
      identifier:           0..Float::INFINITY,
      category:             0, #wtf?
      name:                 0..Float::INFINITY,
      telecom:              0..Float::INFINITY,
      gender:               0..1,
      birthDate:            0..1,
      deceasedBoolean:      0..1,
      address:              0..Float::INFINITY,
      maritalStatus:        0..1,
      photo:                0..Float::INFINITY,
      contact:              0..Float::INFINITY,
      communication:        0..Float::INFINITY,
      careProvider:         0..Float::INFINITY,
      managingOrganization: 0..1,
      active:               0..1
    }.each do |name, number|
      res[name] = send("gen_#{name}", number)
      res.delete_if { |k, v| v.nil? }
    end

    res
  end
end
