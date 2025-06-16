import pandas as pd
import json

def model(dbt, session):
    df = dbt.ref('stg_saad_woocommerce_api__raw_woocommerce_orders').toPandas()

    def parse_items(items):
        try:
            return [json.loads(item) for item in items] if isinstance(items, list) else []
        except:
            return []

    def extract_item_data(items):
        skus, quantities, subtotals = [], [], []
        qty_sum, subtotal_sum = 0, 0
        for item in items:
            sku = item.get('sku', '')
            qty = int(item.get('quantity', 0))
            sub = int(item.get('subtotal', 0))
            skus.append(sku)
            quantities.append(str(qty))
            subtotals.append(str(sub))
            qty_sum += qty
            subtotal_sum += sub
        return pd.Series({
            'line_sku': ', '.join(skus),
            'line_quantity': ', '.join(quantities),
            'line_subtotal': ', '.join(subtotals),
            'quantity': qty_sum,
            'subtotal': subtotal_sum
        })

    df['parsed_items'] = df['items_details'].apply(parse_items)
    item_data = df['parsed_items'].apply(extract_item_data)
    df = pd.concat([df, item_data], axis=1)

    df['total'] = df['total'].fillna(0.0).astype(float)
    df['subtotal'] = df['subtotal'].fillna(0.0).astype(float)
    df['discount'] = df['total'] - df['subtotal']

    df = df.dropna(axis=1, how='all').reset_index(drop=True)

    return df
