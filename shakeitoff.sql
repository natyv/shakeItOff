CREATE TABLE users (
  id SERIAL4 PRIMARY KEY,
  email VARCHAR(50) NOT NULL,
  password_digest VARCHAR(400) NOT NULL,
  name VARCHAR(80),
  age INTEGER,
  weight FLOAT(2),
  height FLOAT(2),
  gender VARCHAR(10)
);

CREATE TABLE food_items (
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(80),
  calories INTEGER,
  day DATE,
  user_id INTEGER

);
