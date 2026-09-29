import pandas as pd

# Load all source tables
orders = pd.read_csv("olist_orders_dataset.csv")
items = pd.read_csv("olist_order_items_dataset.csv")
products = pd.read_csv("olist_products_dataset.csv")
customers = pd.read_csv("olist_customers_dataset.csv")
payments = pd.read_csv("olist_order_payments_dataset.csv")
reviews = pd.read_csv("olist_order_reviews_dataset.csv")
sellers = pd.read_csv("olist_sellers_dataset.csv")
category_translation = pd.read_csv("product_category_name_translation.csv")

# Translate product categories (Portuguese -> English)
products = products.merge(category_translation, on="product_category_name", how="left")
products["product_category_name_english"] = products["product_category_name_english"].fillna("unknown")

# Merge into one master table (one row per order item)
master = items.merge(orders, on="order_id", how="left")
master = master.merge(customers, on="customer_id", how="left")
master = master.merge(products[["product_id", "product_category_name_english"]], on="product_id", how="left")
master = master.merge(sellers, on="seller_id", how="left")

# Aggregate payments to order level
payment_summary = payments.groupby("order_id").agg(
    total_payment=("payment_value", "sum"),
    payment_type=("payment_type", lambda x: x.mode()[0] if not x.mode().empty else "unknown")
).reset_index()
master = master.merge(payment_summary, on="order_id", how="left")

# Average review score per order
review_summary = reviews.groupby("order_id")["review_score"].mean().reset_index()
master = master.merge(review_summary, on="order_id", how="left")

# Delivery delay feature (negative = early, positive = late)
for col in ["order_purchase_timestamp", "order_delivered_customer_date", "order_estimated_delivery_date"]:
    master[col] = pd.to_datetime(master[col])
master["delivery_delay_days"] = (
    master["order_delivered_customer_date"] - master["order_estimated_delivery_date"]
).dt.days

master.to_csv("olist_master_clean.csv", index=False)
print("Saved olist_master_clean.csv", master.shape)
