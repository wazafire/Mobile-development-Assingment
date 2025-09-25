INSERT INTO users (username, password_hash, role)
VALUES ('admin', 'hashedpasswordhere', 'admin');

INSERT INTO products (name, price, tax_rate)
VALUES ('Burger', 50.0, 0.16),
       ('Pizza', 120.0, 0.16),
       ('Soda', 20.0, 0.16);
