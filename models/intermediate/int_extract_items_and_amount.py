import pandas as pd
import json

def model(dbt, session):
    # Reference another model or source
    stg_orders_df = dbt.ref("stg_orders").toPandas()
    
    def safe_extract(items):
        if isinstance(items, list):
            return items
        return []

    stg_orders_df["parsed_items"] = stg_orders_df["items_details"].apply(safe_extract)

    # Line SKU
    stg_orders_df['line_sku'] = stg_orders_df['parsed_items'].apply(
        lambda item_list: ', '.join(json.loads(item).get('sku') for item in item_list)
    )

    # Line Quantity
    stg_orders_df['line_quantity'] = stg_orders_df['parsed_items'].apply(
        lambda item_list: ', '.join(str(json.loads(item).get('quantity')) for item in item_list)
    )

    # Line Subtotal
    stg_orders_df['line_subtotal'] = stg_orders_df['parsed_items'].apply(
        lambda item_list: ', '.join(str(json.loads(item).get('subtotal')) for item in item_list)
    )

    # Quantity
    stg_orders_df['quantity'] = stg_orders_df['parsed_items'].apply(
        lambda item_list: sum(int(json.loads(item).get('quantity')) for item in item_list)
    )

    # Subtotal
    stg_orders_df['subtotal'] = stg_orders_df['parsed_items'].apply(
        lambda item_list: sum(int(json.loads(item).get('subtotal')) for item in item_list)
    )

    # Discount
    stg_orders_df['discount'] = stg_orders_df['total'].astype(float) - stg_orders_df['subtotal'].astype(float)

    # Fix types and nulls
    stg_orders_df['line_sku'] = stg_orders_df['line_sku'].fillna('').astype(str)
    stg_orders_df['line_quantity'] = stg_orders_df['line_quantity'].fillna('').astype(str)
    stg_orders_df['line_subtotal'] = stg_orders_df['line_subtotal'].fillna('').astype(str)
    stg_orders_df['quantity'] = stg_orders_df['quantity'].fillna(0).astype(int)
    stg_orders_df['subtotal'] = stg_orders_df['subtotal'].fillna(0.0).astype(float)
    stg_orders_df['total'] = stg_orders_df['total'].fillna(0.0).astype(float)
    stg_orders_df['discount'] = stg_orders_df['discount'].fillna(0.0).astype(float)

    # Drop columns that are entirely None
    stg_orders_df = stg_orders_df.dropna(axis=1, how='all')

    # Reset index
    stg_orders_df.reset_index(drop=True, inplace=True)

    return stg_orders_df
