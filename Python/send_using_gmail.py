import smtplib
import os

def send_email(sender_email, sender_password, recipient_email, subject, body):
    # Set up the SMTP server based on the operating system
    if os.name == 'posix':  # Linux
        smtp_server = 'smtp.gmail.com'
        smtp_port = 587
    elif os.name == 'nt':  # Windows
        smtp_server = 'smtp.gmail.com'
        smtp_port = 465
    else:
        print("Unsupported operating system.")
        return

    try:
        # Create an SMTP connection
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.ehlo()
            if smtp_port == 587:
                server.starttls()
            server.ehlo()

            # Log in to the Gmail account
            server.login(sender_email, sender_password)

            # Compose the email
            email_message = f"Subject: {subject}\n\n{body}"

            # Send the email
            server.sendmail(sender_email, recipient_email, email_message)

        print("Email sent successfully!")
    except Exception as e:
        print(f"An error occurred while sending the email: {e}")

# Usage example
sender_email = 'your_email@gmail.com'
sender_password = 'your_password'
recipient_email = 'recipient_email@example.com'
subject = 'Test Email'
body = 'This is a test email.'

send_email(sender_email, sender_password, recipient_email, subject, body)
