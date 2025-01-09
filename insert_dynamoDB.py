import boto3
from random import randint, choice

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb', region_name='us-east-1')

# Function to generate random product data
def generate_random_products(count=20):
    descriptions = [
        "High-quality product", "Budget-friendly item", "Premium design product",
        "Multi-purpose gadget", "Ergonomic and lightweight tool", "Durable equipment",
        "Exclusive edition item", "Energy-efficient device", "Portable solution",
        "User-friendly appliance", "Innovative technology item"
    ]
    products = []
    for i in range(1, count + 1):
        product_id = f"P{str(i).zfill(3)}"
        description = choice(descriptions)
        price = randint(10, 500)  # Price between $10 and $500
        stock = randint(1, 100)  # Stock between 1 and 100
        email = "aystester1@gmail.com"  # Fixed email for all products
        products.append({
            'productId': {'S': product_id},
            'description': {'S': description},
            'price': {'N': str(price)},
            'stock': {'N': str(stock)},
            'email': {'S': email}
        })
    return products

# Generate 20 random products
products = generate_random_products(20)

# Insert products into the DynamoDB table
for product in products:
    try:
        response = dynamodb.put_item(
            TableName='Products',  # Replace with your table name
            Item=product
        )
        print(f"Inserted product: {product['productId']['S']} with email: {product['email']['S']}")
    except Exception as e:
        print(f"Failed to insert product: {product['productId']['S']}, Error: {e}")
