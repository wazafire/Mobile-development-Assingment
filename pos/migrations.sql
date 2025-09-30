-- Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id VARCHAR(128) UNIQUE NOT NULL,
  payload JSON NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create invoice_responses table
CREATE TABLE IF NOT EXISTS invoice_responses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id VARCHAR(128) NOT NULL,
  status_code INT,
  response_body JSON,
  authority_reference VARCHAR(256),
  attempt_no INT,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
