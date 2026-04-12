from app.categorizer import categorize_item

test_items = [
    "ARROZ INTEGRAL 1KG",
    "SABÃO EM PÓ OMO",
    "REFRIGERANTE COCA-COLA 2L",
    "SHAMPOO ANTI-QUEDA",
    "RESTAURANTE SABOR BRASIL",
    "DETERGENTE YPE",
    "BISCOITO RECHEADO",
    "CERVEJA SKOL 269ML",
    "PAPEL HIGIENICO NEVE"
]

print("--- Testing Categorizer ---\n")
for item in test_items:
    category = categorize_item(item)
    print(f"Product: {item:30} | Category: {category}")
