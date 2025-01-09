import React, { useState, useEffect } from 'react';
import './OrderForm.css';  // Import CSS for styling
import { FaLinkedin, FaGithub, FaYoutube, FaMedium, FaDev, FaGlobe } from 'react-icons/fa';  // Import icons

return (
  <div className="order-form-container">
    {/* Left Panel - Main Form */}
    <div className="left-panel">
      {/* Display current date and time at the top */}
      <div className="time-display">
        {currentTime.toLocaleString()} {/* Format the date and time */}
      </div>

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

        {/* Display success message below the button */}
        {successMessage && <p className="success-message">{successMessage}</p>}
        {/* Display the Order Number */}
        {orderId && <p className="order-number">Order Number: <span>{orderId}</span></p>}
      </form>

      {/* Social Media Links */}
      <div className="social-links">
        <a href="https://www.praful.cloud" target="_blank" rel="noopener noreferrer">
          <FaGlobe className="social-icon" /> Website
        </a>
        <a href="https://linkedin.com/in/prafulpatel16" target="_blank" rel="noopener noreferrer">
          <FaLinkedin className="social-icon" /> LinkedIn
        </a>
        <a href="https://github.com/prafulpatel16/prafulpatel16" target="_blank" rel="noopener noreferrer">
          <FaGithub className="social-icon" /> GitHub
        </a>
        <a href="https://www.youtube.com/@prafulpatel16" target="_blank" rel="noopener noreferrer">
          <FaYoutube className="social-icon" /> YouTube
        </a>
        <a href="https://medium.com/@prafulpatel16" target="_blank" rel="noopener noreferrer">
          <FaMedium className="social-icon" /> Medium
        </a>
        <a href="https://dev.to/prafulpatel16" target="_blank" rel="noopener noreferrer">
          <FaDev className="social-icon" /> Dev.to
        </a>
      </div>

      {/* Footer */}
      <div className="footer">
        <p>
          Developed & Implemented By: 
          <a href="https://www.praful.cloud" target="_blank" rel="noopener noreferrer">
            PRAFUL PATEL
          </a>
        </p>
      </div>
    </div>

    {/* Right Panel - Tech Stack */}
    <div className="right-panel">
      <h2>Tech Stack</h2>
      <ul>
        <li><span>Frontend:</span> React</li>
        <li><span>Backend:</span> AWS Lambda, API Gateway, Step Functions</li>
        <li><span>Database:</span> DynamoDB</li>
        <li><span>Storage:</span> S3 for static assets and receipts</li>
        <li><span>Messaging:</span> SNS for notifications</li>
        <li><span>Infrastructure as Code:</span> AWS CloudFormation, Terraform</li>
      </ul>
    </div>
  </div>
);
