import json
import os
import boto3
import base64
from datetime import datetime
from fpdf import FPDF
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

# Initialize the S3 client and SES client
s3 = boto3.client('s3')
ses = boto3.client('ses')

class PDF(FPDF):
    def header(self):
        self.set_font('Arial', 'B', 12)
        self.cell(0, 10, 'Order Receipt', align='C', ln=1)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', align='C')

def lambda_handler(event, context):
    try:
        # Log the incoming event
        print("Step 1: Lambda function started.")
        print(f"Received event: {json.dumps(event)}")

        # Extract necessary fields
        print("Step 2: Extracting event fields.")
        order_id = event.get('orderId') or event.get('OrderId')
        email = event.get('email')
        product_id = event.get('productId')
        quantity = event.get('quantity')

        if not order_id or not email or not product_id or not quantity:
            raise Exception("Required fields are missing in the event.")

        print(f"Order ID: {order_id}, Email: {email}, Product ID: {product_id}, Quantity: {quantity}")

        # Generate current timestamp
        current_time = datetime.utcnow().isoformat()
        print(f"Step 3: Generated timestamp: {current_time}")

        # Receipt content
        receipt = {
            'Order ID': order_id,
            'Email': email,
            'Product ID': product_id,
            'Quantity': quantity,
            'Date': current_time
        }

        print(f"Step 4: Generated receipt content: {json.dumps(receipt)}")

        # Get the S3 bucket name from environment variables
        bucket_name = os.environ.get('S3_BUCKET_NAME')
        if not bucket_name:
            raise Exception("'S3_BUCKET_NAME' environment variable is missing")
        print(f"Step 5: Using S3 bucket: {bucket_name}")

        # Create the PDF receipt
        pdf = PDF()
        pdf.add_page()
        pdf.set_font('Arial', '', 12)

        pdf.cell(0, 10, 'Receipt Details:', ln=1)
        pdf.ln(10)
        for key, value in receipt.items():
            pdf.cell(0, 10, f'{key}: {value}', ln=1)

        pdf_file_path = f"/tmp/{order_id}.pdf"
        pdf.output(pdf_file_path)
        print(f"Step 6: PDF generated at {pdf_file_path}")

        # Upload the PDF to S3
        object_key = f"receipts/{order_id}.pdf"
        with open(pdf_file_path, 'rb') as pdf_file:
            s3.put_object(
                Bucket=bucket_name,
                Key=object_key,
                Body=pdf_file,
                ContentType='application/pdf'
            )
        print(f"Step 7: Uploaded PDF to S3: s3://{bucket_name}/{object_key}")

        # Read the PDF content and encode it in base64
        with open(pdf_file_path, 'rb') as pdf_file:
            pdf_data = pdf_file.read()
        pdf_base64 = base64.b64encode(pdf_data).decode('utf-8')
        print("Step 8: PDF encoded in base64.")

        # Send the email with the attachment
        send_email_with_attachment(email, pdf_base64, order_id)

        print("Step 9: Email sent successfully.")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'PDF receipt generated, saved to S3, and emailed successfully',
                'receiptUrl': f"s3://{bucket_name}/{object_key}"
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'PDF receipt generation failed',
                'error': str(e)
            })
        }

def send_email_with_attachment(email, pdf_base64, order_id):
    try:
        # Step 1: Logging preparation for email
        print("Step 8.1: Preparing email with attachment.")

        # Sender and recipient
        sender_email = os.environ.get('SES_SENDER_EMAIL')
        if not sender_email:
            raise Exception("'SES_SENDER_EMAIL' environment variable is missing.")
        print(f"Sender email verified: {sender_email}")

        recipient_email = email
        print(f"Recipient email provided: {recipient_email}")

        # Step 2: Setting email subject and body
        subject = f"Your Order Receipt - Order ID: {order_id}"
        print(f"Email subject set: {subject}")

        body_text = "Thank you for your order. Please find your receipt attached."
        body_html = """
        <html>
            <body>
                <h1>Thank you for your order!</h1>
                <p>Please find your receipt attached.</p>
            </body>
        </html>
        """
        print("Email body content created.")

        # Step 3: Creating a MIME multipart message
        msg = MIMEMultipart()
        msg['Subject'] = subject
        msg['From'] = sender_email
        msg['To'] = recipient_email

        # Attaching text and HTML body to the email
        msg.attach(MIMEText(body_text, 'plain'))
        msg.attach(MIMEText(body_html, 'html'))
        print("Text and HTML body added to the email.")

        # Step 4: Decoding base64 PDF content and attaching it
        pdf_data = base64.b64decode(pdf_base64)
        attachment = MIMEApplication(pdf_data, _subtype="pdf")
        attachment.add_header(
            'Content-Disposition',
            'attachment',
            filename=f"{order_id}.pdf"
        )
        msg.attach(attachment)
        print(f"PDF attachment added: {order_id}.pdf")

        # Step 5: Sending the email using SES
        print("Step 8.2: Sending email via SES.")
        response = ses.send_raw_email(
            Source=sender_email,
            Destinations=[recipient_email],
            RawMessage={
                'Data': msg.as_string()
            }
        )

        # Logging the success response
        print(f"Step 8.3: Email sent successfully!")
        print(f"Message ID: {response['MessageId']}")

    except Exception as e:
        # Detailed error logging
        print(f"Error occurred in send_email_with_attachment: {str(e)}")
        raise
