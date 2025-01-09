import React, { useState, useEffect } from 'react';
import './OrderForm.css';  // Import CSS for styling
import { FaLinkedin, FaGithub, FaYoutube, FaMedium, FaDev, FaGlobe } from 'react-icons/fa';  // Import icons

function OrderForm() {
  const [productId, setProductId] = useState('');
  const [quantity, setQuantity] = useState(1);
  const [customerEmail, setCustomerEmail] = useState('');
  const [successMessage, setSuccessMessage] = useState('');  // State for success message
  const [orderId, setOrderId] = useState('');  // State to store orderId
  const [currentTime, setCurrentTime] = useState(new Date());  // State to track current time

  // Update the time every second
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    // Clean up the timer when the component is unmounted
    return () => clearInterval(timer);
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();

    const order = {
      productId,
      quantity,
      customerEmail
    };

    try {
      const response = await fetch('https://88ax43nqed.execute-api.us-east-1.amazonaws.com/dev/place-order', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(order),
      });

      if (response.ok) {
        const result = await response.json();
        const orderNumber = result.OrderId || result.orderId;  // Get the order number from the response

        if (orderNumber) {
          // Clear the form fields
          setProductId('');
          setQuantity(1);
          setCustomerEmail('');
          setOrderId(orderNumber);  // Set the order number
          setSuccessMessage('Order placed successfully!');  // Set success message
        } else {
          setSuccessMessage('Order placed successfully, but no Order Number returned.');
        }
      } else {
        const errorResult = await response.json();
        console.error('Error placing order:', errorResult);
        setSuccessMessage('Failed to place order. Please try again.');
      }
    } catch (error) {
      console.error('Error placing order:', error);
      setSuccessMessage('Error placing order. Please try again.');
    }
  };

  return (
    <div className="order-form-container">
      {/* Left Panel - Main Form */}
      <div className="left-panel">
        <div className="time-display">{currentTime.toLocaleString()}</div>

        <h1 className="title">AWS Serverless Project - Order Processing System</h1>

        <form onSubmit={handleSubmit} className="order-form">
          <div className="form-group">
            <label>Product ID:</label>
            <input
              type="text"
              value={productId}
              onChange={(e) => setProductId(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Quantity:</label>
            <input
              type="number"
              value={quantity}
              onChange={(e) => setQuantity(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Customer Email:</label>
            <input
              type="email"
              value={customerEmail}
              onChange={(e) => setCustomerEmail(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="submit-button">Place Order</button>

          {successMessage && <p className="success-message">{successMessage}</p>}
          {orderId && <p className="order-number">Order Number: <span>{orderId}</span></p>}
        </form>
      </div>

      {/* Right Panel - Tech Stack */}
      <div className="right-panel">
        <h2>Tech Stack</h2>
        <ul>
          <li><strong>Frontend:</strong> React</li>
          <li><strong>Backend:</strong> AWS Lambda, API Gateway, Step Functions</li>
          <li><strong>Database:</strong> DynamoDB</li>
          <li><strong>Storage:</strong> S3 for static assets and receipts</li>
          <li><strong>Messaging:</strong> SNS for notifications</li>
          <li><strong>Infrastructure as Code:</strong> AWS CloudFormation, Terraform</li>
        </ul>
      </div>
    </div>
  );
}

export default OrderForm;
