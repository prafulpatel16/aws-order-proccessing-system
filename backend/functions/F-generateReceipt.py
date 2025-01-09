import json
import os
import boto3
from datetime import datetime
from fpdf import FPDF

# Initialize the S3 client
s3 = boto3.client('s3')

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
        print(f"Received event: {event}")

        # Extract necessary fields
        order_id = event.get('orderId') or event.get('OrderId')
        email = event.get('email')
        product_id = event.get('productId')
        quantity = event.get('quantity')

        if not order_id:
            raise Exception("'orderId' or 'OrderId' is required but not found in the event")
        if not email:
            raise Exception("'email' is required but not found in the event")
        if not product_id:
            raise Exception("'productId' is required but not found in the event")
        if not quantity:
            raise Exception("'quantity' is required but not found in the event")

        # Generate current timestamp
        current_time = datetime.utcnow().isoformat()

        # Receipt content
        receipt = {
            'Order ID': order_id,
            'Email': email,
            'Product ID': product_id,
            'Quantity': quantity,
            'Date': current_time
        }

        # Log receipt data
        print(f"Generated receipt: {receipt}")

        # Get the S3 bucket name from environment variables
        bucket_name = os.environ['S3_BUCKET_NAME'].strip()
        if not bucket_name:
            raise Exception("'S3_BUCKET_NAME' environment variable is missing")

        # Create the PDF receipt
        pdf = PDF()
        pdf.add_page()
        pdf.set_font('Arial', '', 12)

        pdf.cell(0, 10, 'Receipt Details:', ln=1)
        pdf.ln(10)
        for key, value in receipt.items():
            pdf.cell(0, 10, f'{key}: {value}', ln=1)

        # Save the PDF to a local file
        pdf_file_path = f"/tmp/{order_id}.pdf"
        pdf.output(pdf_file_path)

        # Log PDF generation success
        print(f"PDF generated successfully: {pdf_file_path}")

        # Generate the S3 object key
        object_key = f"receipts/{order_id}.pdf"

        # Upload the PDF to S3
        with open(pdf_file_path, 'rb') as pdf_file:
            s3.put_object(
                Bucket=bucket_name,
                Key=object_key,
                Body=pdf_file,
                ContentType='application/pdf'
            )

        # Log successful upload
        print(f"PDF receipt uploaded to S3: s3://{bucket_name}/{object_key}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'PDF receipt generated and saved successfully',
                'receiptUrl': f"s3://{bucket_name}/{object_key}"
            })
        }

    except Exception as e:
        # Log the error
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'PDF receipt generation failed',
                'error': str(e)
            })
        }
