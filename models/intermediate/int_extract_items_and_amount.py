import pandas as pd
import json

def model(dbt, session):
    df = dbt.ref("stg_saad_woocommerce_api__raw_woocommerce_orders").toPandas()

    def safe_extract(items):
        if isinstance(items, list):
            return items
        try:
            parsed = json.loads(items)
            return parsed if isinstance(parsed, list) else []
        except:
            return []

    def extract_field(item_list, field):
        try:
            return ', '.join(str(json.loads(i).get(field, '')) for i in item_list)
        except:
            return ''

    def sum_field(item_list, field):
        try:
            return sum(int(json.loads(i).get(field, 0) or 0) for i in item_list)
        except:
            return 0

    df["parsed_items"] = df["items_details"].apply(safe_extract)
    df["line_sku"] = df["parsed_items"].apply(lambda x: extract_field(x, 'sku'))
    df["line_quantity"] = df["parsed_items"].apply(lambda x: extract_field(x, 'quantity'))
    df["line_subtotal"] = df["parsed_items"].apply(lambda x: extract_field(x, 'subtotal'))
    df["quantity"] = df["parsed_items"].apply(lambda x: sum_field(x, 'quantity'))
    df["subtotal"] = df["parsed_items"].apply(lambda x: sum_field(x, 'subtotal'))

    df['total'] = pd.to_numeric(df['total'], errors='coerce').fillna(0)
    df['discount'] = df['total'] - df['subtotal']

    df.fillna('', inplace=True)
    df = df.dropna(axis=1, how='all')
    df.reset_index(drop=True, inplace=True)

    return df
