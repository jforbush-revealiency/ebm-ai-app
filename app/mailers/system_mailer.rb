class SystemMailer < ApplicationMailer
  def results_email(output)
    @output = output

    # Safe logo loading — skip if file doesn't exist
    logo_path = Rails.root.join("app/assets/images/ebmpro-logo.png")
    attachments.inline['ebmpro-logo.png'] = File.read(logo_path) if File.exist?(logo_path)

    # Safe parameter lookup — won't crash if parameter is missing
    to_email   = Parameter.find_by_code('Send_notification_emails_to')&.value
    from_email = Parameter.find_by_code('Send_notification_emails_from')&.value

    # Also notify the submitter directly
    submitter_email = output.input.submitter_email
    recipients = [to_email, submitter_email].compact.uniq.join(', ')

    return if recipients.blank?

    company = output.input.location.company
    mail(
      from:    from_email || 'noreply@ebmpros.com',
      to:      recipients,
      subject: "EBM AI Diagnostic Results — #{company.code} / #{output.location_code}"
    )
  end
end
