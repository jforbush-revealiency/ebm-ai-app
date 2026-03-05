FactoryGirl.define do
  factory :location_attainment, class: Location do
    code 'Pierina'
    description 'An attainment area'
    attainment true

    association :company, factory: :company, code: "Barrick Gold"
  end

  factory :location_non_attainment, class: Location do
    code 'Non Pierina'
    description 'A non-attainment area'
    attainment false

    association :company, factory: :company, code: "Barrick Gold"
  end
end

