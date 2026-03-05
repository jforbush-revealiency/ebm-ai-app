FactoryGirl.define do
  factory :input_attainment, class: Input do
    submitter_first_name "First Name"
    submitter_last_name "First Name"
    submitter_email "jwswensen@gmail.com"
    submitted DateTime.now 
    user User.find_by_role("imports")

    association :vehicle, factory: :vehicle_cat_electic_attainment, code: "MD702"
    location {Location.find_by_code("Attainment")}
    #association :location, factory: :location_attainment, code: "Attainment"
  end

  factory :input_attainment_without_vehicle, class: Input do
    submitter_first_name "First Name"
    submitter_last_name "First Name"
    submitter_email "jwswensen@gmail.com"
    submitted DateTime.now 

    location {Location.find_by_code("Attainment")}
    #association :location, factory: :location_attainment, code: "Attainment"
  end

  factory :input_non_attainment, class: Input do
    submitter_first_name "First Name"
    submitter_last_name "First Name"
    submitter_email "jwswensen@gmail.com"
    submitted DateTime.now 
    user User.find_by_role("imports")

    association :vehicle, factory: :vehicle_cat_electic_non_attainment
    association :location, factory: :location_non_attainment, code: "Non Attainment"
  end

  factory :input_single_stack, class: Input do
    submitter_first_name "First Name"
    submitter_last_name "First Name"
    submitter_email "jwswensen@gmail.com"
    submitted DateTime.now 
    user User.find_by_role("imports")

    association :vehicle, factory: :vehicle_cat_single_stack, code: "SingleStack"
    location {Location.find_by_code("Attainment")}
    #association :location, factory: :location_attainment, code: "Attainment"
  end
end

