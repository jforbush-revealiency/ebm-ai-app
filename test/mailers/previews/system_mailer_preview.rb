# Preview all emails at http://localhost:3000/rails/mailers/system_mailer
# http://localhost:3000/rails/mailers/system_mailer/results_email_success.html
class SystemMailerPreview < ActionMailer::Preview
  def results_email_errors
    SystemMailer.results_email(Output.first)
  end
  def results_email_success
    #SystemMailer.results_email(Output.find(10))
    #SystemMailer.results_email(Output.find(1313)) # Electric
    #SystemMailer.results_email(Output.last) # Mechanical
    SystemMailer.results_email(Output.find(2703)) # Single Stack 
  end
end
