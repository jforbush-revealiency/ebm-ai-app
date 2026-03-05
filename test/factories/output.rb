FactoryGirl.define do
  factory :input do
    submitter_first_name "First Name"
    submitter_last_name "First Name"
    submitter_email "jwswensen@gmail.com"
    submitted Date.today 
    company_code ""
  end
end
