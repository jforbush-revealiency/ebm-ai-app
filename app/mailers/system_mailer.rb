class SystemMailer < ApplicationMailer
  def results_email(output)
    @output = output
    attachments.inline['ebmpro-logo.png'] = File.read(Rails.root.join("app/assets/images/ebmpro-logo.png"))
    to_email = Parameter.find_by_code('Send_notification_emails_to').value
    from_email = Parameter.find_by_code('Send_notification_emails_from').value
    company = @output.input.location.company
    mail(from: from_email, to: to_email, subject: "Results were generated for #{company.code} / #{output.location_code}")
  end
end
