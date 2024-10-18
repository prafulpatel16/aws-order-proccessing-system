import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
//import '@testing-library/jest-dom/extend-expect'; // For better assertion syntax
 // Adjust the path if needed
import '@testing-library/jest-dom';
import '../OrderForm.css';  // Import CSS for styling
import App from '../App.js';






// Mocking the fetch function
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({ OrderId: '1234' }),
  })
);

describe('OrderForm Component', () => {
  beforeEach(() => {
    // Reset fetch mock before each test
    fetch.mockClear();
  });

  test('renders OrderForm and displays the title', () => {
    render(<OrderForm />);
    expect(screen.getByText('AWS Serverless Order Management System')).toBeInTheDocument();
  });

  test('submits the form and displays success message with order number', async () => {
    render(<OrderForm />);

    // Enter values into form fields
    fireEvent.change(screen.getByLabelText(/Product ID/i), { target: { value: 'P001' } });
    fireEvent.change(screen.getByLabelText(/Quantity/i), { target: { value: '2' } });
    fireEvent.change(screen.getByLabelText(/Customer Email/i), { target: { value: 'test@example.com' } });

    // Click the submit button
    fireEvent.click(screen.getByText(/Place Order/i));

    // Wait for the fetch to complete and the success message to appear
    await waitFor(() => screen.getByText(/Order placed successfully!/));

    // Assert that success message is displayed
    expect(screen.getByText(/Order placed successfully!/)).toBeInTheDocument();

    // Assert that the order number is displayed
    expect(screen.getByText(/Order Number: 1234/)).toBeInTheDocument();
  });

  test('handles failed order submission', async () => {
    // Mocking fetch to return an error response
    fetch.mockImplementationOnce(() =>
      Promise.resolve({
        ok: false,
        json: () => Promise.resolve({ error: 'Failed to place order' }),
      })
    );

    render(<OrderForm />);

    // Enter values into form fields
    fireEvent.change(screen.getByLabelText(/Product ID/i), { target: { value: 'P001' } });
    fireEvent.change(screen.getByLabelText(/Quantity/i), { target: { value: '2' } });
    fireEvent.change(screen.getByLabelText(/Customer Email/i), { target: { value: 'test@example.com' } });

    // Click the submit button
    fireEvent.click(screen.getByText(/Place Order/i));

    // Wait for the fetch to complete and error message to appear
    await waitFor(() => screen.getByText(/Failed to place order/));

    // Assert that failure message is displayed
    expect(screen.getByText(/Failed to place order/)).toBeInTheDocument();
  });
});
