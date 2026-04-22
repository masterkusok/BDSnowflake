INSERT INTO dim_pet_breed (breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL
ON CONFLICT (breed_name) DO NOTHING;

INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code, pet_type, pet_name, pet_breed_id)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    b.pet_breed_id
FROM mock_data m
JOIN dim_pet_breed b ON b.breed_name = m.customer_pet_breed
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
ON CONFLICT (seller_id) DO NOTHING;

INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO dim_store (name, address, city, state, country, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_name IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO dim_product (product_id, name, category, price, quantity, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date, pet_category_id)
SELECT DISTINCT ON (sale_product_id)
    sale_product_id,
    product_name,
    product_category,
    product_price,
    product_quantity,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    pc.pet_category_id
FROM mock_data m
JOIN dim_pet_category pc ON pc.category_name = m.pet_category
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dim_date (date_id, full_date, day, month, year, quarter)
SELECT DISTINCT
    TO_CHAR(sale_date, 'YYYYMMDD')::INTEGER,
    sale_date,
    EXTRACT(DAY     FROM sale_date)::INTEGER,
    EXTRACT(MONTH   FROM sale_date)::INTEGER,
    EXTRACT(YEAR    FROM sale_date)::INTEGER,
    EXTRACT(QUARTER FROM sale_date)::INTEGER
FROM mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (date_id) DO NOTHING;

INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, supplier_id, date_id, sale_quantity, sale_total_price)
SELECT
    m.sale_customer_id,
    m.sale_seller_id,
    m.sale_product_id,
    s.store_id,
    sup.supplier_id,
    TO_CHAR(m.sale_date, 'YYYYMMDD')::INTEGER,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN LATERAL (
    SELECT store_id FROM dim_store
    WHERE name = m.store_name
      AND city = m.store_city
      AND COALESCE(state, '') = COALESCE(m.store_state, '')
    LIMIT 1
) s ON true
JOIN LATERAL (
    SELECT supplier_id FROM dim_supplier
    WHERE name = m.supplier_name
      AND contact = m.supplier_contact
    LIMIT 1
) sup ON true;
